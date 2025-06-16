# Direct EC2 deployment without local Docker
# This script deploys everything directly on the EC2 instance

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "preprod", "prod")]
    [string]$Environment = "dev"
)

$EC2_IP = "52.91.251.180"
$EC2_USER = "ubuntu"
$KEY_PATH = "C:\Users\PC\Downloads\DevSecOps_jenkins.pem"

Write-Host "🚀 Direct EC2 Deployment (No Local Docker Required)" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Yellow

# Check if SSH key exists
if (-not (Test-Path $KEY_PATH)) {
    Write-Host "❌ SSH key not found at: $KEY_PATH" -ForegroundColor Red
    Write-Host "💡 Please ensure your EC2 SSH key is located at: $KEY_PATH" -ForegroundColor Yellow
    Write-Host "💡 Or update the KEY_PATH variable in this script" -ForegroundColor Yellow
    exit 1
}

# Test SSH connectivity
Write-Host "🔍 Testing SSH connectivity..." -ForegroundColor Yellow
try {
    ssh -i $KEY_PATH -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo 'Connection successful'" 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH connection successful" -ForegroundColor Green
    } else {
        throw "SSH failed"
    }
} catch {
    Write-Host "❌ SSH connection failed" -ForegroundColor Red
    Write-Host "📋 Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "   1. Ensure EC2 instance is running" -ForegroundColor White
    Write-Host "   2. Check security group allows SSH (port 22)" -ForegroundColor White
    Write-Host "   3. Verify SSH key path: $KEY_PATH" -ForegroundColor White
    Write-Host "   4. Set correct key permissions: icacls `"$KEY_PATH`" /inheritance:r" -ForegroundColor White
    exit 1
}

# Create temporary directory for files
$tempDir = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
    # Create deployment package
    Write-Host "📦 Creating deployment package..." -ForegroundColor Yellow
    
    # Copy application files
    Copy-Item -Path "app\*" -Destination $tempDir -Recurse
    Copy-Item -Path "docker\*" -Destination $tempDir
    Copy-Item -Path "environments\$Environment.env" -Destination "$tempDir\.env"
    
    # Create deployment script for EC2
    $deployScript = @"
#!/bin/bash
set -e

echo "🚀 Starting deployment on EC2..."

# Update system
sudo apt update -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
    echo "✅ Docker installed"
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`$(uname -s)`-`$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
fi

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "✅ Node.js installed"
fi

# Create application directory
APP_DIR="/opt/devops-app-$Environment"
sudo mkdir -p `$APP_DIR
sudo chown ubuntu:ubuntu `$APP_DIR

# Copy application files
cp -r /tmp/deployment/* `$APP_DIR/

cd `$APP_DIR

# Install dependencies
echo "📦 Installing Node.js dependencies..."
npm install --production

# Build Docker image
echo "🔨 Building Docker image..."
docker build -f Dockerfile -t devops-sample-app:$Environment .

# Set port based on environment
case "$Environment" in
    "dev")
        export PORT=80
        export APP_PORT=3000
        ;;
    "preprod")
        export PORT=8080
        export APP_PORT=3001
        ;;
    "prod")
        export PORT=9000
        export APP_PORT=3002
        ;;
esac

# Create docker-compose file
cat > docker-compose.yml << 'EOL'
version: '3.8'

services:
  app:
    image: devops-sample-app:$Environment
    ports:
      - "`${APP_PORT}:3000"
    environment:
      - NODE_ENV=$Environment
      - PORT=3000
    restart: unless-stopped
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "node", "healthcheck.js"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    ports:
      - "`${PORT}:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOL

# Stop existing containers for this environment
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Start new containers
echo "🚀 Starting containers..."
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 15

# Health check
echo "🔍 Performing health check..."
if curl -f http://localhost:`$PORT/health > /dev/null 2>&1; then
    echo "✅ Application deployed successfully!"
    echo "🌐 Access at: http://52.91.251.180:`$PORT"
else
    echo "❌ Health check failed. Checking logs..."
    docker-compose logs
    exit 1
fi

echo "✅ Deployment completed successfully!"
"@

    # Save deployment script
    $deployScript | Out-File -FilePath "$tempDir\deploy.sh" -Encoding UTF8

    # Transfer files to EC2
    Write-Host "📤 Transferring files to EC2..." -ForegroundColor Yellow
    
    # Create deployment directory on EC2
    ssh -i $KEY_PATH "$EC2_USER@$EC2_IP" "sudo mkdir -p /tmp/deployment && sudo chown ubuntu:ubuntu /tmp/deployment"
    
    # Transfer files using SCP
    scp -i $KEY_PATH -r "$tempDir\*" "$EC2_USER@$EC2_IP" + ":/tmp/deployment/"
    
    # Make script executable and run deployment
    Write-Host "🚀 Running deployment on EC2..." -ForegroundColor Yellow
    ssh -i $KEY_PATH "$EC2_USER@$EC2_IP" "chmod +x /tmp/deployment/deploy.sh && /tmp/deployment/deploy.sh"
    
    if ($LASTEXITCODE -eq 0) {
        $port = switch ($Environment) {
            "dev" { 80 }
            "preprod" { 8080 }
            "prod" { 9000 }
        }
        
        Write-Host ""
        Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
        Write-Host "🌐 Application URL: http://$EC2_IP`:$port" -ForegroundColor Cyan
        Write-Host "📊 Health Check: http://$EC2_IP`:$port/health" -ForegroundColor Cyan
        Write-Host "🔧 API Endpoint: http://$EC2_IP`:$port/api/users" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🧪 Test the deployment:" -ForegroundColor Yellow
        Write-Host "   curl http://$EC2_IP`:$port/health" -ForegroundColor White
    } else {
        Write-Host "❌ Deployment failed!" -ForegroundColor Red
        exit 1
    }

} finally {
    # Clean up temporary directory
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
}

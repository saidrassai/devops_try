# PowerShell deployment script for Windows
# Deploy to EC2 instance i-0e605f03f8a4d2420

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "preprod", "prod")]
    [string]$Environment = "dev"
)

$EC2_IP = "3.86.184.138"
$EC2_USER = "ec2_user"
$KEY_PATH = "C:\Users\PC\Downloads\DevSecOps_jenkins.pem"

Write-Host "🚀 Deploying to EC2 instance i-0e605f03f8a4d2420 ($Environment environment)" -ForegroundColor Green

# Test SSH connectivity
Write-Host "🔍 Testing SSH connectivity..." -ForegroundColor Yellow
try {
    $sshTest = ssh -i $KEY_PATH -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo 'SSH connection successful'"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH connection successful" -ForegroundColor Green
    } else {
        throw "SSH connection failed"
    }
} catch {
    Write-Host "❌ SSH connection failed. Please check:" -ForegroundColor Red
    Write-Host "   - EC2 instance is running" -ForegroundColor Yellow
    Write-Host "   - Security group allows SSH (port 22)" -ForegroundColor Yellow
    Write-Host "   - SSH key path is correct: $KEY_PATH" -ForegroundColor Yellow
    Write-Host "   - Key permissions are 400: chmod 400 $KEY_PATH" -ForegroundColor Yellow
    exit 1
}

# Build Docker image locally
Write-Host "🔨 Building Docker image..." -ForegroundColor Yellow
docker build -f docker/Dockerfile -t devops-sample-app:latest app/

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}

# Save and transfer Docker image
Write-Host "📤 Transferring Docker image to EC2..." -ForegroundColor Yellow
docker save devops-sample-app:latest | gzip > devops-app.tar.gz
scp -i $KEY_PATH devops-app.tar.gz "$EC2_USER@$EC2_IP" + ":/tmp/"

# Transfer configuration files
Write-Host "📁 Transferring configuration files..." -ForegroundColor Yellow
scp -i $KEY_PATH docker/docker-compose.yml "$EC2_USER@$EC2_IP" + ":/opt/devops-app/"
scp -i $KEY_PATH docker/nginx.conf "$EC2_USER@$EC2_IP" + ":/opt/devops-app/"
scp -i $KEY_PATH "environments/$Environment.env" "$EC2_USER@$EC2_IP" + ":/opt/devops-app/.env"

# Install dependencies and deploy
Write-Host "📦 Installing dependencies and deploying..." -ForegroundColor Yellow
$deployScript = @"
# Update system
sudo apt update -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create application directory
sudo mkdir -p /opt/devops-app
sudo chown ubuntu:ubuntu /opt/devops-app

# Load Docker image
cd /tmp
gunzip -c devops-app.tar.gz | docker load
rm devops-app.tar.gz

# Deploy application
cd /opt/devops-app
docker-compose down || true
docker-compose up -d

# Wait for services to start
sleep 15

# Health check
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✅ Application deployed successfully!"
else
    echo "❌ Deployment failed. Checking logs..."
    docker-compose logs
    exit 1
fi
"@

ssh -i $KEY_PATH "$EC2_USER@$EC2_IP" $deployScript

if ($LASTEXITCODE -eq 0) {
    $port = switch ($Environment) {
        "dev" { 80 }
        "preprod" { 8080 }
        "prod" { 9000 }
    }
    
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    Write-Host "🌐 Application is available at: http://$EC2_IP`:$port" -ForegroundColor Cyan
    Write-Host "📊 Health check: http://$EC2_IP`:$port/health" -ForegroundColor Cyan
    Write-Host "🔧 API endpoint: http://$EC2_IP`:$port/api/users" -ForegroundColor Cyan
} else {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    exit 1
}

# Clean up
if (Test-Path "devops-app.tar.gz") {
    Remove-Item "devops-app.tar.gz"
}

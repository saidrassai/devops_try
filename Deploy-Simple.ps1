# Simple deployment script for your EC2 instance
# No Docker Desktop required!

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "preprod", "prod")]
    [string]$Environment = "dev"
)

$EC2_IP = "3.86.184.138"
$EC2_USER = "ubuntu"
$KEY_PATH = "C:\Users\PC\Downloads\DevSecOps_jenkins.pem"

Write-Host "🚀 Deploying DevSecOps Application to EC2" -ForegroundColor Green
Write-Host "Instance: i-0e605f03f8a4d2420 ($EC2_IP)" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow

# Check SSH key
if (-not (Test-Path $KEY_PATH)) {
    Write-Host "❌ SSH key not found at: $KEY_PATH" -ForegroundColor Red
    exit 1
}

Write-Host "✅ SSH key found" -ForegroundColor Green

# Test SSH connection
Write-Host "🔍 Testing SSH connection..." -ForegroundColor Yellow
$sshTest = ssh -i $KEY_PATH -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo 'Connection successful'"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ SSH connection failed!" -ForegroundColor Red
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "1. EC2 instance is running" -ForegroundColor White
    Write-Host "2. Security group allows SSH (port 22)" -ForegroundColor White
    Write-Host "3. SSH key has correct permissions" -ForegroundColor White
    exit 1
}

Write-Host "✅ SSH connection successful" -ForegroundColor Green

# Set environment-specific ports
$ports = @{
    "dev" = @{ app = 3000; nginx = 80 }
    "preprod" = @{ app = 3001; nginx = 8080 }
    "prod" = @{ app = 3002; nginx = 9000 }
}

$currentPorts = $ports[$Environment]

Write-Host "📦 Deploying to $Environment environment..." -ForegroundColor Yellow
Write-Host "App Port: $($currentPorts.app), Nginx Port: $($currentPorts.nginx)" -ForegroundColor Cyan

# Create deployment script for EC2
$deploymentScript = @"
#!/bin/bash
set -e

echo "🔧 Setting up environment on EC2..."

# Update system
sudo apt update -y

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create application directory
sudo mkdir -p /opt/devops-app-$Environment
sudo chown ubuntu:ubuntu /opt/devops-app-$Environment
cd /opt/devops-app-$Environment

# Clone or create application
echo "📁 Setting up application files..."

# Create package.json
cat > package.json << 'PACKAGE_EOF'
{
  "name": "devops-sample-app",
  "version": "1.0.0",
  "description": "Sample Node.js application for DevOps infrastructure demo",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0"
  }
}
PACKAGE_EOF

# Create server.js
cat > server.js << 'SERVER_EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || $($currentPorts.app);
const ENV = process.env.NODE_ENV || '$Environment';

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'DevSecOps Sample Application',
    environment: ENV,
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    hostname: require('os').hostname(),
    port: PORT
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    environment: ENV,
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/api/users', (req, res) => {
  res.json({
    users: [
      { id: 1, name: 'John Doe', environment: ENV },
      { id: 2, name: 'Jane Smith', environment: ENV },
      { id: 3, name: 'Bob Johnson', environment: ENV }
    ]
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port $PORT in $ENV environment`);
});
SERVER_EOF

# Create Dockerfile
cat > Dockerfile << 'DOCKER_EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE $($currentPorts.app)
CMD ["npm", "start"]
DOCKER_EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'
services:
  app:
    build: .
    ports:
      - "$($currentPorts.app):$($currentPorts.app)"
    environment:
      - NODE_ENV=$Environment
      - PORT=$($currentPorts.app)
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "$($currentPorts.nginx):80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app
    restart: unless-stopped
COMPOSE_EOF

# Create nginx.conf
cat > nginx.conf << 'NGINX_EOF'
events {
    worker_connections 1024;
}

http {
    upstream app {
        server app:$($currentPorts.app);
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://app;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }

        location /health {
            access_log off;
            proxy_pass http://app;
        }
    }
}
NGINX_EOF

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm install

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Build and start new containers
echo "🚀 Starting application..."
docker-compose up --build -d

# Wait for application to start
echo "⏳ Waiting for application to start..."
sleep 15

# Health check
echo "🔍 Performing health check..."
if curl -f http://localhost:$($currentPorts.nginx)/health > /dev/null 2>&1; then    echo "✅ Application deployed successfully!"
    echo "🌐 Access URL: http://${EC2_IP}:$($currentPorts.nginx)"
else
    echo "❌ Health check failed. Checking logs..."
    docker-compose logs
    exit 1
fi

echo "🎉 Deployment completed successfully!"
"@

# Write deployment script to temp file
$tempScript = [System.IO.Path]::GetTempFileName() + ".sh"
$deploymentScript | Out-File -FilePath $tempScript -Encoding UTF8

# Copy and execute deployment script on EC2
Write-Host "📤 Transferring deployment script to EC2..." -ForegroundColor Yellow
scp -i $KEY_PATH $tempScript "$EC2_USER@$EC2_IP":/tmp/deploy.sh

Write-Host "🚀 Executing deployment on EC2..." -ForegroundColor Yellow
ssh -i $KEY_PATH "$EC2_USER@$EC2_IP" "chmod +x /tmp/deploy.sh && /tmp/deploy.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🎉 Deployment Successful!" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host "🌐 Application URL: http://$EC2_IP`:$($currentPorts.nginx)" -ForegroundColor Cyan
    Write-Host "📊 Health Check: http://$EC2_IP`:$($currentPorts.nginx)/health" -ForegroundColor Cyan
    Write-Host "🔧 API Endpoint: http://$EC2_IP`:$($currentPorts.nginx)/api/users" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ Your $Environment environment is now running!" -ForegroundColor Green
} else {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
}

# Clean up temp file
Remove-Item $tempScript -Force

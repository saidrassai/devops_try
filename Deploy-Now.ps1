# Ultra-Simple Deployment Script
# Deploy to EC2 without any complex variable handling

param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev"
)

$EC2_IP = "3.86.184.138"
$EC2_USER = "ubuntu"  
$KEY_PATH = "C:\Users\PC\Downloads\DevSecOps_jenkins.pem"

Write-Host "🚀 Deploying to EC2: $EC2_IP" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Yellow

# Test SSH
Write-Host "🔍 Testing connection..." -ForegroundColor Yellow
ssh -i $KEY_PATH -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo 'Connected!'"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Connection failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Connected successfully!" -ForegroundColor Green

# Simple deployment script
$script = @'
#!/bin/bash
set -e

echo "🔧 Setting up on EC2..."

# Update and install essentials
sudo apt update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs docker.io
sudo systemctl start docker
sudo usermod -aG docker ubuntu

# Create app directory
mkdir -p ~/devops-app
cd ~/devops-app

# Create simple Express app
cat > package.json << 'EOF'
{
  "name": "devops-app",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

cat > server.js << 'EOF'
const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'DevSecOps Application Running!',
    environment: 'development',
    timestamp: new Date().toISOString(),
    success: true
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Install and start
npm install
pkill -f "node server.js" || true
nohup node server.js > app.log 2>&1 &

sleep 5

# Test
if curl -f http://localhost:3000/health; then
  echo "✅ App deployed successfully!"
else
  echo "❌ Deployment failed"
  exit 1
fi
'@

# Execute on EC2
Write-Host "🚀 Deploying application..." -ForegroundColor Yellow
$script | ssh -i $KEY_PATH "$EC2_USER@$EC2_IP" "cat > deploy.sh && chmod +x deploy.sh && ./deploy.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🎉 SUCCESS!" -ForegroundColor Green
    Write-Host "🌐 Your app is running at: http://$EC2_IP`:3000" -ForegroundColor Cyan
    Write-Host "📊 Health check: http://$EC2_IP`:3000/health" -ForegroundColor Cyan
} else {
    Write-Host "❌ Deployment failed" -ForegroundColor Red
}

# Alternative deployment using AWS Session Manager
# This bypasses SSH connectivity issues

Write-Host "🚀 DevSecOps Deployment - Alternative Method" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Since SSH connection failed, here are alternative approaches:" -ForegroundColor Yellow
Write-Host ""

Write-Host "📋 Option 1: AWS Session Manager (Recommended)" -ForegroundColor Cyan
Write-Host "----------------------------------------------" -ForegroundColor Cyan
Write-Host "1. Go to AWS Console -> EC2 -> Instances"
Write-Host "2. Select instance i-0e605f03f8a4d2420"
Write-Host "3. Click 'Connect' -> 'Session Manager'"
Write-Host "4. Run these commands:"
Write-Host ""
Write-Host @"
# Update system
sudo apt update -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Create application
mkdir -p ~/devops-app && cd ~/devops-app

# Create package.json
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

# Create server.js
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'DevSecOps Application Running!',
    environment: 'development',
    timestamp: new Date().toISOString(),
    instance: 'i-0e605f03f8a4d2420',
    success: true
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    uptime: process.uptime()
  });
});

app.get('/api/users', (req, res) => {
  res.json({
    users: [
      { id: 1, name: 'DevOps User 1' },
      { id: 2, name: 'DevOps User 2' }
    ]
  });
});

app.listen(PORT, () => {
  console.log('Server running on port 3000');
});
EOF

# Install dependencies and start
npm install
pkill -f "node server.js" || true
nohup node server.js > app.log 2>&1 &

# Verify it's running
sleep 5
curl http://localhost:3000/health

echo "Application deployed! Access at: http://3.86.184.138:3000"
"@ -ForegroundColor White

Write-Host ""
Write-Host "📋 Option 2: Fix SSH Connection" -ForegroundColor Cyan
Write-Host "-------------------------------" -ForegroundColor Cyan
Write-Host "1. Check if EC2 instance is running in AWS Console"
Write-Host "2. Verify Security Group allows SSH (port 22) from your IP"
Write-Host "3. Confirm you have the correct SSH key for this instance"
Write-Host "4. Your current IP might need to be added to security group"

Write-Host ""
Write-Host "📋 Option 3: Open Required Ports" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Cyan
Write-Host "Ensure your Security Group allows these inbound rules:"
Write-Host "- Port 22 (SSH) from your IP"
Write-Host "- Port 3000 (Application) from 0.0.0.0/0"
Write-Host "- Port 80 (HTTP) from 0.0.0.0/0"

Write-Host ""
Write-Host "🎯 Quick Test" -ForegroundColor Green
Write-Host "After deployment, test these URLs:"
Write-Host "🌐 Main App: http://3.86.184.138:3000" -ForegroundColor Cyan
Write-Host "📊 Health: http://3.86.184.138:3000/health" -ForegroundColor Cyan  
Write-Host "🔧 API: http://3.86.184.138:3000/api/users" -ForegroundColor Cyan

Write-Host ""
Write-Host "💡 The Session Manager method is the most reliable!" -ForegroundColor Yellow

#!/bin/bash
# Fix Jenkins npm issue - Install Node.js and npm

echo "🔧 Installing Node.js and npm for Jenkins"
echo "=========================================="

# Update package manager
sudo yum update -y

# Install Node.js 18.x (LTS)
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
echo "📋 Verification:"
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# Install global packages that might be needed
sudo npm install -g pm2

# Set proper permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins/.npm 2>/dev/null || true

echo "✅ Node.js and npm installation completed!"
echo "🔄 Restart Jenkins to apply changes:"
echo "sudo systemctl restart jenkins"

# Optional: Restart Jenkins automatically
read -p "Restart Jenkins now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo systemctl restart jenkins
    echo "✅ Jenkins restarted!"
fi

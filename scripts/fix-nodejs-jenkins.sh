#!/bin/bash
# Fix Jenkins Pipeline - Install Node.js and npm on EC2
# This script installs Node.js 18 LTS and npm for the Jenkins pipeline

echo "🔧 Installing Node.js and npm for Jenkins Pipeline"
echo "================================================="

# Update system packages
echo "📦 Updating system packages..."
sudo yum update -y

# Install Node.js 18 LTS using NodeSource repository
echo "📥 Installing Node.js 18 LTS..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
echo "✅ Verifying installation..."
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# Set npm permissions for jenkins user
echo "🔐 Setting up npm permissions for jenkins user..."
sudo mkdir -p /var/lib/jenkins/.npm
sudo chown jenkins:jenkins /var/lib/jenkins/.npm
sudo chmod 755 /var/lib/jenkins/.npm

# Install global packages that might be needed
echo "🌐 Installing global npm packages..."
sudo npm install -g npm@latest

# Test installation with jenkins user
echo "🧪 Testing npm with jenkins user..."
sudo -u jenkins npm --version

echo ""
echo "✅ Node.js and npm installation completed!"
echo "🔄 You can now re-run the Jenkins pipeline"
echo ""
echo "📊 Installation Summary:"
echo "  - Node.js: $(node --version)"
echo "  - npm: $(npm --version)"
echo "  - Global npm location: $(npm root -g)"
echo ""
echo "🌐 Access your applications:"
echo "  - Development: http://52.91.251.180:3000"
echo "  - Staging: http://52.91.251.180:3001"
echo "  - Jenkins: http://52.91.251.180:8080"

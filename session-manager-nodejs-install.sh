# AWS Session Manager Commands for Jenkins Node.js Fix
# Copy and paste these commands into AWS Session Manager console

echo "🔧 Jenkins Node.js Installation via AWS Session Manager"
echo "======================================================"

# Update system packages
echo "📦 Updating system packages..."
sudo yum update -y

# Install Node.js 18 LTS
echo "📥 Installing Node.js 18 LTS..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify Node.js installation
echo "✅ Verifying Node.js installation..."
node --version
npm --version

# Set up Jenkins npm directory and permissions
echo "🔐 Setting up Jenkins user permissions..."
sudo mkdir -p /var/lib/jenkins/.npm
sudo mkdir -p /var/lib/jenkins/.config
sudo chown -R jenkins:jenkins /var/lib/jenkins/.npm
sudo chown -R jenkins:jenkins /var/lib/jenkins/.config
sudo chmod 755 /var/lib/jenkins/.npm

# Update npm to latest version
echo "🌐 Updating npm to latest version..."
sudo npm install -g npm@latest

# Set npm global directory for Jenkins user
echo "📁 Configuring npm global directory for Jenkins..."
sudo -u jenkins npm config set prefix '/var/lib/jenkins/.npm-global'
echo 'export PATH=/var/lib/jenkins/.npm-global/bin:$PATH' | sudo tee -a /var/lib/jenkins/.bashrc

# Test npm with Jenkins user
echo "🧪 Testing npm with Jenkins user..."
sudo -u jenkins npm --version
sudo -u jenkins node --version

# Install commonly needed global packages
echo "📦 Installing commonly needed global packages..."
sudo -u jenkins npm install -g npm@latest

# Restart Jenkins to reload environment
echo "🔄 Restarting Jenkins service..."
sudo systemctl restart jenkins

# Wait for Jenkins to start
echo "⏳ Waiting for Jenkins to restart..."
sleep 30

# Check Jenkins status
echo "🔍 Checking Jenkins status..."
sudo systemctl status jenkins --no-pager

# Test Node.js availability for Jenkins
echo "🧪 Final verification..."
sudo -u jenkins bash -c 'node --version && npm --version'

echo ""
echo "✅ Node.js and npm installation completed successfully!"
echo ""
echo "📊 Installation Summary:"
echo "========================"
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Jenkins user npm: $(sudo -u jenkins npm --version)"
echo ""
echo "🎯 Next Steps:"
echo "1. Go to Jenkins: http://52.91.251.180:8080"
echo "2. Re-run your pipeline"
echo "3. The pipeline should now work without npm errors"
echo ""
echo "🌐 Your applications will be available at:"
echo "- Development: http://52.91.251.180:3000"
echo "- Staging: http://52.91.251.180:3001"
echo "- Production: http://52.91.251.180:3002"

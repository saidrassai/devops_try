# Fix Jenkins Pipeline - Install Node.js WITHOUT SSH
# Multiple approaches to install Node.js on EC2 instance

Write-Host "🔧 Jenkins Node.js Fix - No SSH Required" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
Write-Host ""

$EC2_IP = "52.91.251.180"
$INSTANCE_ID = "i-0e605f03f8a4d2420"

Write-Host "📋 Target Configuration:" -ForegroundColor Cyan
Write-Host "  - Instance ID: $INSTANCE_ID" -ForegroundColor White
Write-Host "  - Public IP: $EC2_IP" -ForegroundColor White
Write-Host ""

Write-Host "🎯 Available Methods (Choose One):" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Method 1: AWS Session Manager (Recommended)" -ForegroundColor Cyan
Write-Host "----------------------------------------------" -ForegroundColor Cyan
Write-Host "1. Open AWS Console: https://console.aws.amazon.com/ec2/"
Write-Host "2. Navigate to: EC2 > Instances"
Write-Host "3. Select instance: $INSTANCE_ID"
Write-Host "4. Click 'Connect' -> 'Session Manager' -> 'Connect'"
Write-Host "5. Copy and paste these commands:"
Write-Host ""

# Create the installation script for Session Manager
$sessionManagerScript = @"
# Install Node.js 18 LTS for Jenkins
echo "🔧 Installing Node.js 18 LTS..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
echo "✅ Verifying installation..."
node --version
npm --version

# Set up Jenkins npm permissions
echo "🔐 Setting up Jenkins permissions..."
sudo mkdir -p /var/lib/jenkins/.npm
sudo chown jenkins:jenkins /var/lib/jenkins/.npm
sudo chmod 755 /var/lib/jenkins/.npm

# Update npm to latest
echo "🌐 Updating npm..."
sudo npm install -g npm@latest

# Test with Jenkins user
echo "🧪 Testing with Jenkins user..."
sudo -u jenkins npm --version

echo ""
echo "✅ Node.js installation completed!"
echo "🔄 You can now re-run the Jenkins pipeline"
echo ""
echo "📊 Installation Summary:"
echo "  - Node.js: `$(node --version)`"
echo "  - npm: `$(npm --version)`"
echo ""
"@

Write-Host $sessionManagerScript -ForegroundColor Gray
Write-Host ""

Write-Host "Method 2: AWS CLI + SSM (Advanced)" -ForegroundColor Cyan
Write-Host "------------------------------------" -ForegroundColor Cyan
Write-Host "If you have AWS CLI configured with SSM permissions:"
Write-Host ""

Write-Host "aws ssm send-command --instance-ids $INSTANCE_ID --document-name AWS-RunShellScript --parameters commands=['curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -','sudo yum install -y nodejs']" -ForegroundColor Gray
Write-Host ""

Write-Host "Method 3: EC2 User Data (For Future Instances)" -ForegroundColor Cyan
Write-Host "------------------------------------------------" -ForegroundColor Cyan
Write-Host "Add this to EC2 User Data when launching new instances:"
Write-Host ""

$userDataScript = @"
#!/bin/bash
# Auto-install Node.js during instance launch
yum update -y
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs
mkdir -p /var/lib/jenkins/.npm
chown jenkins:jenkins /var/lib/jenkins/.npm
npm install -g npm@latest
"@

Write-Host $userDataScript -ForegroundColor Gray
Write-Host ""

Write-Host "Method 4: Via Jenkins Pipeline (Self-Fix)" -ForegroundColor Cyan
Write-Host "-------------------------------------------" -ForegroundColor Cyan
Write-Host "Modify Jenkinsfile to install Node.js automatically:"
Write-Host ""

$jenkinsfileScript = @"
pipeline {
    agent any
    stages {
        stage('Install Node.js') {
            steps {
                script {
                    // Check if Node.js is installed
                    def nodeExists = sh(script: 'which node', returnStatus: true) == 0
                    if (!nodeExists) {
                        echo 'Installing Node.js...'
                        sh '''
                            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                            sudo yum install -y nodejs
                            sudo mkdir -p /var/lib/jenkins/.npm
                            sudo chown jenkins:jenkins /var/lib/jenkins/.npm
                            sudo npm install -g npm@latest
                        '''
                    }
                }
            }
        }
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm test'
            }
        }
        // ... rest of your pipeline
    }
}
"@

Write-Host $jenkinsfileScript -ForegroundColor Gray
Write-Host ""

Write-Host "🎯 Recommended Action Plan:" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host "1. ✅ Use Method 1 (Session Manager) for immediate fix"
Write-Host "2. 🔄 Re-run Jenkins pipeline to test"
Write-Host "3. 📝 Consider Method 4 for future automation"
Write-Host ""

Write-Host "💡 Pro Tips:" -ForegroundColor Yellow
Write-Host "- Session Manager doesn't require SSH keys or security group changes"
Write-Host "- The installation will persist across reboots"
Write-Host "- Jenkins user will have proper npm permissions"
Write-Host ""

Write-Host "🌐 After installation, test your Jenkins pipeline at:" -ForegroundColor Cyan
Write-Host "http://$EC2_IP`:8080" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to continue..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

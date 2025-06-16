# Fix Jenkins Pipeline - Install Node.js and npm on EC2
# PowerShell script to remotely install Node.js on EC2 via SSH

param(
    [string]$KeyPath = "C:\Users\PC\Downloads\DevSecOps_jenkins.pem",
    [string]$EC2_IP = "52.91.251.180",
    [string]$EC2_User = "ec2-user"
)

Write-Host "🔧 Jenkins Pipeline Fix - Installing Node.js" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "📋 Configuration:" -ForegroundColor Cyan
Write-Host "  - EC2 IP: $EC2_IP" -ForegroundColor White
Write-Host "  - User: $EC2_User" -ForegroundColor White
Write-Host "  - Key: $KeyPath" -ForegroundColor White
Write-Host ""

# Test SSH connection first
Write-Host "🔗 Testing SSH connection..." -ForegroundColor Yellow
try {
    $testResult = ssh -i "$KeyPath" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_User@$EC2_IP" "echo 'SSH connection successful'" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH connection successful" -ForegroundColor Green
    } else {
        Write-Host "❌ SSH connection failed" -ForegroundColor Red
        Write-Host "💡 Please check your key permissions and network connectivity" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ SSH connection error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📦 Installing Node.js and npm..." -ForegroundColor Yellow

# Create and execute the installation script remotely
$installScript = @"
#!/bin/bash
echo '📥 Installing Node.js 18 LTS...'
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

echo '✅ Verifying installation...'
node --version
npm --version

echo '🔐 Setting up npm permissions for jenkins user...'
sudo mkdir -p /var/lib/jenkins/.npm
sudo chown jenkins:jenkins /var/lib/jenkins/.npm
sudo chmod 755 /var/lib/jenkins/.npm

echo '🌐 Installing global npm packages...'
sudo npm install -g npm@latest

echo '🧪 Testing npm with jenkins user...'
sudo -u jenkins npm --version

echo '✅ Installation completed!'
"@

# Execute the script remotely
Write-Host "🚀 Executing installation on EC2..." -ForegroundColor Yellow
ssh -i "$KeyPath" -o StrictHostKeyChecking=no "$EC2_User@$EC2_IP" "$installScript"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Node.js and npm installation completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔄 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Go to Jenkins: http://$EC2_IP:8080" -ForegroundColor White
    Write-Host "2. Re-run your pipeline (it should now work)" -ForegroundColor White
    Write-Host "3. Check the build logs for success" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 Your applications:" -ForegroundColor Cyan
    Write-Host "  - Development: http://$EC2_IP:3000" -ForegroundColor White
    Write-Host "  - Staging: http://$EC2_IP:3001" -ForegroundColor White
    Write-Host "  - Jenkins: http://$EC2_IP:8080" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Installation failed" -ForegroundColor Red
    Write-Host "💡 Please check the error messages above" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# PowerShell script to fix Jenkins pipeline by installing Node.js and npm
# Fix for: npm: command not found error in Jenkins build

Write-Host "🔧 Jenkins Pipeline Fix - Installing Node.js and npm" -ForegroundColor Yellow
Write-Host "======================================================" -ForegroundColor Yellow

# Configuration
$EC2_IP = "52.91.251.180"
$KEY_PATH = "C:\Users\PC\Downloads\DevSecOps_jenkins.pem"
$EC2_USER = "ubuntu"

Write-Host ""
Write-Host "📋 Issue: Jenkins pipeline failing due to missing npm" -ForegroundColor Red
Write-Host "💡 Solution: Install Node.js and npm on EC2 instance" -ForegroundColor Green
Write-Host ""

# Test SSH connection first
Write-Host "🔍 Testing SSH connection..." -ForegroundColor Cyan

$testResult = ssh -i $KEY_PATH -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo 'SSH connection successful'" 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ SSH connection successful" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "📦 Installing Node.js and npm..." -ForegroundColor Cyan
    
    # Install Node.js
    $installCommand = "curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs && echo 'Node.js version:' && node --version && echo 'npm version:' && npm --version"
    
    ssh -i $KEY_PATH -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" $installCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Node.js and npm installed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Go to Jenkins: http://$EC2_IP`:8080" -ForegroundColor White
        Write-Host "2. Run your pipeline again" -ForegroundColor White
        Write-Host "3. The npm build should now work!" -ForegroundColor White
    } else {
        Write-Host "❌ Installation failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ SSH connection failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Manual installation steps:" -ForegroundColor Yellow
    Write-Host "1. SSH to your EC2 instance manually" -ForegroundColor White
    Write-Host "2. Run: curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -" -ForegroundColor Gray
    Write-Host "3. Run: sudo apt-get install -y nodejs" -ForegroundColor Gray
    Write-Host "4. Verify: node --version; npm --version" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📊 Current Jenkins Status:" -ForegroundColor Cyan
Write-Host "   Jenkins URL: http://$EC2_IP`:8080" -ForegroundColor White
Write-Host "   Applications running: devops-dev (port 3000), devops-staging (port 3001)" -ForegroundColor White

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

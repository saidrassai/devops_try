# Debug SSH connection

$EC2_IP = "52.91.251.180"
$KEY_PATH = "C:\Users\PC\Downloads\DevSecOps_jenkins.pem"

Write-Host "🔍 Debugging SSH connection to EC2" -ForegroundColor Yellow
Write-Host "IP: $EC2_IP" -ForegroundColor White
Write-Host "Key: $KEY_PATH" -ForegroundColor White

# Check if key file exists
if (Test-Path $KEY_PATH) {
    Write-Host "✅ SSH key file exists" -ForegroundColor Green
} else {
    Write-Host "❌ SSH key file not found!" -ForegroundColor Red
    exit 1
}

# Show key permissions
Write-Host "📋 Key file permissions:" -ForegroundColor Yellow
icacls $KEY_PATH

Write-Host ""
Write-Host "🔍 Testing different connection methods..." -ForegroundColor Yellow

# Try with ubuntu user
Write-Host "Trying with ubuntu user..." -ForegroundColor Cyan
ssh -i $KEY_PATH -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@$EC2_IP "whoami"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Connection successful with ubuntu user!" -ForegroundColor Green
    exit 0
}

# Try with ec2-user
Write-Host "Trying with ec2-user..." -ForegroundColor Cyan
ssh -i $KEY_PATH -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@$EC2_IP "whoami"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Connection successful with ec2-user!" -ForegroundColor Green
    exit 0
}

# Try with admin
Write-Host "Trying with admin user..." -ForegroundColor Cyan
ssh -i $KEY_PATH -o ConnectTimeout=10 -o StrictHostKeyChecking=no admin@$EC2_IP "whoami"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Connection successful with admin user!" -ForegroundColor Green
    exit 0
}

Write-Host "❌ All connection attempts failed!" -ForegroundColor Red
Write-Host ""
Write-Host "💡 Troubleshooting tips:" -ForegroundColor Yellow
Write-Host "1. Check if EC2 instance is running" -ForegroundColor White
Write-Host "2. Verify security group allows SSH (port 22) from your IP" -ForegroundColor White
Write-Host "3. Confirm this is the correct SSH key for the instance" -ForegroundColor White
Write-Host "4. Try connecting from AWS Console using Session Manager" -ForegroundColor White

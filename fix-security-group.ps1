# Fix Security Group for Jenkins Access
# This script updates the security group to allow port 8080 access

Write-Host "🔒 Security Group Fix for Jenkins Access" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Instance details
$INSTANCE_ID = "i-0e605f03f8a4d2420"

Write-Host ""
Write-Host "📋 Current Issue: Port 8080 restricted to specific IP" -ForegroundColor Red
Write-Host "💡 Solution: Update security group rule for Jenkins access" -ForegroundColor Green
Write-Host ""

Write-Host "🔧 To fix this issue manually in AWS Console:" -ForegroundColor Cyan
Write-Host "1. Go to EC2 Console → Security Groups" -ForegroundColor White
Write-Host "2. Find the security group for instance: $INSTANCE_ID" -ForegroundColor White
Write-Host "3. Edit inbound rules" -ForegroundColor White
Write-Host "4. Update the rule for port 8080:" -ForegroundColor White
Write-Host "   - Type: Custom TCP" -ForegroundColor Gray
Write-Host "   - Port: 8080" -ForegroundColor Gray
Write-Host "   - Source: 0.0.0.0/0 (for testing)" -ForegroundColor Gray
Write-Host "   - Description: Jenkins Web UI" -ForegroundColor Gray
Write-Host "5. Save rules" -ForegroundColor White

Write-Host ""
Write-Host "⚠️  SECURITY NOTE:" -ForegroundColor Yellow
Write-Host "   Opening port 8080 to 0.0.0.0/0 allows access from anywhere." -ForegroundColor Yellow
Write-Host "   After testing, restrict to your IP for better security." -ForegroundColor Yellow

Write-Host ""
Write-Host "🌐 After fixing, Jenkins will be accessible at:" -ForegroundColor Green
Write-Host "   http://52.91.251.180:8080" -ForegroundColor White

Write-Host ""
Write-Host "✅ Alternative: Use AWS CLI to fix (if configured):" -ForegroundColor Cyan
Write-Host 'aws ec2 authorize-security-group-ingress --group-id <SG-ID> --protocol tcp --port 8080 --cidr 0.0.0.0/0' -ForegroundColor Gray

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
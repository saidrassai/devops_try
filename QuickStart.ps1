# Quick Start - DevSecOps Infrastructure
# Execute this PowerShell script for immediate deployment

Write-Host "🚀 DevSecOps Infrastructure - Quick Start" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

$EC2_IP = "3.86.184.138"
$INSTANCE_ID = "i-0e605f03f8a4d2420"

Write-Host ""
Write-Host "📋 Instance Details:" -ForegroundColor Yellow
Write-Host "   Instance ID: $INSTANCE_ID" -ForegroundColor White
Write-Host "   Public IP: $EC2_IP" -ForegroundColor White
Write-Host "   Private IP: 172.31.93.22" -ForegroundColor White

Write-Host ""
Write-Host "🔧 Step 1: Checking Docker..." -ForegroundColor Yellow

# Check if Docker is running
$dockerRunning = $false
try {
    docker version 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $dockerRunning = $true
        Write-Host "✅ Docker is running" -ForegroundColor Green
    }
} catch {
    $dockerRunning = $false
}

if (-not $dockerRunning) {
    Write-Host "⚠️  Docker is not running locally" -ForegroundColor Yellow
    Write-Host "📋 Choose deployment method:" -ForegroundColor Yellow
    Write-Host "   1. Start Docker Desktop and try again" -ForegroundColor White
    Write-Host "   2. Deploy directly on EC2 (recommended)" -ForegroundColor White
    
    $dockerChoice = Read-Host "Enter your choice (1-2)"
    
    if ($dockerChoice -eq "1") {
        Write-Host "🔄 Please start Docker Desktop and run this script again" -ForegroundColor Yellow
        Write-Host "💡 Tip: Open Docker Desktop and wait for it to fully start" -ForegroundColor Cyan
        exit 0
    } elseif ($dockerChoice -eq "2") {
        Write-Host "🚀 Proceeding with EC2-based deployment..." -ForegroundColor Green
        $deployOnEC2 = $true
    } else {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "🔨 Building Docker image locally..." -ForegroundColor Yellow
    docker build -f docker/Dockerfile -t devops-sample-app:latest app/
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker image built successfully" -ForegroundColor Green
        $deployOnEC2 = $false
    } else {
        Write-Host "❌ Docker build failed, switching to EC2 deployment" -ForegroundColor Yellow
        $deployOnEC2 = $true
    }
}

Write-Host ""
Write-Host "🚀 Step 2: Choose deployment environment:" -ForegroundColor Yellow
Write-Host "   1. Development (port 80)" -ForegroundColor White
Write-Host "   2. Preproduction (port 8080)" -ForegroundColor White
Write-Host "   3. Production (port 9000)" -ForegroundColor White
Write-Host "   4. Deploy to all environments" -ForegroundColor White

$choice = Read-Host "Enter your choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host "🚀 Deploying to Development..." -ForegroundColor Green
        if ($deployOnEC2) {
            .\scripts\Deploy-Direct-EC2.ps1 -Environment dev
        } else {
            .\scripts\Deploy-ToEC2.ps1 -Environment dev
        }
        Write-Host "🌐 Access at: http://$EC2_IP" -ForegroundColor Cyan
    }
    "2" {
        Write-Host "🚀 Deploying to Preproduction..." -ForegroundColor Green
        if ($deployOnEC2) {
            .\scripts\Deploy-Direct-EC2.ps1 -Environment preprod
        } else {
            .\scripts\Deploy-ToEC2.ps1 -Environment preprod
        }
        Write-Host "🌐 Access at: http://$EC2_IP`:8080" -ForegroundColor Cyan
    }
    "3" {
        Write-Host "🚀 Deploying to Production..." -ForegroundColor Green
        if ($deployOnEC2) {
            .\scripts\Deploy-Direct-EC2.ps1 -Environment prod
        } else {
            .\scripts\Deploy-ToEC2.ps1 -Environment prod
        }
        Write-Host "🌐 Access at: http://$EC2_IP`:9000" -ForegroundColor Cyan
    }
    "4" {
        Write-Host "🚀 Deploying to all environments..." -ForegroundColor Green
        if ($deployOnEC2) {
            .\scripts\Deploy-Direct-EC2.ps1 -Environment dev
            .\scripts\Deploy-Direct-EC2.ps1 -Environment preprod
            .\scripts\Deploy-Direct-EC2.ps1 -Environment prod
        } else {
            .\scripts\Deploy-ToEC2.ps1 -Environment dev
            .\scripts\Deploy-ToEC2.ps1 -Environment preprod
            .\scripts\Deploy-ToEC2.ps1 -Environment prod
        }
        Write-Host "🌐 Access URLs:" -ForegroundColor Cyan
        Write-Host "   Development: http://$EC2_IP" -ForegroundColor White
        Write-Host "   Preproduction: http://$EC2_IP`:8080" -ForegroundColor White
        Write-Host "   Production: http://$EC2_IP`:9000" -ForegroundColor White
    }
    default {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "📊 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Set up Jenkins: Run scripts/setup-jenkins.sh on EC2" -ForegroundColor White
Write-Host "   2. Configure CI/CD pipeline in Jenkins" -ForegroundColor White
Write-Host "   3. Test infrastructure: Run scripts/test-infrastructure.sh" -ForegroundColor White
Write-Host "   4. Monitor applications via health endpoints" -ForegroundColor White

Write-Host ""
Write-Host "✅ Quick start completed successfully!" -ForegroundColor Green

# SSH Key Setup Helper for Windows
# This script helps you set up the SSH key for EC2 access

Write-Host "🔑 SSH Key Setup Helper" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green

$keyPath = "$env:USERPROFILE\.ssh\devops-key.pem"
$sshDir = "$env:USERPROFILE\.ssh"

# Create .ssh directory if it doesn't exist
if (-not (Test-Path $sshDir)) {
    Write-Host "📁 Creating .ssh directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    Write-Host "✅ .ssh directory created" -ForegroundColor Green
}

Write-Host ""
Write-Host "📋 SSH Key Setup Options:" -ForegroundColor Yellow
Write-Host "   1. I have the key file and want to copy it" -ForegroundColor White
Write-Host "   2. I need to download the key from AWS Console" -ForegroundColor White
Write-Host "   3. My key is already in place" -ForegroundColor White

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host "📁 Please select your EC2 key file..." -ForegroundColor Yellow
        
        # Use Windows file dialog
        Add-Type -AssemblyName System.Windows.Forms
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.Title = "Select EC2 Key File"
        $fileDialog.Filter = "PEM files (*.pem)|*.pem|All files (*.*)|*.*"
        $fileDialog.InitialDirectory = $env:USERPROFILE
        
        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $sourceKey = $fileDialog.FileName
            
            Write-Host "📋 Copying key file..." -ForegroundColor Yellow
            Copy-Item -Path $sourceKey -Destination $keyPath -Force
            
            Write-Host "✅ Key file copied to: $keyPath" -ForegroundColor Green
        } else {
            Write-Host "❌ No file selected" -ForegroundColor Red
            exit 1
        }
    }
    "2" {
        Write-Host "💡 To download your EC2 key:" -ForegroundColor Yellow
        Write-Host "   1. Go to AWS Console → EC2 → Key Pairs" -ForegroundColor White
        Write-Host "   2. Find your key pair for the instance" -ForegroundColor White
        Write-Host "   3. If you don't have it, create a new key pair" -ForegroundColor White
        Write-Host "   4. Download the .pem file" -ForegroundColor White
        Write-Host "   5. Save it as: $keyPath" -ForegroundColor White
        Write-Host ""        Write-Host "📁 Expected key location: $keyPath" -ForegroundColor Cyan
        
        Read-Host "Press Enter when you have placed the key file at the expected location" | Out-Null
    }
    "3" {
        Write-Host "🔍 Checking existing key..." -ForegroundColor Yellow
        if (Test-Path $keyPath) {
            Write-Host "✅ Key file found at: $keyPath" -ForegroundColor Green
        } else {
            Write-Host "❌ Key file not found at: $keyPath" -ForegroundColor Red
            Write-Host "💡 Please choose option 1 or 2 to set up the key" -ForegroundColor Yellow
            exit 1
        }
    }
    default {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        exit 1
    }
}

# Set proper permissions on the key file
if (Test-Path $keyPath) {
    Write-Host "🔒 Setting proper permissions on key file..." -ForegroundColor Yellow
    
    # Set proper Windows permissions (equivalent to chmod 400)
    $acl = Get-Acl $keyPath
    $acl.SetAccessRuleProtection($true, $false)  # Remove inheritance
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $keyPath -AclObject $acl
    
    Write-Host "✅ Permissions set correctly" -ForegroundColor Green
    
    # Test SSH connection
    Write-Host ""
    Write-Host "🧪 Testing SSH connection to EC2..." -ForegroundColor Yellow
    $EC2_IP = "3.86.184.138"
    
    try {
        ssh -i $keyPath -o ConnectTimeout=10 -o StrictHostKeyChecking=no "ubuntu@$EC2_IP" "echo 'SSH test successful'" 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ SSH connection successful!" -ForegroundColor Green
            Write-Host ""
            Write-Host "🚀 You're ready to deploy! Run:" -ForegroundColor Cyan
            Write-Host "   .\QuickStart.ps1" -ForegroundColor White
        } else {
            Write-Host "⚠️  SSH connection failed" -ForegroundColor Yellow
            Write-Host "📋 Possible issues:" -ForegroundColor Yellow
            Write-Host "   - EC2 instance might be stopped" -ForegroundColor White
            Write-Host "   - Security group doesn't allow SSH from your IP" -ForegroundColor White
            Write-Host "   - Wrong key file" -ForegroundColor White
        }
    } catch {
        Write-Host "⚠️  Could not test SSH (ssh command not found)" -ForegroundColor Yellow
        Write-Host "💡 You can still try the deployment" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ Key file setup failed" -ForegroundColor Red
}

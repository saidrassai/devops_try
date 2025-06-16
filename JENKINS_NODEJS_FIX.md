# Jenkins Pipeline Fix - Node.js Installation

## 🎯 Issue Summary
The Jenkins pipeline was failing with the error:
```
npm: command not found
```

This happened because Node.js and npm were not installed on the EC2 instance where Jenkins is running.

## 🔧 Solution
Install Node.js 18 LTS and npm on the EC2 instance to enable the Jenkins pipeline to build the Node.js application.

## 📋 Current Status
- ✅ Jenkins is running on port 8080
- ✅ Applications are deployed and running:
  - Development: http://52.91.251.180:3000
  - Staging: http://52.91.251.180:3001
- ❌ Jenkins pipeline fails at build stage (npm missing)

## 🚀 Quick Fix

### Option 1: PowerShell Script (Recommended)
Run the PowerShell script from Windows:
```powershell
.\Fix-Jenkins-NodeJS.ps1
```

### Option 2: Manual SSH Command
```powershell
ssh -i "C:\Users\PC\Downloads\DevSecOps_jenkins.pem" ec2-user@52.91.251.180
```

Then run these commands on the EC2 instance:
```bash
# Install Node.js 18 LTS
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
node --version
npm --version

# Set permissions for Jenkins user
sudo mkdir -p /var/lib/jenkins/.npm
sudo chown jenkins:jenkins /var/lib/jenkins/.npm
sudo chmod 755 /var/lib/jenkins/.npm

# Update npm
sudo npm install -g npm@latest

# Test with Jenkins user
sudo -u jenkins npm --version
```

## ✅ Verification Steps

1. **Check Node.js installation:**
   ```bash
   node --version  # Should show v18.x.x
   npm --version   # Should show 9.x.x or higher
   ```

2. **Test Jenkins pipeline:**
   - Go to http://52.91.251.180:8080
   - Re-run the pipeline job
   - Check build logs for success

3. **Verify applications:**
   - Development: http://52.91.251.180:3000
   - Staging: http://52.91.251.180:3001

## 📊 Expected Pipeline Flow After Fix

```
✅ Checkout ➜ ✅ Build (npm install) ➜ ✅ Test ➜ ✅ Docker Build ➜ ✅ Deploy
```

## 🎉 Success Indicators

- Pipeline shows "SUCCESS" status
- Build logs show npm commands executing
- All stages complete without errors
- Applications accessible on all ports

## 🔍 Troubleshooting

### If SSH fails:
- Check key permissions: `icacls "DevSecOps_jenkins.pem"`
- Verify security group allows SSH (port 22)
- Try with `ubuntu` user instead of `ec2-user`

### If npm still not found:
- Restart Jenkins: `sudo systemctl restart jenkins`
- Check Jenkins user environment: `sudo -u jenkins which npm`
- Verify PATH includes npm: `sudo -u jenkins echo $PATH`

## 📁 Related Files
- `Fix-Jenkins-NodeJS.ps1` - PowerShell fix script
- `scripts/fix-nodejs-jenkins.sh` - Bash fix script
- `Jenkinsfile` - Pipeline configuration
- `app/package.json` - Node.js application dependencies

# Jenkins Node.js Fix Documentation
# Multiple approaches to install Node.js without SSH

## 🎯 Problem
Jenkins pipeline fails with "npm: command not found" because Node.js/npm is not installed on the EC2 Jenkins server.

## 🔧 Solutions (No SSH Required)

### Option 1: AWS Session Manager (Recommended) ⭐

**Steps:**
1. Open AWS Console: https://console.aws.amazon.com/ec2/
2. Navigate to: EC2 → Instances
3. Select instance: `i-0e605f03f8a4d2420`
4. Click **Connect** → **Session Manager** → **Connect**
5. Copy and run the script from `session-manager-nodejs-install.sh`

**Advantages:**
- ✅ No SSH setup required
- ✅ No security group changes needed
- ✅ Works instantly
- ✅ Secure and AWS-managed

### Option 2: Self-Healing Jenkins Pipeline

**Steps:**
1. Replace current `Jenkinsfile` with `Jenkinsfile-auto-fix`
2. Re-run the pipeline

**How it works:**
- Pipeline automatically detects missing Node.js
- Installs Node.js 18 LTS if not found
- Sets up proper Jenkins permissions
- Continues with normal build process

### Option 3: AWS CLI + Systems Manager

**Prerequisites:** AWS CLI configured with SSM permissions

```powershell
aws ssm send-command \
    --instance-ids "i-0e605f03f8a4d2420" \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -","sudo yum install -y nodejs","sudo mkdir -p /var/lib/jenkins/.npm","sudo chown jenkins:jenkins /var/lib/jenkins/.npm"]'
```

### Option 4: EC2 User Data (Future Instances)

Add this to EC2 User Data when launching new instances:

```bash
#!/bin/bash
yum update -y
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs
mkdir -p /var/lib/jenkins/.npm
chown jenkins:jenkins /var/lib/jenkins/.npm
```

## 🚀 Quick Action Plan

### Immediate Fix (5 minutes)
1. Use **Option 1** (Session Manager)
2. Copy commands from `session-manager-nodejs-install.sh`
3. Paste into Session Manager console
4. Wait for completion

### Test the Fix
1. Go to Jenkins: http://52.91.251.180:8080
2. Re-run the pipeline
3. Verify no more "npm: command not found" errors

### Expected Results
- ✅ Development app: http://52.91.251.180:3000
- ✅ Staging app: http://52.91.251.180:3001  
- ✅ Production app: http://52.91.251.180:3002
- ✅ Jenkins pipeline successful

## 🛠️ Files Created

| File | Purpose |
|------|---------|
| `Fix-Jenkins-NodeJS-NoSSH.ps1` | PowerShell guide with all options |
| `session-manager-nodejs-install.sh` | Session Manager installation script |
| `Jenkinsfile-auto-fix` | Self-healing Jenkins pipeline |

## 💡 Pro Tips

1. **Session Manager** is the fastest and most reliable method
2. **Auto-fix pipeline** prevents future issues
3. Installation persists across EC2 reboots
4. Jenkins gets proper npm permissions automatically

## 🔍 Troubleshooting

If Session Manager doesn't work:
- Check if EC2 instance has `AmazonSSMManagedInstanceCore` role
- Verify instance is running Amazon Linux 2
- Try the auto-fix Jenkinsfile approach instead

## ✅ Success Verification

After installation, verify:
```bash
node --version    # Should show v18.x.x
npm --version     # Should show latest npm
sudo -u jenkins npm --version  # Should work without errors
```

## 🎉 Final Result

Your complete DevSecOps infrastructure will be running:
- ✅ Multi-environment deployment (dev/staging/prod)
- ✅ Automated CI/CD pipeline
- ✅ Health monitoring endpoints
- ✅ Manual approval gates for production
- ✅ Containerized applications
- ✅ Professional DevOps setup

**Access your infrastructure:**
- Jenkins Dashboard: http://52.91.251.180:8080
- Development: http://52.91.251.180:3000
- Staging: http://52.91.251.180:3001
- Production: http://52.91.251.180:3002

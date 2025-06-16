# DevSecOps Deployment Guide

## EC2 Instance Details
- **Instance ID**: i-0e605f03f8a4d2420 (DevSecops_Project)
- **Public IP**: 3.86.184.138
- **Private IP**: 172.31.93.22
- **Environment**: Multi-environment setup (dev/preprod/prod)

## Quick Start (1 Hour Setup)

### Step 1: Prerequisites Setup (10 minutes)
```powershell
# On your local Windows machine
# 1. Ensure you have your EC2 SSH key ready
# 2. Install required tools if not present:
#    - Docker Desktop
#    - Git
#    - SSH client

# Set up SSH key (replace with your actual key path)
$keyPath = "C:\path\to\your\devops-key.pem"
# Ensure proper permissions on Windows
icacls $keyPath /inheritance:r
icacls $keyPath /grant:r "$($env:USERNAME):(R)"
```

### Step 2: Deploy Application (15 minutes)
```powershell
# Navigate to project directory
cd "C:\Users\PC\Desktop\devops_try"

# Deploy to development environment
.\scripts\Deploy-ToEC2.ps1 -Environment dev

# Or deploy to other environments
.\scripts\Deploy-ToEC2.ps1 -Environment preprod
.\scripts\Deploy-ToEC2.ps1 -Environment prod
```

### Step 3: Setup Jenkins CI/CD (20 minutes)
```bash
# SSH to your EC2 instance
ssh -i ~/.ssh/devops-key.pem ubuntu@3.86.184.138

# Run Jenkins setup script
curl -sSL https://raw.githubusercontent.com/saidrassai/devops_try/main/scripts/setup-jenkins.sh | bash

# Access Jenkins at: http://3.86.184.138:8080
```

### Step 4: Configure Jenkins Pipeline (10 minutes)
1. Access Jenkins: `http://3.86.184.138:8080`
2. Get initial password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
3. Install suggested plugins
4. Create admin user
5. Create new Pipeline job:
   - Source: GitHub repository
   - Script Path: `Jenkinsfile`

### Step 5: Test and Verify (5 minutes)
```bash
# Test each environment
curl http://3.86.184.138/health          # Development
curl http://3.86.184.138:8080/health     # Preproduction  
curl http://3.86.184.138:9000/health     # Production
```

## Environment Access URLs

### Development Environment
- **Application**: http://3.86.184.138
- **Health Check**: http://3.86.184.138/health
- **API**: http://3.86.184.138/api/users

### Preproduction Environment
- **Application**: http://3.86.184.138:8080
- **Health Check**: http://3.86.184.138:8080/health
- **API**: http://3.86.184.138:8080/api/users

### Production Environment
- **Application**: http://3.86.184.138:9000
- **Health Check**: http://3.86.184.138:9000/health
- **API**: http://3.86.184.138:9000/api/users

### Jenkins
- **URL**: http://3.86.184.138:8080
- **Blue Ocean**: http://3.86.184.138:8080/blue

## Security Group Configuration

Ensure your EC2 security group allows these ports:
- **22** (SSH) - Source: Your IP
- **80** (HTTP - Dev) - Source: 0.0.0.0/0
- **8080** (Jenkins/Preprod) - Source: 0.0.0.0/0
- **9000** (Production) - Source: 0.0.0.0/0

## Troubleshooting

### Common Issues
1. **SSH Connection Failed**
   ```bash
   # Check key permissions
   chmod 400 ~/.ssh/devops-key.pem
   
   # Test connection
   ssh -i ~/.ssh/devops-key.pem ubuntu@3.86.184.138
   ```

2. **Docker Build Failed**
   ```bash
   # Ensure Docker is running
   docker --version
   
   # Check Docker daemon
   docker ps
   ```

3. **Application Not Accessible**
   ```bash
   # Check if containers are running
   ssh -i ~/.ssh/devops-key.pem ubuntu@3.86.184.138 "docker ps"
   
   # Check logs
   ssh -i ~/.ssh/devops-key.pem ubuntu@3.86.184.138 "cd /opt/devops-app && docker-compose logs"
   ```

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Development   │    │  Preproduction  │    │   Production    │
│    Port: 80     │    │   Port: 8080    │    │   Port: 9000    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────────┐
                    │     Jenkins CI/CD   │
                    │     Port: 8080      │
                    └─────────────────────┘
                                 │
                    ┌─────────────────────┐
                    │    EC2 Instance     │
                    │  3.86.184.138       │
                    │ i-0e605f03f8a4d2420 │
                    └─────────────────────┘
```

## Next Steps
1. Set up monitoring with CloudWatch
2. Configure SSL/TLS certificates
3. Implement log aggregation
4. Set up backup strategies
5. Configure auto-scaling

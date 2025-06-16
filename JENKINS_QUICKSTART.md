# Quick Jenkins Pipeline Setup for DevSecOps

## 🎯 Access Jenkins
**Jenkins URL**: http://52.91.251.180:8080/

## 📋 Step-by-Step Setup

### Step 1: Access Jenkins
1. Open browser and go to: http://52.91.251.180:8080/
2. If this is first time, get admin password from EC2:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

### Step 2: Create Pipeline Job
1. Click **"New Item"**
2. Enter name: **`devops-pipeline`**
3. Select **"Pipeline"**
4. Click **"OK"**

### Step 3: Configure Pipeline
In the job configuration:

**General Section:**
- ✅ Check "GitHub project" 
- Project URL: `https://github.com/saidrassai/devops_try/`

**Build Triggers:**
- ✅ Check "Poll SCM"
- Schedule: `H/5 * * * *` (checks every 5 minutes)

**Pipeline Section:**
- Definition: **"Pipeline script from SCM"**
- SCM: **Git**
- Repository URL: `https://github.com/saidrassai/devops_try.git`
- Branch Specifier: `*/main`
- Script Path: `Jenkinsfile`

### Step 4: Save and Build
1. Click **"Save"**
2. Click **"Build Now"**

## 🚀 What the Pipeline Does

### Automatic Deployment Flow:
1. **Checkout** → Downloads code from GitHub
2. **Build** → Installs Node.js dependencies  
3. **Test** → Runs application tests
4. **Docker Build** → Creates container image
5. **Deploy Dev** → Automatically deploys to development (port 3000)
6. **Deploy Staging** → Deploys to staging (port 3001) on main branch
7. **Approval Gate** → Manual approval required for production
8. **Deploy Prod** → Deploys to production (port 3002) after approval

### Environment URLs After Pipeline:
- **Development**: http://52.91.251.180:3000
- **Staging**: http://52.91.251.180:3001  
- **Production**: http://52.91.251.180:3002
- **Jenkins Dashboard**: http://52.91.251.180:8080

## 🔧 Required Jenkins Plugins

If not already installed, install these via **Manage Jenkins → Manage Plugins**:
- Pipeline
- Git Plugin  
- Docker Pipeline
- Blue Ocean (optional)

## 🎯 Testing the Pipeline

1. **Trigger Build**: Click "Build Now" in Jenkins
2. **Watch Progress**: Use Blue Ocean view for visual pipeline
3. **Test Endpoints**: After deployment, test the health endpoints
4. **Manual Approval**: For production deployment, approve when prompted

## ⚡ Quick Commands for EC2

If you need to check anything on EC2:

```bash
# Check running containers
docker ps

# Check application logs
docker logs devops-dev
docker logs devops-staging  
docker logs devops-prod

# Check if apps are responding
curl http://localhost:3000/health  # Development
curl http://localhost:3001/health  # Staging
curl http://localhost:3002/health  # Production

# Restart Jenkins if needed
sudo systemctl restart jenkins
```

## 🎉 Complete DevSecOps Setup

Once this is running, you'll have:
- ✅ Automated CI/CD pipeline
- ✅ Multi-environment deployment
- ✅ Docker containerization
- ✅ Health monitoring
- ✅ Manual approval gates
- ✅ Automated testing

**Your professional DevSecOps infrastructure is ready! 🚀**

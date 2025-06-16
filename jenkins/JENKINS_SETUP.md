# Jenkins Configuration for DevSecOps Pipeline

## 🎯 Jenkins Access
- **URL**: http://52.91.251.180:8080/
- **Instance**: i-0e605f03f8a4d2420

## 🔧 Initial Setup Steps

### 1. First-Time Jenkins Setup
```bash
# If you need the initial admin password, run this on EC2:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 2. Required Jenkins Plugins
Install these plugins via Jenkins UI (Manage Jenkins → Manage Plugins):
- **Pipeline** (for Jenkinsfile support)
- **Git Plugin** (for GitHub integration)
- **Docker Pipeline** (for Docker builds)
- **Blue Ocean** (optional - modern UI)
- **Ansible Plugin** (for infrastructure automation)

### 3. Create Pipeline Job

1. **Go to Jenkins**: http://52.91.251.180:8080/
2. **Click "New Item"**
3. **Enter name**: `devops-pipeline`
4. **Select**: "Pipeline"
5. **Click OK**

### 4. Configure Pipeline
In the pipeline configuration:

**Pipeline Definition**: Pipeline script from SCM
**SCM**: Git
**Repository URL**: `https://github.com/saidrassai/devops_try.git`
**Branch**: `*/main` (or `*/master`)
**Script Path**: `Jenkinsfile`

## 🚀 Pipeline Features

Our Jenkins pipeline will:
- ✅ Build Docker images
- ✅ Run automated tests
- ✅ Deploy to development automatically
- ✅ Deploy to staging with approval
- ✅ Deploy to production with manual approval
- ✅ Health checks after deployment
- ✅ Rollback capability

## 🌐 Environment URLs After Pipeline
- **Development**: http://52.91.251.180:3000
- **Staging**: http://52.91.251.180:3001
- **Production**: http://52.91.251.180:3002
- **Jenkins**: http://52.91.251.180:8080

## 📋 Next Steps
1. Access Jenkins at the URL above
2. Complete initial setup if not done
3. Install required plugins
4. Create the pipeline job
5. Trigger first build

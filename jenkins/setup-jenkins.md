# Jenkins Setup for DevSecOps Project

## Prerequisites
- Jenkins server running on EC2
- Docker installed on Jenkins server
- Ansible installed on Jenkins server
- SSH access to target servers

## Jenkins Configuration Steps

### 1. Install Required Plugins
```bash
# Install via Jenkins CLI or UI
- Pipeline
- Docker Pipeline
- Ansible Plugin
- Git Plugin
- Blue Ocean (optional)
```

### 2. Configure Global Tools
- **Git**: Configure Git installation
- **Docker**: Add Docker installation
- **Ansible**: Configure Ansible installation path

### 3. Create Pipeline Job
1. New Item → Pipeline
2. Name: `devops-infrastructure-pipeline`
3. Pipeline → Definition: Pipeline script from SCM
4. SCM: Git
5. Repository URL: `https://github.com/saidrassai/devops_try.git`
6. Script Path: `Jenkinsfile`

### 4. Configure Credentials
Add the following credentials in Jenkins:
- SSH private key for EC2 access
- Docker registry credentials (if using private registry)
- GitHub credentials (if repository is private)

### 5. Environment Variables
Configure these environment variables:
- `DOCKER_REGISTRY`: Your Docker registry URL
- `AWS_REGION`: us-east-1 (or your region)
- `EC2_KEY_PATH`: Path to your EC2 private key

## Branch Strategy
- `develop` branch → Deploys to Development
- `main` branch → Deploys to Preproduction → Manual approval → Production

## Security Considerations
- Use Jenkins credentials store for sensitive data
- Implement proper RBAC (Role-Based Access Control)
- Enable CSRF protection
- Use HTTPS for Jenkins access

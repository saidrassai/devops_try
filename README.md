# DevOps Infrastructure Project
test test
A professional DevOps infrastructure using AWS EC2, Jenkins, Docker, and Ansible for multi-environment deployment.

## Architecture Overview

- **Environments**: Development, Preproduction, Production
- **CI/CD**: Jenkins Pipeline
- **Containerization**: Docker & Docker Compose
- **Configuration Management**: Ansible
- **Cloud Provider**: AWS EC2

## Quick Start

1. **Setup Infrastructure**
   ```bash
   # Deploy infrastructure with Ansible
   ansible-playbook -i inventory/hosts ansible/playbooks/infrastructure.yml
   ```

2. **Build and Deploy Application**
   ```bash
   # Development
   ./scripts/deploy.sh dev
   
   # Preproduction
   ./scripts/deploy.sh preprod
   
   # Production
   ./scripts/deploy.sh prod
   ```

## Project Structure

```
├── app/                    # Application source code
├── docker/                 # Docker configurations
├── jenkins/               # Jenkins pipeline configurations
├── ansible/               # Ansible playbooks and roles
├── scripts/               # Deployment and utility scripts
├── environments/          # Environment-specific configurations
└── monitoring/           # Monitoring and logging setup
```

## Environments

- **Development**: Quick deployment for testing features
- **Preproduction**: Staging environment mimicking production
- **Production**: Live environment with full monitoring

## Technologies

- Jenkins for CI/CD
- Docker for containerization
- Ansible for configuration management
- AWS EC2 for infrastructure
- Nginx for load balancing
- Node.js sample application

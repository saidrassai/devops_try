# DevOps Infrastructure Setup Guide

## Prerequisites

1. **AWS EC2 Instances**
   - Development: 1 instance (t3.micro)
   - Preproduction: 1 instance (t3.small)
   - Production: 2 instances (t3.medium)

2. **Required Software**
   - Docker & Docker Compose
   - Ansible
   - Jenkins
   - Git

## Quick Setup Steps

### 1. Update EC2 IP Addresses

Update the following files with your actual EC2 IP addresses:
- `ansible/inventory/dev.ini`
- `ansible/inventory/preprod.ini`
- `ansible/inventory/prod.ini`
- `monitoring/prometheus.yml`

### 2. Setup SSH Keys

Place your EC2 SSH keys in `~/.ssh/` and update the inventory files.

### 3. Deploy Infrastructure

For local development:
```bash
./scripts/local-setup.sh
```

For remote environments:
```bash
# Development
./scripts/deploy.sh dev

# Preproduction
./scripts/deploy.sh preprod

# Production
./scripts/deploy.sh prod
```

### 4. Setup Jenkins

```bash
cd jenkins
docker-compose up -d
```

Access Jenkins at `http://localhost:8080`

Initial admin password:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 5. Setup Monitoring

```bash
cd monitoring
docker-compose up -d
```

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3001` (admin/admin123)

## Environment URLs

- **Development**: `http://YOUR_DEV_IP`
- **Preproduction**: `http://YOUR_PREPROD_IP`
- **Production**: `http://YOUR_PROD_IP`

## Troubleshooting

### Check Application Health
```bash
curl http://YOUR_SERVER_IP/health
```

### View Logs
```bash
docker-compose logs -f
```

### Restart Services
```bash
docker-compose restart
```

## Security Notes

1. Change default passwords
2. Use HTTPS in production
3. Implement proper firewall rules
4. Regular security updates
5. Monitor access logs

#!/bin/bash

# Deployment script for DevOps infrastructure
# Usage: ./deploy.sh [dev|preprod|prod]

set -e

ENVIRONMENT=${1:-dev}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Starting deployment to $ENVIRONMENT environment..."

case $ENVIRONMENT in
    "dev")
        INVENTORY="ansible/inventory/dev.ini"
        ;;
    "preprod")
        INVENTORY="ansible/inventory/preprod.ini"
        ;;
    "prod")
        INVENTORY="ansible/inventory/prod.ini"
        echo "⚠️  Deploying to PRODUCTION environment!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Deployment cancelled"
            exit 1
        fi
        ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        echo "Usage: $0 [dev|preprod|prod]"
        exit 1
        ;;
esac

# Build Docker image
echo "🔨 Building Docker image..."
cd "$PROJECT_DIR"
docker build -f docker/Dockerfile -t devops-sample-app:latest app/

# Run Ansible playbook
echo "📦 Deploying with Ansible..."
ansible-playbook -i "$INVENTORY" ansible/playbooks/deploy.yml \
    --extra-vars "env=$ENVIRONMENT docker_tag=latest"

echo "✅ Deployment to $ENVIRONMENT completed successfully!"
echo "🌐 Application should be available on the target servers"

#!/bin/bash

# Quick deployment script for EC2 instance i-0e605f03f8a4d2420
# Public IP: 52.91.251.180
# Private IP: 172.31.93.22

set -e

ENVIRONMENT=${1:-dev}
EC2_IP="52.91.251.180"
EC2_USER="ubuntu"
KEY_PATH="~/.ssh/devops-key.pem"

echo "🚀 Deploying to EC2 instance i-0e605f03f8a4d2420 ($ENVIRONMENT environment)"

# Test SSH connectivity
echo "🔍 Testing SSH connectivity..."
if ssh -i "$KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo 'SSH connection successful'"; then
    echo "✅ SSH connection successful"
else
    echo "❌ SSH connection failed. Please check:"
    echo "   - EC2 instance is running"
    echo "   - Security group allows SSH (port 22)"
    echo "   - SSH key path is correct: $KEY_PATH"
    echo "   - Key permissions are 400: chmod 400 $KEY_PATH"
    exit 1
fi

# Install Docker and dependencies on EC2
echo "📦 Installing dependencies on EC2..."
ssh -i "$KEY_PATH" "$EC2_USER@$EC2_IP" << 'EOF'
    # Update system
    sudo apt update -y
    
    # Install Docker
    if ! command -v docker &> /dev/null; then
        sudo apt install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker ubuntu
    fi
    
    # Install Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    # Create application directory
    sudo mkdir -p /opt/devops-app
    sudo chown ubuntu:ubuntu /opt/devops-app
    
    echo "✅ Dependencies installed successfully"
EOF

# Build Docker image locally
echo "🔨 Building Docker image..."
docker build -f docker/Dockerfile -t devops-sample-app:latest app/

# Save and transfer Docker image
echo "📤 Transferring Docker image to EC2..."
docker save devops-sample-app:latest | gzip > devops-app.tar.gz
scp -i "$KEY_PATH" devops-app.tar.gz "$EC2_USER@$EC2_IP:/tmp/"

# Transfer configuration files
echo "📁 Transferring configuration files..."
scp -i "$KEY_PATH" docker/docker-compose.yml "$EC2_USER@$EC2_IP:/opt/devops-app/"
scp -i "$KEY_PATH" docker/nginx.conf "$EC2_USER@$EC2_IP:/opt/devops-app/"
scp -i "$KEY_PATH" "environments/${ENVIRONMENT}.env" "$EC2_USER@$EC2_IP:/opt/devops-app/.env"

# Deploy on EC2
echo "🚀 Deploying application on EC2..."
ssh -i "$KEY_PATH" "$EC2_USER@$EC2_IP" << EOF
    # Load Docker image
    cd /tmp
    gunzip -c devops-app.tar.gz | docker load
    rm devops-app.tar.gz
    
    # Stop existing containers
    cd /opt/devops-app
    docker-compose down || true
    
    # Start new containers
    docker-compose up -d
    
    # Wait for services to start
    sleep 10
    
    # Check if application is running
    if curl -f http://localhost/health > /dev/null 2>&1; then
        echo "✅ Application deployed successfully!"
    else
        echo "❌ Deployment failed. Checking logs..."
        docker-compose logs
        exit 1
    fi
EOF

# Configure security group (if needed)
echo "🔒 Checking security group configuration..."
case $ENVIRONMENT in
    "dev")
        PORT=80
        ;;
    "preprod")
        PORT=8080
        ;;
    "prod")
        PORT=9000
        ;;
esac

echo "✅ Deployment completed successfully!"
echo "🌐 Application is available at: http://$EC2_IP:$PORT"
echo "📊 Health check: http://$EC2_IP:$PORT/health"
echo "🔧 API endpoint: http://$EC2_IP:$PORT/api/users"

# Clean up
rm -f devops-app.tar.gz

#!/bin/bash

# Jenkins setup script for EC2
# Run this on your Jenkins EC2 instance

set -e

echo "🔧 Setting up Jenkins for DevSecOps Pipeline..."

# Update system
sudo apt update -y

# Install Java (required for Jenkins)
sudo apt install -y openjdk-11-jdk

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install Jenkins
sudo apt update -y
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Ansible
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Install additional tools
sudo apt install -y git curl wget unzip

# Configure firewall
sudo ufw allow 8080  # Jenkins
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw --force enable

echo "✅ Jenkins setup completed!"
echo "🌐 Access Jenkins at: http://$(curl -s ifconfig.me):8080"
echo "🔑 Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

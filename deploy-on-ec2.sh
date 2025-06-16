#!/bin/bash

# Direct deployment script for EC2 instance
# Run this script directly on your EC2 instance

set -e

ENVIRONMENT=${1:-dev}

echo "🚀 DevSecOps Direct Deployment on EC2"
echo "====================================="
echo "Environment: $ENVIRONMENT"
echo "Instance: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"

# Update system packages
echo "📦 Updating system packages..."
sudo yum update -y

# Install Git if not present
echo "🔧 Installing Git..."
sudo yum install -y git

# Install Docker
echo "🐳 Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker $USER

# Install Docker Compose
echo "🔧 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Node.js (for building the app)
echo "📦 Installing Node.js..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Clone or update repository
REPO_DIR="/home/ec2-user/devops_try"
if [ -d "$REPO_DIR" ]; then
    echo "📁 Updating existing repository..."
    cd "$REPO_DIR"
    git pull origin main || git pull origin master || echo "Git pull failed, continuing..."
else
    echo "📁 Cloning repository..."
    cd /home/ec2-user
    git clone https://github.com/saidrassai/devops_try.git || {
        echo "Git clone failed, creating local project..."
        mkdir -p devops_try
        cd devops_try
    }
fi

cd "$REPO_DIR"

# Create application structure if not exists
mkdir -p app docker environments scripts

# Create Node.js application
echo "🔨 Creating Node.js application..."
cat > app/package.json << 'EOF'
{
  "name": "devops-sample-app",
  "version": "1.0.0",
  "description": "Sample Node.js application for DevOps infrastructure demo",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "echo \"No tests yet\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0"
  }
}
EOF

cat > app/server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const ENV = process.env.NODE_ENV || 'development';

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'DevSecOps Sample Application',
    environment: ENV,
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    hostname: require('os').hostname(),
    instance: process.env.INSTANCE_ID || 'unknown'
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    environment: ENV,
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    hostname: require('os').hostname()
  });
});

app.get('/api/users', (req, res) => {
  res.json({
    users: [
      { id: 1, name: 'John Doe', environment: ENV },
      { id: 2, name: 'Jane Smith', environment: ENV },
      { id: 3, name: 'Bob Johnson', environment: ENV }
    ],
    environment: ENV,
    timestamp: new Date().toISOString()
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    environment: ENV
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    environment: ENV
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT} in ${ENV} environment`);
  console.log(`🌐 Access at: http://0.0.0.0:${PORT}`);
});

module.exports = app;
EOF

# Create public directory and HTML file
mkdir -p app/public
cat > app/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevSecOps Sample App</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            background: rgba(255, 255, 255, 0.1);
            padding: 3rem;
            border-radius: 15px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            max-width: 600px;
        }
        h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }
        .info {
            margin: 1rem 0;
            padding: 1rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
        }
        .btn {
            background: #4CAF50;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
            text-decoration: none;
            display: inline-block;
        }
        .btn:hover {
            background: #45a049;
        }
        .env-badge {
            background: #ff6b6b;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
            margin: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 DevSecOps Sample Application</h1>
        <div class="env-badge" id="envBadge">Loading...</div>
        <div class="info">
            <p><strong>Status:</strong> <span id="status">Loading...</span></p>
            <p><strong>Environment:</strong> <span id="environment">Loading...</span></p>
            <p><strong>Version:</strong> <span id="version">Loading...</span></p>
            <p><strong>Hostname:</strong> <span id="hostname">Loading...</span></p>
            <p><strong>Instance:</strong> <span id="instance">Loading...</span></p>
        </div>
        <a href="/api/users" class="btn">View Users API</a>
        <a href="/health" class="btn">Health Check</a>
    </div>

    <script>
        fetch('/')
            .then(response => response.json())
            .then(data => {
                document.getElementById('status').textContent = 'Running ✅';
                document.getElementById('environment').textContent = data.environment;
                document.getElementById('version').textContent = data.version;
                document.getElementById('hostname').textContent = data.hostname;
                document.getElementById('instance').textContent = data.instance;
                document.getElementById('envBadge').textContent = data.environment.toUpperCase();
            })
            .catch(error => {
                document.getElementById('status').textContent = 'Error ❌';
                console.error('Error:', error);
            });
    </script>
</body>
</html>
EOF

# Create healthcheck
cat > app/healthcheck.js << 'EOF'
const http = require('http');

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/health',
  method: 'GET'
};

const req = http.request(options, (res) => {
  if (res.statusCode === 200) {
    process.exit(0);
  } else {
    process.exit(1);
  }
});

req.on('error', () => {
  process.exit(1);
});

req.end();
EOF

# Create Dockerfile
cat > docker/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodeuser -u 1001
RUN chown -R nodeuser:nodejs /app
USER nodeuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

CMD ["npm", "start"]
EOF

# Create Docker Compose
cat > docker/docker-compose.yml << EOF
version: '3.8'

services:
  app:
    build:
      context: ../app
      dockerfile: ../docker/Dockerfile
    ports:
      - "\${PORT:-3000}:3000"
    environment:
      - NODE_ENV=\${NODE_ENV:-$ENVIRONMENT}
      - PORT=3000
      - INSTANCE_ID=\$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo 'local')
    restart: unless-stopped
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "\${NGINX_PORT:-80}:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF

# Create Nginx config
cat > docker/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream app {
        server app:3000;
    }

    server {
        listen 80;
        server_name _;

        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            access_log off;
            proxy_pass http://app;
            proxy_set_header Host $host;
        }
    }
}
EOF

# Create environment file
cat > environments/${ENVIRONMENT}.env << EOF
NODE_ENV=$ENVIRONMENT
PORT=3000
NGINX_PORT=80
EOF

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
cd app
npm install
cd ..

# Build and start application
echo "🚀 Building and starting application..."
cd docker

# Set environment variables
export NODE_ENV=$ENVIRONMENT
export NGINX_PORT=80

# Stop any existing containers
sudo docker-compose down 2>/dev/null || true

# Build and start new containers
sudo docker-compose up -d --build

echo "⏳ Waiting for application to start..."
sleep 15

# Test the application
echo "🧪 Testing application..."
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✅ Application is running successfully!"
    echo ""
    echo "🌐 Access URLs:"
    echo "   External: http://$INSTANCE_IP"
    echo "   Internal: http://localhost"
    echo "   Health: http://$INSTANCE_IP/health"
    echo "   API: http://$INSTANCE_IP/api/users"
    echo ""
    echo "🔧 Container Status:"
    sudo docker-compose ps
else
    echo "❌ Application health check failed. Checking logs..."
    sudo docker-compose logs
fi

echo ""
echo "✅ Deployment completed for $ENVIRONMENT environment!"

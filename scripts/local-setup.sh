#!/bin/bash

# Local development setup script

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🛠️  Setting up local development environment..."

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Install dependencies
echo "📦 Installing Node.js dependencies..."
cd "$PROJECT_DIR/app"
npm install

# Build and start local environment
echo "🚀 Starting local development environment..."
cd "$PROJECT_DIR"
cp environments/dev.env docker/.env
cd docker
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 10

# Health check
echo "🔍 Performing health check..."
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✅ Application is running successfully!"
    echo "🌐 Access the application at: http://localhost"
    echo "📊 Health endpoint: http://localhost/health"
    echo "🔧 API endpoint: http://localhost/api/users"
else
    echo "❌ Health check failed. Check the logs:"
    docker-compose logs
fi

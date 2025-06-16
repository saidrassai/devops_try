#!/bin/bash

# DevSecOps Infrastructure Test Script
# Run this on EC2 to verify complete setup

echo "🧪 DevSecOps Infrastructure Test"
echo "================================"

# Get instance info
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo "📋 Instance Info:"
echo "   Instance ID: $INSTANCE_ID"
echo "   Public IP: $PUBLIC_IP"
echo ""

# Test Jenkins
echo "🔧 Testing Jenkins..."
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "   ✅ Jenkins is running on port 8080"
    echo "   🌐 Access at: http://$PUBLIC_IP:8080"
else
    echo "   ❌ Jenkins is not accessible"
fi

# Test Docker
echo ""
echo "🐳 Testing Docker..."
if docker --version > /dev/null 2>&1; then
    echo "   ✅ Docker is installed: $(docker --version)"
    
    # Show running containers
    CONTAINERS=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | tail -n +2)
    if [ -n "$CONTAINERS" ]; then
        echo "   📦 Running containers:"
        echo "$CONTAINERS" | sed 's/^/      /'
    else
        echo "   ℹ️ No containers currently running"
    fi
else
    echo "   ❌ Docker is not installed"
fi

# Test application endpoints
echo ""
echo "🌐 Testing Application Endpoints..."

# Test Development (port 3000)
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    RESPONSE=$(curl -s http://localhost:3000/health)
    echo "   ✅ Development (3000): http://$PUBLIC_IP:3000"
    echo "      Health: $(echo $RESPONSE | jq -r '.status' 2>/dev/null || echo 'healthy')"
else
    echo "   ❌ Development (3000): Not accessible"
fi

# Test Staging (port 3001)
if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    RESPONSE=$(curl -s http://localhost:3001/health)
    echo "   ✅ Staging (3001): http://$PUBLIC_IP:3001"
    echo "      Health: $(echo $RESPONSE | jq -r '.status' 2>/dev/null || echo 'healthy')"
else
    echo "   ⚠️ Staging (3001): Not deployed yet"
fi

# Test Production (port 3002)
if curl -s http://localhost:3002/health > /dev/null 2>&1; then
    RESPONSE=$(curl -s http://localhost:3002/health)
    echo "   ✅ Production (3002): http://$PUBLIC_IP:3002"
    echo "      Health: $(echo $RESPONSE | jq -r '.status' 2>/dev/null || echo 'healthy')"
else
    echo "   ⚠️ Production (3002): Not deployed yet"
fi

# Test port 80 (if nginx/main app is running)
if curl -s http://localhost:80/health > /dev/null 2>&1; then
    echo "   ✅ Main App (80): http://$PUBLIC_IP"
else
    echo "   ⚠️ Main App (80): Not deployed yet"
fi

echo ""
echo "🔒 Security Group Check:"
echo "   Make sure these ports are open in AWS Security Group:"
echo "   - 22 (SSH) - from your IP"
echo "   - 80 (HTTP) - from 0.0.0.0/0"
echo "   - 3000, 3001, 3002 (Apps) - from 0.0.0.0/0"
echo "   - 8080 (Jenkins) - from 0.0.0.0/0"

echo ""
echo "📊 Quick Summary:"
echo "=================="
echo "🌐 Jenkins Dashboard: http://$PUBLIC_IP:8080"
echo "🚀 Development App: http://$PUBLIC_IP:3000"
echo "🎭 Staging App: http://$PUBLIC_IP:3001"
echo "🏭 Production App: http://$PUBLIC_IP:3002"
echo ""
echo "💡 Next Steps:"
echo "   1. Access Jenkins and create the pipeline"
echo "   2. Run first build to deploy all environments"
echo "   3. Test the complete CI/CD workflow"
echo ""
echo "✅ DevSecOps Infrastructure Test Complete!"

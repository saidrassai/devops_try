#!/bin/bash

# Test script for DevSecOps infrastructure
# Tests all environments on EC2 instance

EC2_IP="52.91.251.180"
ENVIRONMENTS=("dev:80" "preprod:8080" "prod:9000")

echo "🧪 Testing DevSecOps Infrastructure on EC2: $EC2_IP"
echo "================================================"

for env_port in "${ENVIRONMENTS[@]}"; do
    IFS=':' read -ra ENV_PORT <<< "$env_port"
    ENV=${ENV_PORT[0]}
    PORT=${ENV_PORT[1]}
    
    echo ""
    echo "🔍 Testing $ENV environment (port $PORT)..."
    
    # Test health endpoint
    if curl -s -f "http://$EC2_IP:$PORT/health" > /dev/null; then
        echo "  ✅ Health check passed"
        
        # Test main endpoint
        RESPONSE=$(curl -s "http://$EC2_IP:$PORT/")
        if echo "$RESPONSE" | grep -q "DevOps Sample Application"; then
            echo "  ✅ Main endpoint working"
        else
            echo "  ❌ Main endpoint failed"
        fi
        
        # Test API endpoint
        if curl -s -f "http://$EC2_IP:$PORT/api/users" > /dev/null; then
            echo "  ✅ API endpoint working"
        else
            echo "  ❌ API endpoint failed"
        fi
        
        # Get environment info
        ENV_INFO=$(curl -s "http://$EC2_IP:$PORT/" | grep -o '"environment":"[^"]*"' | cut -d'"' -f4)
        echo "  📊 Environment: $ENV_INFO"
        
    else
        echo "  ❌ $ENV environment not accessible on port $PORT"
    fi
done

echo ""
echo "🔧 Testing Jenkins..."
if curl -s -f "http://$EC2_IP:8080" > /dev/null; then
    echo "  ✅ Jenkins is accessible"
else
    echo "  ❌ Jenkins not accessible (might not be installed yet)"
fi

echo ""
echo "📊 Infrastructure Test Summary:"
echo "================================"
echo "🌐 Application URLs:"
echo "   Development:   http://$EC2_IP"
echo "   Preproduction: http://$EC2_IP:8080"
echo "   Production:    http://$EC2_IP:9000"
echo "   Jenkins:       http://$EC2_IP:8080"
echo ""
echo "✅ Test completed!"

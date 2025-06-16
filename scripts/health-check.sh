#!/bin/bash

# Health check script for all environments
# Usage: ./health-check.sh [dev|preprod|prod|all]

ENVIRONMENT=${1:-all}

check_health() {
    local env=$1
    local url=$2
    
    echo "🔍 Checking $env environment..."
    
    if curl -f "$url/health" > /dev/null 2>&1; then
        echo "✅ $env environment is healthy"
        curl -s "$url/health" | jq '.'
    else
        echo "❌ $env environment is unhealthy"
    fi
    echo ""
}

case $ENVIRONMENT in
    "dev")
        check_health "Development" "http://YOUR_DEV_IP"
        ;;
    "preprod")
        check_health "Preproduction" "http://YOUR_PREPROD_IP"
        ;;
    "prod")
        check_health "Production" "http://YOUR_PROD_IP_1"
        check_health "Production-2" "http://YOUR_PROD_IP_2"
        ;;
    "all")
        check_health "Development" "http://YOUR_DEV_IP"
        check_health "Preproduction" "http://YOUR_PREPROD_IP"
        check_health "Production-1" "http://YOUR_PROD_IP_1"
        check_health "Production-2" "http://YOUR_PROD_IP_2"
        ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        echo "Usage: $0 [dev|preprod|prod|all]"
        exit 1
        ;;
esac

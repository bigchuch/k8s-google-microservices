#!/bin/bash

# Microservices Installation Script
# Usage: ./install.sh [environment]
# Environments: dev, staging, prod
# Default: dev

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Installing microservices for environment: $ENVIRONMENT"

# Validate environment
case $ENVIRONMENT in
  dev|staging|prod)
    echo "Valid environment: $ENVIRONMENT"
    ;;
  *)
    echo "Error: Invalid environment '$ENVIRONMENT'. Use: dev, staging, or prod"
    exit 1
    ;;
esac

# Check if helmfile is installed
if ! command -v helmfile &> /dev/null; then
    echo "Error: helmfile is not installed. Please install helmfile first."
    echo "Visit: https://github.com/helmfile/helmfile#installation"
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT"

# Deploy using helmfile
echo "Deploying microservices using Helmfile..."
helmfile -f helmfile/helmfile.yaml -e $ENVIRONMENT sync

echo "Installation completed for environment: $ENVIRONMENT"
echo ""
echo "To check the status:"
echo "  kubectl get pods -n microservices-$ENVIRONMENT"
echo ""
echo "To access the frontend (if NodePort/LoadBalancer):"
case $ENVIRONMENT in
  dev)
    echo "  kubectl port-forward -n microservices-dev svc/frontend 8080:80"
    ;;
  staging)
    echo "  kubectl port-forward -n microservices-staging svc/frontend 8080:80"
    ;;
  prod)
    echo "  Check LoadBalancer external IP: kubectl get svc -n microservices-prod frontend"
    ;;
esac

#!/bin/bash

# Microservices Uninstallation Script
# Usage: ./uninstall.sh [environment] [method]
# Environments: dev, staging, prod
# Methods: argocd, helm
# Default: dev argocd

set -e

ENVIRONMENT=${1:-dev}
METHOD=${2:-argocd}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Uninstalling microservices for environment: $ENVIRONMENT using method: $METHOD"

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

# Validate method
case $METHOD in
  argocd|helm)
    echo "Valid method: $METHOD"
    ;;
  *)
    echo "Error: Invalid method '$METHOD'. Use: argocd or helm"
    exit 1
    ;;
esac

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT"

if [ "$METHOD" = "argocd" ]; then
    # Uninstall using ArgoCD
    echo "Removing ArgoCD application for $ENVIRONMENT..."
    
    # Delete the ArgoCD application
    kubectl delete -f apps/app-$ENVIRONMENT.yaml --ignore-not-found=true
    
    echo "ArgoCD application removed. Resources may take time to be cleaned up."
    echo "You can monitor the cleanup with:"
    echo "  kubectl get pods -n microservices-$ENVIRONMENT"
    
elif [ "$METHOD" = "helm" ]; then
    # Uninstall using Helm directly
    echo "Uninstalling Helm release for $ENVIRONMENT..."
    
    # Check if helm is available
    if ! command -v helm &> /dev/null; then
        echo "Error: helm is not installed. Please install helm first."
        exit 1
    fi
    
    # Uninstall the helm release
    helm uninstall microservices-$ENVIRONMENT --namespace microservices-$ENVIRONMENT --ignore-not-found
fi

# Optionally delete the namespace
read -p "Do you want to delete the namespace 'microservices-$ENVIRONMENT'? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting namespace microservices-$ENVIRONMENT..."
    kubectl delete namespace microservices-$ENVIRONMENT --ignore-not-found=true
fi

echo "Uninstallation completed for environment: $ENVIRONMENT"

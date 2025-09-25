#!/bin/bash

# Microservices Installation Script
# Usage: ./install.sh [environment] [method]
# Environments: dev, staging, prod
# Methods: argocd, helm
# Default: dev argocd

set -e

ENVIRONMENT=${1:-dev}
METHOD=${2:-argocd}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Installing microservices for environment: $ENVIRONMENT using method: $METHOD"

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

# Change to project root
cd "$PROJECT_ROOT"

if [ "$METHOD" = "argocd" ]; then
    # Deploy using ArgoCD
    echo "Deploying microservices using ArgoCD..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        echo "Error: kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Apply the ArgoCD application
    echo "Applying ArgoCD application for $ENVIRONMENT..."
    kubectl apply -f apps/app-$ENVIRONMENT.yaml
    
    echo "ArgoCD application created. Waiting for sync..."
    echo "You can monitor the deployment with:"
    echo "  kubectl get applications -n argocd microservices-$ENVIRONMENT"
    echo "  kubectl describe application -n argocd microservices-$ENVIRONMENT"
    
elif [ "$METHOD" = "helm" ]; then
    # Deploy using Helm directly
    echo "Deploying microservices using Helm..."
    
    # Check if helm is available
    if ! command -v helm &> /dev/null; then
        echo "Error: helm is not installed. Please install helm first."
        exit 1
    fi
    
    # Install/upgrade using helm
    echo "Installing/upgrading Helm chart for $ENVIRONMENT..."
    helm upgrade --install microservices-$ENVIRONMENT \
        charts/microservices \
        --namespace microservices-$ENVIRONMENT \
        --create-namespace \
        --values values/$ENVIRONMENT.yaml \
        --set global.environment=$ENVIRONMENT \
        --set global.namespace=microservices-$ENVIRONMENT
fi

echo "Installation completed for environment: $ENVIRONMENT"
echo ""
echo "To check the status:"
echo "  kubectl get pods -n microservices-$ENVIRONMENT"
echo ""
echo "To access the frontend:"
case $ENVIRONMENT in
  dev)
    echo "  kubectl port-forward -n microservices-dev svc/frontend 8080:80"
    echo "  Then visit: http://localhost:8080"
    ;;
  staging|prod)
    echo "  kubectl get svc -n microservices-$ENVIRONMENT frontend"
    echo "  Check the EXTERNAL-IP for LoadBalancer access"
    ;;
esac

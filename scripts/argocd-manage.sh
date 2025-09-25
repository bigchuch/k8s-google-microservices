#!/bin/bash

# ArgoCD Management Script
# Usage: ./argocd-manage.sh [command] [environment]
# Commands: status, sync, logs, diff, refresh
# Environments: dev, staging, prod
# Default: status dev

set -e

COMMAND=${1:-status}
ENVIRONMENT=${2:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "ArgoCD Management - Command: $COMMAND, Environment: $ENVIRONMENT"

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

# Validate command
case $COMMAND in
  status|sync|logs|diff|refresh)
    echo "Valid command: $COMMAND"
    ;;
  *)
    echo "Error: Invalid command '$COMMAND'. Use: status, sync, logs, diff, or refresh"
    echo ""
    echo "Available commands:"
    echo "  status  - Show application status"
    echo "  sync    - Sync application with Git repository"
    echo "  logs    - Show application logs"
    echo "  diff    - Show differences between Git and cluster"
    echo "  refresh - Refresh application (re-read Git repository)"
    exit 1
    ;;
esac

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed. Please install kubectl first."
    exit 1
fi

APP_NAME="microservices-$ENVIRONMENT"

case $COMMAND in
  status)
    echo "Getting status for $APP_NAME..."
    kubectl get application -n argocd $APP_NAME -o wide
    echo ""
    echo "Detailed status:"
    kubectl describe application -n argocd $APP_NAME
    ;;
    
  sync)
    echo "Syncing $APP_NAME..."
    kubectl patch application -n argocd $APP_NAME --type merge --patch='{"operation":{"sync":{"syncStrategy":{"hook":{"force":true}}}}}'
    echo "Sync initiated. Check status with: $0 status $ENVIRONMENT"
    ;;
    
  logs)
    echo "Getting logs for $APP_NAME..."
    kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=50 | grep $APP_NAME || echo "No recent logs found for $APP_NAME"
    ;;
    
  diff)
    echo "Getting diff for $APP_NAME..."
    kubectl get application -n argocd $APP_NAME -o jsonpath='{.status.operationState.syncResult.revision}' > /tmp/current_revision
    echo "Current revision: $(cat /tmp/current_revision)"
    echo "Use ArgoCD UI or CLI for detailed diff visualization"
    ;;
    
  refresh)
    echo "Refreshing $APP_NAME..."
    kubectl patch application -n argocd $APP_NAME --type merge --patch='{"operation":{"initiatedBy":{"automated":false},"retry":{"limit":5}}}'
    echo "Refresh initiated. Check status with: $0 status $ENVIRONMENT"
    ;;
esac

echo ""
echo "Useful commands:"
echo "  kubectl get pods -n microservices-$ENVIRONMENT"
echo "  kubectl get svc -n microservices-$ENVIRONMENT"
echo "  kubectl port-forward -n microservices-$ENVIRONMENT svc/frontend 8080:80"
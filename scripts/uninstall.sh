#!/bin/bash

# Microservices Uninstallation Script
# Usage: ./uninstall.sh [environment]
# Environments: dev, staging, prod
# Default: dev

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Uninstalling microservices for environment: $ENVIRONMENT"

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

# Destroy using helmfile
echo "Destroying microservices using Helmfile..."
helmfile -f helmfile/helmfile.yaml -e $ENVIRONMENT destroy

# Optionally delete the namespace
read -p "Do you want to delete the namespace 'microservices-$ENVIRONMENT'? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting namespace microservices-$ENVIRONMENT..."
    kubectl delete namespace microservices-$ENVIRONMENT --ignore-not-found=true
fi

echo "Uninstallation completed for environment: $ENVIRONMENT"

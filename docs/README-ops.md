# Microservices Operations Guide

This document provides operational guidance for deploying, managing, and troubleshooting the Google Cloud microservices demo application.

## Quick Start

### Prerequisites

- Kubernetes cluster (local or cloud)
- `kubectl` configured to access your cluster
- `helmfile` installed ([Installation Guide](https://github.com/helmfile/helmfile#installation))
- `helm` v3+ installed

### Environment Deployment

Deploy to different environments using the install script:

```bash
# Development environment (default)
./scripts/install.sh dev

# Staging environment
./scripts/install.sh staging

# Production environment
./scripts/install.sh prod
```

### Environment Differences

| Environment | Namespace | Replicas | Frontend Service | Image Tag |
|-------------|-----------|----------|------------------|-----------|
| dev         | microservices-dev | 1 | NodePort (30007) | v1 |
| staging     | microservices-staging | 2 | NodePort (30008) | v1 |
| prod        | microservices-prod | 3 | LoadBalancer | v1 |

## Access Applications

### Development
```bash
# Port forward to access frontend
kubectl port-forward -n microservices-dev svc/frontend 8080:80

# Access at http://localhost:8080
```

### Staging
```bash
# Port forward to access frontend
kubectl port-forward -n microservices-staging svc/frontend 8080:80

# Or access via NodePort
kubectl get nodes -o wide  # Get node IP
# Access at http://<NODE_IP>:30008
```

### Production
```bash
# Get LoadBalancer external IP
kubectl get svc -n microservices-prod frontend

# Access at http://<EXTERNAL_IP>
```

## Monitoring and Troubleshooting

### Check Pod Status
```bash
# Development
kubectl get pods -n microservices-dev

# Staging
kubectl get pods -n microservices-staging

# Production
kubectl get pods -n microservices-prod
```

### View Logs
```bash
# View logs for a specific service
kubectl logs -n microservices-<env> deployment/<service-name>

# Follow logs
kubectl logs -n microservices-<env> deployment/<service-name> -f
```

### Common Issues

1. **Pods stuck in Pending**: Check resource constraints
   ```bash
   kubectl describe pod -n microservices-<env> <pod-name>
   ```

2. **Service not accessible**: Verify service and ingress configuration
   ```bash
   kubectl get svc -n microservices-<env>
   kubectl describe svc -n microservices-<env> <service-name>
   ```

3. **Redis connection issues**: Check redis-cart service
   ```bash
   kubectl logs -n microservices-<env> deployment/redis-cart
   ```

## Rollback Procedures

### Using Helmfile
```bash
# Rollback to previous release
helmfile -f helmfile/helmfile.yaml -e <environment> rollback

# Rollback specific release
helm rollback -n microservices-<env> <release-name> <revision>
```

### Check Release History
```bash
# List releases
helm list -n microservices-<env>

# Check release history
helm history -n microservices-<env> <release-name>
```

## Scaling

### Manual Scaling
```bash
# Scale a specific deployment
kubectl scale deployment -n microservices-<env> <service-name> --replicas=<count>
```

### Update Environment Configuration
1. Edit the appropriate environment file in `helmfile/environments/`
2. Update replica counts
3. Apply changes:
   ```bash
   helmfile -f helmfile/helmfile.yaml -e <environment> sync
   ```

## Cleanup

### Uninstall Environment
```bash
# Uninstall specific environment
./scripts/uninstall.sh <environment>

# This will prompt to delete the namespace as well
```

### Manual Cleanup
```bash
# Delete all resources in namespace
kubectl delete all --all -n microservices-<env>

# Delete namespace
kubectl delete namespace microservices-<env>
```

## ArgoCD Integration

If using ArgoCD, applications are defined in the `apps/` directory:

- `app-dev.yaml` - Development environment
- `app-staging.yaml` - Staging environment  
- `app-prod.yaml` - Production environment

Apply ArgoCD applications:
```bash
kubectl apply -f apps/app-<environment>.yaml
```

## Security Considerations

- Production uses manual sync policy in ArgoCD for safety
- Review all changes before applying to production
- Use proper RBAC for different environments
- Monitor resource usage and set appropriate limits
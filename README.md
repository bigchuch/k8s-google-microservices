# Google Cloud Microservices Demo - Kubernetes Deployment

This repository contains a complete GitOps workflow for deploying the Google Cloud microservices demo application to Kubernetes using Helm, Helmfile, and ArgoCD.

## 🏗️ Architecture

The application consists of 11 microservices:

- **Frontend** - Web UI for the e-commerce application
- **Cart Service** - Shopping cart functionality  
- **Product Catalog Service** - Product information and search
- **Currency Service** - Currency conversion
- **Payment Service** - Payment processing
- **Shipping Service** - Shipping cost calculation
- **Email Service** - Email notifications
- **Checkout Service** - Checkout process orchestration
- **Recommendation Service** - Product recommendations
- **Ad Service** - Contextual advertisements
- **Redis Cart** - Redis cache for cart data

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (local or cloud)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured
- [Helm v3+](https://helm.sh/docs/intro/install/)
- [Helmfile](https://github.com/helmfile/helmfile#installation)

### Deploy to Development

```bash
# Clone the repository
git clone <repository-url>
cd k8s-google-microservices

# Deploy to development environment
./scripts/install.sh dev

# Access the application
kubectl port-forward -n microservices-dev svc/frontend 8080:80
# Open http://localhost:8080
```

### Deploy to Staging

```bash
./scripts/install.sh staging

# Access via NodePort
kubectl get nodes -o wide  # Get node IP
# Access at http://<NODE_IP>:30008
```

### Deploy to Production

```bash
./scripts/install.sh prod

# Get LoadBalancer external IP
kubectl get svc -n microservices-prod frontend
# Access at http://<EXTERNAL_IP>
```

## 📁 Repository Structure

```
k8s-google-microservices/
├── charts/                          # Reusable Helm charts
│   └── microservices/               # Main umbrella chart
│       ├── Chart.yaml
│       ├── values.yaml              # Default values
│       └── templates/               # Kubernetes manifests
├── values/                          # Environment-specific values
│   ├── dev.yaml                     # Development configuration
│   ├── staging.yaml                 # Staging configuration
│   └── prod.yaml                    # Production configuration
├── apps/                            # ArgoCD Applications
│   ├── app-dev.yaml
│   ├── app-staging.yaml
│   └── app-prod.yaml
├── helmfile/                        # Helmfile orchestration
│   ├── helmfile.yaml
│   └── environments/
│       ├── dev.yaml
│       ├── staging.yaml
│       └── prod.yaml
├── scripts/                         # Helper scripts
│   ├── install.sh                   # Installation script
│   └── uninstall.sh                 # Cleanup script
├── .github/workflows/               # CI/CD pipelines
│   └── ci.yaml
└── docs/                           # Documentation
    └── README-ops.md               # Operations guide
```

## 🌍 Environment Configurations

| Environment | Namespace | Replicas | Frontend Service | Image Tag |
|-------------|-----------|----------|------------------|-----------|
| **dev** | microservices-dev | 1 | NodePort (30007) | v1 |
| **staging** | microservices-staging | 2 | NodePort (30008) | v1 |
| **prod** | microservices-prod | 3 | LoadBalancer | v1 |

## 🔧 Management Commands

### Installation
```bash
# Install specific environment
./scripts/install.sh [dev|staging|prod]

# Default is dev if no environment specified
./scripts/install.sh
```

### Monitoring
```bash
# Check pod status
kubectl get pods -n microservices-<env>

# View logs
kubectl logs -n microservices-<env> deployment/<service-name>

# Port forward for local access
kubectl port-forward -n microservices-<env> svc/frontend 8080:80
```

### Cleanup
```bash
# Uninstall specific environment
./scripts/uninstall.sh [dev|staging|prod]

# This will prompt to delete the namespace
```

## 🔄 GitOps with ArgoCD

Deploy ArgoCD applications for automated GitOps:

```bash
# Apply ArgoCD application for development
kubectl apply -f apps/app-dev.yaml

# Apply ArgoCD application for staging
kubectl apply -f apps/app-staging.yaml

# Apply ArgoCD application for production (manual sync)
kubectl apply -f apps/app-prod.yaml
```

## 🧪 CI/CD Pipeline

The repository includes a comprehensive CI/CD pipeline that:

- Lints Helm charts
- Validates Kubernetes manifests
- Tests deployments in kind clusters
- Runs security scans with Checkov
- Packages and releases Helm charts

## 📚 Documentation

- [Operations Guide](docs/README-ops.md) - Detailed operational procedures
- [Helm Chart Documentation](charts/microservices/README.md) - Chart-specific documentation

## 🛠️ Customization

### Adding New Services

1. Add service configuration to `charts/microservices/values.yaml`
2. Create deployment and service templates in `charts/microservices/templates/`
3. Update environment-specific values in `values/` directory
4. Test with `helm template` and deploy

### Modifying Environments

1. Edit environment-specific files in `values/` or `helmfile/environments/`
2. Apply changes with `./scripts/install.sh <environment>`

### Custom Images

Update image configurations in the appropriate values files:

```yaml
services:
  your-service:
    appName: your-service
    appImage: your-registry/your-image
    appVersion: your-tag
```

## 🔒 Security

- Production environment uses manual sync in ArgoCD
- Secrets should be managed separately (not in this repo)
- Use proper RBAC for different environments
- Regular security scanning via CI/CD pipeline

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with all environments
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For operational issues, see the [Operations Guide](docs/README-ops.md).

For development questions, please open an issue in this repository.
# Google Cloud Microservices Demo - Kubernetes Deployment

This repository contains a complete GitOps workflow for deploying the Google Cloud microservices demo application to Kubernetes using ArgoCD with direct Helm chart integration.

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
- [Helm v3+](https://helm.sh/docs/intro/install/) (optional, for direct Helm deployment)
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/getting_started/) installed in your cluster
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) (optional, for advanced operations)

### Deploy to Development

#### Option 1: ArgoCD (Recommended)
```bash
# Clone the repository
git clone <repository-url>
cd micro-services

# Deploy using ArgoCD (default method)
./scripts/install.sh dev

# Access the application
kubectl port-forward -n microservices-dev svc/frontend 8080:80
# Open http://localhost:8080
```

#### Option 2: Direct Helm
```bash
# Deploy using Helm directly
./scripts/install.sh dev helm

# Access the application
kubectl port-forward -n microservices-dev svc/frontend 8080:80
# Open http://localhost:8080
```

### Deploy to Staging

```bash
# ArgoCD deployment (recommended)
./scripts/install.sh staging

# Or direct Helm deployment
./scripts/install.sh staging helm

# Access via NodePort
kubectl get nodes -o wide  # Get node IP
# Access at http://<NODE_IP>:30008
```

### Deploy to Production

```bash
# ArgoCD deployment (recommended)
./scripts/install.sh prod

# Or direct Helm deployment
./scripts/install.sh prod helm

# Get LoadBalancer external IP
kubectl get svc -n microservices-prod frontend
# Access at http://<EXTERNAL_IP>
```

## 📁 Repository Structure

```
micro-services/
├── charts/                          # Helm charts
│   └── microservices/               # Umbrella chart for all services
│       ├── Chart.yaml               # Chart metadata
│       ├── values.yaml              # Default values for all services
│       └── templates/               # Kubernetes manifests
│           ├── deployment.yaml      # Deployment template
│           └── service.yaml         # Service template
├── values/                          # Environment-specific value overlays
│   ├── dev.yaml                     # Development configuration
│   ├── staging.yaml                 # Staging configuration
│   └── prod.yaml                    # Production configuration
├── apps/                            # ArgoCD Application manifests
│   ├── app-dev.yaml                 # Development ArgoCD app
│   ├── app-staging.yaml             # Staging ArgoCD app
│   └── app-prod.yaml                # Production ArgoCD app
├── scripts/                         # Management scripts
│   ├── install.sh                   # Installation script (ArgoCD/Helm)
│   ├── uninstall.sh                 # Cleanup script
│   └── argocd-manage.sh             # ArgoCD operations script
├── .github/workflows/               # CI/CD pipelines
│   └── ci.yaml
├── docs/                           # Documentation
│   └── README-ops.md               # Operations guide
└── helmfile/                        # Legacy Helmfile (deprecated)
    ├── helmfile.yaml
    └── environments/
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
# Install using ArgoCD (recommended)
./scripts/install.sh [dev|staging|prod] argocd

# Install using Helm directly
./scripts/install.sh [dev|staging|prod] helm

# Default is dev environment with ArgoCD method
./scripts/install.sh
```

### ArgoCD Operations
```bash
# Check ArgoCD application status
./scripts/argocd-manage.sh status [dev|staging|prod]

# Sync application with Git repository
./scripts/argocd-manage.sh sync [dev|staging|prod]

# View application logs
./scripts/argocd-manage.sh logs [dev|staging|prod]

# Refresh application (re-read Git)
./scripts/argocd-manage.sh refresh [dev|staging|prod]

# Show differences between Git and cluster
./scripts/argocd-manage.sh diff [dev|staging|prod]
```

### Monitoring
```bash
# Check pod status
kubectl get pods -n microservices-<env>

# View service status
kubectl get svc -n microservices-<env>

# View logs for specific service
kubectl logs -n microservices-<env> deployment/<service-name>

# Port forward for local access
kubectl port-forward -n microservices-<env> svc/frontend 8080:80
```

### Cleanup
```bash
# Uninstall using ArgoCD
./scripts/uninstall.sh [dev|staging|prod] argocd

# Uninstall using Helm directly
./scripts/uninstall.sh [dev|staging|prod] helm

# This will prompt to delete the namespace
```

## 🔄 GitOps with ArgoCD

This repository is designed for GitOps workflows using ArgoCD with direct Helm chart integration. Each environment has its own ArgoCD Application that monitors this Git repository and automatically deploys changes.

### ArgoCD Application Setup

```bash
# Apply ArgoCD application for development (auto-sync enabled)
kubectl apply -f apps/app-dev.yaml

# Apply ArgoCD application for staging (auto-sync enabled)
kubectl apply -f apps/app-staging.yaml

# Apply ArgoCD application for production (manual sync for safety)
kubectl apply -f apps/app-prod.yaml
```

### GitOps Workflow

1. **Make Changes**: Update Helm chart values or templates
2. **Commit & Push**: Changes to this repository
3. **Auto-Sync**: Dev and staging environments automatically sync
4. **Manual Sync**: Production requires manual approval via ArgoCD UI or CLI

### ArgoCD Application Configuration

Each environment uses:
- **Source**: This Git repository
- **Path**: `charts/microservices` (umbrella Helm chart)
- **Values**: Environment-specific files from `values/` directory
- **Namespace**: `microservices-{environment}`
- **Sync Policy**: Auto for dev/staging, manual for prod

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

1. Add service configuration to `charts/microservices/values.yaml`:
```yaml
services:
  your-new-service:
    enabled: true
    appName: your-new-service
    appImage: your-registry/your-image
    appVersion: v1.0.0
    appReplicas: 1
    containerPort: 8080
    # ... other configuration
```

2. The existing templates in `charts/microservices/templates/` will automatically handle the new service
3. Update environment-specific values in `values/` directory if needed
4. Test with `helm template charts/microservices --values values/dev.yaml`
5. Deploy with `./scripts/install.sh dev` or commit for GitOps

### Modifying Environments

1. Edit environment-specific files in `values/` directory:
   - `values/dev.yaml` - Development overrides
   - `values/staging.yaml` - Staging overrides  
   - `values/prod.yaml` - Production overrides

2. Apply changes:
   - **ArgoCD**: Commit and push (auto-sync for dev/staging)
   - **Direct Helm**: `./scripts/install.sh <environment> helm`

### Custom Images

Update image configurations in the appropriate values files:

```yaml
services:
  your-service:
    enabled: true
    appName: your-service
    appImage: your-registry/your-image
    appVersion: your-tag
    appReplicas: 2
    containerPort: 8080
    containerEnvVars:
      - name: ENV_VAR
        value: "custom-value"
```

### Environment-Specific Overrides

```yaml
# values/prod.yaml
global:
  environment: prod
  namespace: microservices-prod
  imageTag: v1.2.0
  replicas: 3

services:
  frontend:
    appReplicas: 5  # Override for production
    serviceType: LoadBalancer
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
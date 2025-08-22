# L2Scan Stack CE

A comprehensive deployment solution for L2Scan blockchain explorer, providing both Kubernetes Helm charts and Docker Compose configurations for easy deployment and management. Includes integrated smart contract verification service for complete blockchain exploration capabilities.

## 🚀 Features

- **Complete Stack**: App, indexer, verifier, database, and caching in one deployment
- **Smart Contract Verification**: Integrated Blockscout verifier for Solidity and Vyper contracts
- **Flexible Deployment**: Support for both Docker Compose and Kubernetes
- **Production Ready**: Security, monitoring, and scaling configurations included
- **Developer Friendly**: Development environment with hot reloading and admin tools
- **Well Documented**: Comprehensive guides and configuration examples

## 📦 Components

| Component | Description | Technology |
|-----------|-------------|------------|
| **App** | Web-based blockchain explorer interface | Next.js, React |
| **Indexer** | Blockchain data indexing service | Go |
| **Verifier** | Smart contract verification service | Rust |
| **Database** | Persistent storage for blockchain data | PostgreSQL |
| **Cache** | Session and data caching | Redis |
| **Proxy** | Load balancing and reverse proxy | Nginx |

## 🏁 Quick Start

### Docker Compose (Recommended for development)

```bash
# Clone repository
git clone https://github.com/unifralabs/l2scan-stack-ce.git
cd l2scan-stack-ce/docker-compose

# Configure environment
cp .env.example .env
# Edit .env with your blockchain RPC URL

# Start services
make up

# Access the application
open http://localhost:3000

# Service endpoints
# - App: http://localhost:3000
# - Indexer API: http://localhost:8080  
# - Verifier API: http://localhost:8050
# - Database: localhost:5432
# - Redis: localhost:6379
```

### Kubernetes with Helm (Recommended for production)

```bash
# Create image pull secret (if using private images)
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_TOKEN

# Install directly from GitHub Container Registry (OCI)
helm install my-l2scan oci://ghcr.io/unifralabs/helm/l2scan-stack-ce \
  --version 0.1.0 \
  --set app.env.RPC="your-rpc-url" \
  --set app.env.DATABASE_URL="postgresql://user:pass@host:5432/dbname" \
  --set indexer.env.L2_RPC="your-rpc-url" \
  --set verifier.enabled=true \
  --set global.imagePullSecrets[0].name=ghcr-secret

# Or use example configurations
helm install my-l2scan oci://ghcr.io/unifralabs/helm/l2scan-stack-ce \
  --version 0.1.0 \
  -f https://raw.githubusercontent.com/unifralabs/l2scan-stack-ce/main/helm-chart/examples/production-values.yaml

# Access the application
kubectl port-forward svc/my-l2scan-l2scan-stack-app 3000:3000

# Verify deployment
kubectl get pods
kubectl get svc
```

### Kubernetes with Local Helm Chart (Development)

```bash
# Navigate to helm chart
cd l2scan-stack-ce/helm-chart

# Add required helm repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install dependencies
helm dependency build

# Create image pull secret (if using private images)
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_TOKEN

# Deploy with development configuration (recommended for first-time users)
helm install l2scan . -f examples/development-values.yaml \
  --set global.imagePullSecrets[0].name=ghcr-secret

# OR deploy with custom values
helm install l2scan . \
  --set app.env.RPC="your-rpc-url" \
  --set indexer.env.L2_RPC="your-rpc-url" \
  --set verifier.enabled=true \
  --set global.imagePullSecrets[0].name=ghcr-secret

# Access the application
kubectl port-forward svc/l2scan-l2scan-stack-ce-app 3000:3000

# Verify deployment
kubectl get pods
kubectl get svc
```

## 📋 Prerequisites

### Docker Compose Requirements
- Docker Engine 20.10+
- Docker Compose V2
- 8GB+ RAM
- 50GB+ storage space

### Kubernetes Requirements
- Kubernetes cluster 1.19+
- Helm 3.0+
- kubectl configured
- Persistent volume support

## 🔧 Configuration

### Essential Configuration

Create and configure your environment file:

```bash
# Copy example configuration
cp docker-compose/.env.example docker-compose/.env
```

Key configuration options:

```env
# Blockchain Configuration
RPC=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
L2_RPC=https://mainnet.infura.io/v3/YOUR_PROJECT_ID

# Database Configuration
DATABASE_URL=postgresql://l2scan:l2scan123@postgres:5432/l2scan
PGDSN=postgresql://l2scan:l2scan123@postgres:5432/l2scan

# Cache Configuration
REDIS_URL=redis://:redis123@redis:6379

# Contract Verification
VERIFICATION_URL=http://verifier:8050

# Indexer Settings
WORKER=1
CMC_API_KEY=your_coinmarketcap_api_key

# Environment
NODE_ENV=production
```

### Advanced Configuration

For Helm deployments, customize `values.yaml`:

```yaml
app:
  replicaCount: 1
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
  ingress:
    enabled: true
    hosts:
      - host: explorer.yourdomain.com
        paths:
          - path: /
            pathType: Prefix

indexer:
  replicaCount: 1
  env:
    L2_RPC: "https://your-l2-rpc-endpoint"
    WORKER: "2"
    CMC_API_KEY: "your-api-key"

verifier:
  enabled: true
  replicaCount: 1
  persistence:
    enabled: true
    size: 50Gi
  config:
    maxThreads: 8
```

## 💾 Data Persistence and Redeployment

### Data Persistence
By default, L2Scan preserves data across deployments:
- **PostgreSQL data** is stored in persistent volumes and will survive pod restarts and chart upgrades
- **Redis data** is also persisted and maintained
- **Indexed blockchain data** is preserved in PostgreSQL and indexing will resume from the last processed block

### Safe Redeployment
```bash
# To redeploy while keeping data (recommended)
helm upgrade l2scan . -f examples/development-values.yaml

# To completely reset and start fresh (DANGER: loses all data)
helm uninstall l2scan
kubectl delete pvc --all  # This permanently deletes all data
helm install l2scan . -f examples/development-values.yaml
```

## 🛠️ Management Commands

### Docker Compose Operations

```bash
# Start services
make up

# Development mode with admin tools
make dev

# View logs
make logs
make app-logs
make indexer-logs
make verifier-logs

# Database operations
make db-backup
make db-restore BACKUP=filename.sql

# Health checks
make health

# Stop services
make down

# Clean up everything
make clean
```

### Kubernetes Operations

```bash
# Deploy/upgrade
helm upgrade --install l2scan ./helm-chart -f values.yaml

# Check status
kubectl get pods -l app.kubernetes.io/name=l2scan-stack

# View logs
kubectl logs -f deployment/l2scan-app
kubectl logs -f deployment/l2scan-indexer
kubectl logs -f deployment/l2scan-verifier

# Scale services
kubectl scale deployment l2scan-app --replicas=3
kubectl scale deployment l2scan-indexer --replicas=2
kubectl scale deployment l2scan-verifier --replicas=2
```

### Kubernetes Deployment Details

#### Prerequisites
- Kubernetes cluster 1.19+
- Helm 3.0+
- kubectl configured to access your cluster
- Persistent volume support (for production)

#### Step-by-Step Deployment

1. **Prepare the environment**
   ```bash
   # Clone and navigate
   git clone https://github.com/unifralabs/l2scan-stack-ce.git
   cd l2scan-stack-ce/helm-chart
   
   # Download dependencies
   helm dependency build
   ```

2. **Configure authentication (for private images)**
   ```bash
   # Create image pull secret
   kubectl create secret docker-registry ghcr-secret \
     --docker-server=ghcr.io \
     --docker-username=YOUR_USERNAME \
     --docker-password=YOUR_TOKEN
   ```

3. **Create custom values file or use examples**
   ```bash
   # Use provided examples
   helm install l2scan . -f examples/production-values.yaml
   # OR create your own values file
   cp examples/production-values.yaml my-values.yaml
   # Edit my-values.yaml with your specific settings
   ```
   
   Example configuration structure:
   ```yaml
   # my-values.yaml
   app:
     env:
       RPC: "https://your-l2-rpc-endpoint"
        
   indexer:
     env:
       L2_RPC: "https://your-l2-rpc-endpoint"
       WORKER: "2"
       CMC_API_KEY: "your-coinmarketcap-api-key"
   
   verifier:
     enabled: true
     persistence:
       enabled: true
       size: 50Gi
   
   postgresql:
     enabled: true
     auth:
       postgresPassword: "secure-password"
       
   redis:
     enabled: true
     auth:
       password: "secure-redis-password"
   
   global:
     imagePullSecrets:
       - name: ghcr-secret
   ```

4. **Deploy the stack**
   ```bash
   helm install l2scan . -f production-values.yaml
   ```

5. **Verify deployment**
   ```bash
   # Check pod status
   kubectl get pods
   
   # Check services
   kubectl get svc
   
   # Test verifier service
   kubectl port-forward svc/l2scan-verifier 8050:8050 &
   curl http://localhost:8050/health
   
   # Access the app
   kubectl port-forward svc/l2scan-app 3000:3000
   ```

#### Common Issues and Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **ImagePullBackOff** | Pods stuck in ImagePullBackOff | Create and configure ImagePullSecret |
| **Pending Pods** | Pods stuck in Pending state | Check PV availability and resource quotas |
| **CrashLoopBackOff** | Pods restarting repeatedly | Check logs and database connectivity |
| **Failed Dependencies** | Helm install fails | Run `helm dependency build` first |

## 🔍 Monitoring and Debugging

### Service Health Checks

```bash
# App health
curl http://localhost:3000/api/health

# Indexer status (check logs)
docker-compose logs indexer

# Verifier health
curl http://localhost:8050/health

# Database health
docker-compose exec postgres pg_isready -U l2scan
```

### Development Tools (Docker Compose)

When using `make dev`, additional admin tools are available:

- **pgAdmin**: http://localhost:8081 (Database administration)
- **Redis Commander**: http://localhost:8082 (Redis management)

### Log Analysis

```bash
# Real-time logs for all services
make logs

# Service-specific logs
make app-logs
make indexer-logs
make verifier-logs
make postgres-logs
make redis-logs
```

## 🔒 Security Considerations

### Production Security Checklist

- [ ] Change default passwords in `.env` file
- [ ] Use secrets management for sensitive data
- [ ] Enable TLS/SSL for external access
- [ ] Configure firewall rules
- [ ] Regular security updates
- [ ] Container image scanning
- [ ] Database connection encryption

### Recommended Security Settings

```yaml
# values.yaml for Helm
app:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
  
networkPolicy:
  enabled: true
  
postgresql:
  auth:
    postgresPassword: "strong-random-password"
    
redis:
  auth:
    enabled: true
    password: "strong-redis-password"
```

## 📊 Performance Tuning

### Resource Allocation

```yaml
# Recommended production resources
app:
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi

indexer:
  resources:
    requests:
      cpu: 1000m
      memory: 2Gi
    limits:
      cpu: 2000m
      memory: 4Gi

verifier:
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
```

### Database Optimization

```yaml
postgresql:
  primary:
    configuration: |
      shared_buffers = 256MB
      effective_cache_size = 1GB
      checkpoint_completion_target = 0.9
      max_connections = 200
```

## 🐛 Troubleshooting

### Common Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Slow indexing** | Indexer falls behind blockchain | Increase `WORKER` count and check RPC connection |
| **App errors** | 500 errors, connection issues | Check database connectivity and logs |
| **Database locks** | Slow queries, timeouts | Restart database, check query performance |
| **Memory issues** | OOM kills, slow performance | Increase resource limits |
| **Verification errors** | Contract verification fails | Check verifier logs and compiler availability |
| **ImagePullBackOff (K8s)** | Kubernetes can't pull images | Create ImagePullSecret for private registries |
| **Helm dependency errors** | Missing PostgreSQL/Redis charts | Add bitnami repo: `helm repo add bitnami https://charts.bitnami.com/bitnami` then `helm dependency build` |

### Debug Commands

#### Docker Compose
```bash
# Check container health
docker-compose ps

# Inspect container details
docker inspect l2scan-app

# Check resource usage
docker stats

# Test verifier service
curl http://localhost:8050/health

# Network debugging
docker network ls
docker network inspect docker-compose_l2scan-network
```

#### Kubernetes
```bash
# Check pod status and events
kubectl get pods
kubectl describe pod <pod-name>

# Check logs
kubectl logs -f deployment/l2scan-app
kubectl logs -f deployment/l2scan-verifier

# Test services
kubectl port-forward svc/l2scan-verifier 8050:8050 &
curl http://localhost:8050/health

# Check resources
kubectl top pods
kubectl get pv,pvc

# Network debugging
kubectl get svc,ingress
kubectl describe service l2scan-verifier
```

## 📚 Documentation

- **[Complete Deployment Guide](docs/README.md)** - Detailed setup and configuration
- **[Helm OCI Registry Guide](docs/HELM_REPOSITORY.md)** - Install from GitHub Container Registry
- **[Docker Compose Guide](docker-compose/README.md)** - Docker-specific instructions
- **[Helm Chart Documentation](helm-chart/README.md)** - Local Kubernetes deployment details
- **[Configuration Examples](helm-chart/examples/)** - Ready-to-use deployment configurations
- **[Smart Contract Verifier Integration](docker-compose/smart-contract-verifier/)** - Verification service details

## 🔍 Smart Contract Verification

The integrated smart contract verifier supports multiple verification methods:

### Supported Features
- **Solidity Contract Verification** - Full source code verification with compiler version detection
- **Vyper Contract Verification** - Support for Vyper smart contracts
- **Sourcify Integration** - Automatic verification through Sourcify.dev
- **Multi-compiler Support** - Automatic downloading and management of compiler versions
- **RESTful API** - HTTP API for programmatic verification

### Verification Endpoints
- **Health Check**: `GET /health` - Service status
- **Solidity Verification**: `POST /verify/solidity` - Verify Solidity contracts
- **Vyper Verification**: `POST /verify/vyper` - Verify Vyper contracts  
- **Sourcify Verification**: `POST /verify/sourcify` - Verify via Sourcify

### Configuration
The verifier service is automatically configured and connected to your L2Scan instance:
- **Docker Compose**: `http://verifier:8050`
- **Kubernetes**: Auto-generated service URL
- **Storage**: Persistent compiler cache for performance

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the `docs/` directory for detailed guides
- **Issues**: Report bugs and request features via GitHub Issues
- **Discussions**: Join community discussions in GitHub Discussions

---

**Built with ❤️ for the blockchain community**

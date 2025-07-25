# L2Scan Stack CE

A comprehensive deployment solution for L2Scan blockchain explorer, providing both Kubernetes Helm charts and Docker Compose configurations for easy deployment and management.

## 🚀 Features

- **Complete Stack**: Frontend, indexer, database, and caching in one deployment
- **Flexible Deployment**: Support for both Docker Compose and Kubernetes
- **Production Ready**: Security, monitoring, and scaling configurations included
- **Developer Friendly**: Development environment with hot reloading and admin tools
- **Well Documented**: Comprehensive guides and configuration examples

## 📦 Components

| Component | Description | Technology |
|-----------|-------------|------------|
| **Frontend** | Web-based blockchain explorer interface | Next.js, React |
| **Indexer** | Blockchain data indexing service | Go |
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
```

### Kubernetes with Helm (Recommended for production)

```bash
# Navigate to helm chart
cd l2scan-stack-ce/helm-chart

# Install dependencies
helm dependency build

# Deploy with custom values
helm install l2scan . \
  --set frontend.env.RPC_URL="your-rpc-url" \
  --set frontend.ingress.enabled=true \
  --set frontend.ingress.hosts[0].host="your-domain.com"

# Access the application
kubectl port-forward svc/l2scan-frontend 3000:3000
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
RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
CHAIN_ID=1

# Indexer Settings
START_BLOCK=0
BATCH_SIZE=100
WORKER_COUNT=4

# Frontend Settings
NEXT_PUBLIC_SITE_URL=http://localhost:3000
NEXT_PUBLIC_CHAIN=1
```

### Advanced Configuration

For Helm deployments, customize `values.yaml`:

```yaml
frontend:
  replicaCount: 3
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
  replicaCount: 2
  env:
    RPC_URL: "https://your-rpc-endpoint"
    BATCH_SIZE: "200"
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
make frontend-logs
make indexer-logs

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
kubectl logs -f deployment/l2scan-frontend
kubectl logs -f deployment/l2scan-indexer

# Scale services
kubectl scale deployment l2scan-frontend --replicas=3
kubectl scale deployment l2scan-indexer --replicas=2
```

## 🔍 Monitoring and Debugging

### Service Health Checks

```bash
# Frontend health
curl http://localhost:3000/api/health

# Indexer health  
curl http://localhost:8080/health

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
make frontend-logs
make indexer-logs
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
frontend:
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
frontend:
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
| **Slow indexing** | Indexer falls behind blockchain | Increase `BATCH_SIZE` and `WORKER_COUNT` |
| **Frontend errors** | 500 errors, connection issues | Check database connectivity and logs |
| **Database locks** | Slow queries, timeouts | Restart database, check query performance |
| **Memory issues** | OOM kills, slow performance | Increase resource limits |

### Debug Commands

```bash
# Check container health
docker-compose ps

# Inspect container details
docker inspect l2scan-frontend

# Check resource usage
docker stats

# Network debugging
docker network ls
docker network inspect l2scan-stack-ce_l2scan-network
```

## 📚 Documentation

- **[Complete Deployment Guide](docs/README.md)** - Detailed setup and configuration
- **[Docker Compose Guide](docker-compose/README.md)** - Docker-specific instructions
- **[Helm Chart Documentation](helm-chart/README.md)** - Kubernetes deployment details
- **[Configuration Reference](docs/configuration.md)** - All configuration options

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

## 🔄 Roadmap

- [ ] Multi-chain support
- [ ] Advanced monitoring and alerting
- [ ] Automated scaling policies
- [ ] Enhanced security features
- [ ] CI/CD pipeline templates
- [ ] Cloud provider specific deployments (AWS, GCP, Azure)

---

**Built with ❤️ for the blockchain community**

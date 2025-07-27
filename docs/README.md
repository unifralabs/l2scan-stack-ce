# L2Scan Stack Deployment Guide

A complete deployment solution for L2Scan blockchain explorer using Kubernetes Helm charts and Docker Compose.

## Overview

L2Scan Stack includes:
- **Frontend**: Next.js web application for blockchain exploration
- **Indexer**: Go-based blockchain indexer service
- **PostgreSQL**: Database for storing blockchain data
- **Redis**: Caching and session storage
- **Nginx**: Reverse proxy and load balancer

## Quick Start

### Prerequisites

#### For Docker Compose
- Docker Engine 20.10+
- Docker Compose V2
- 8GB+ RAM recommended
- 50GB+ storage

#### For Kubernetes/Helm
- Kubernetes cluster 1.19+
- Helm 3.0+
- kubectl configured
- Persistent storage support

### Docker Compose Deployment

1. **Clone and Setup**
   ```bash
   git clone https://github.com/unifralabs/l2scan-stack-ce
   cd l2scan-stack-ce/docker-compose
   cp .env.example .env
   ```

2. **Configure Environment**
   Edit `.env` file with your blockchain configuration:
   ```bash
   # Frontend Required Variables
   DATABASE_URL=postgresql://l2scan:l2scan123@postgres:5432/l2scan
   RPC=http://10.2.0.76:8545
   REDIS_URL=redis://:redis123@redis:6379
   VERIFICATION_URL=https://your-verification-service.com

   # Backend (Indexer) Required Variables
   L1_RPC=http://10.2.0.13:8545
   L2_RPC=http://10.2.0.76:8545
   PGDSN=postgresql://l2scan:l2scan123@postgres:5432/l2scan
   WORKER=1
   CMC_API_KEY=
   ```

3. **Deploy Stack**
   ```bash
   # Production deployment
   make up
   
   # Development deployment (with admin tools)
   make dev
   ```

4. **Access Services**
   - Frontend: http://localhost:3000
   - Indexer API: http://localhost:8080
   - pgAdmin (dev): http://localhost:8081
   - Redis Commander (dev): http://localhost:8082

### Helm Deployment

1. **Add Dependencies**
   ```bash
   cd helm-chart
   helm dependency build
   ```

2. **Create Values File**
   ```bash
   cp values.yaml my-values.yaml
   # Edit my-values.yaml with your configuration
   ```

3. **Deploy to Kubernetes**
   ```bash
   helm install l2scan . -f my-values.yaml
   ```

4. **Access Services**
   ```bash
   kubectl get services
   kubectl port-forward svc/l2scan-frontend 3000:3000
   ```

## Configuration

### Environment Variables

#### Frontend Configuration
- `DATABASE_URL`: PostgreSQL connection string
- `RPC`: Layer 2 blockchain RPC endpoint
- `REDIS_URL`: Redis connection string
- `VERIFICATION_URL`: Contract verification service URL

#### Indexer Configuration
- `L1_RPC`: Layer 1 blockchain RPC endpoint
- `L2_RPC`: Layer 2 blockchain RPC endpoint
- `PGDSN`: PostgreSQL connection string
- `WORKER`: Number of concurrent workers
- `L1_FORCE_START_BLOCK`: Starting block for L1 indexing (optional)
- `L2_FORCE_START_BLOCK`: Starting block for L2 indexing (optional)
- `CHECK_MISMATCHED_BLOCKS`: Enable block mismatch checking (optional)
- `CMC_API_KEY`: CoinMarketCap API key

### Database Schema

The application uses Prisma for database management. Schema migrations are automatically applied on startup.

### Scaling Configuration

#### Docker Compose Scaling
```bash
docker-compose up -d --scale frontend=3 --scale indexer=2
```

#### Kubernetes Scaling
```yaml
frontend:
  replicaCount: 3
indexer:
  replicaCount: 2
```

## Operations

### Monitoring

#### Health Checks
```bash
# Docker Compose
make health

# Kubernetes
kubectl get pods
kubectl logs -l app.kubernetes.io/name=l2scan-stack
```

#### Logs
```bash
# Docker Compose
make logs
make frontend-logs
make indexer-logs

# Kubernetes
kubectl logs -f deployment/l2scan-frontend
kubectl logs -f deployment/l2scan-indexer
```

### Backup and Recovery

#### Database Backup
```bash
# Docker Compose
make db-backup

# Kubernetes
kubectl exec deployment/l2scan-postgresql -- pg_dump -U l2scan l2scan > backup.sql
```

#### Database Restore
```bash
# Docker Compose
make db-restore BACKUP=backup.sql

# Kubernetes
kubectl exec -i deployment/l2scan-postgresql -- psql -U l2scan -d l2scan < backup.sql
```

### Updates

#### Docker Compose Updates
```bash
make update
```

#### Helm Updates
```bash
helm upgrade l2scan . -f my-values.yaml
```

## Security

### Database Security
- Change default passwords in production
- Use secrets management for sensitive data
- Enable SSL/TLS for database connections

### Network Security
- Configure firewall rules
- Use TLS termination at load balancer
- Implement rate limiting

### Application Security
- Regular security updates
- Container image scanning
- RBAC configuration for Kubernetes

## Troubleshooting

### Common Issues

#### Frontend Won't Start
1. Check database connectivity
2. Verify environment variables
3. Check logs: `make frontend-logs`

#### Indexer Sync Issues
1. Verify RPC endpoint accessibility
2. Check blockchain network status
3. Monitor resource usage

#### Database Connection Issues
1. Verify PostgreSQL is running
2. Check connection string format
3. Ensure database exists

### Performance Tuning

#### Database Optimization
- Increase shared_buffers for PostgreSQL
- Optimize checkpoint settings
- Add custom indexes for frequent queries

#### Indexer Optimization
- Adjust batch size based on RPC limits
- Scale worker count based on CPU cores
- Monitor memory usage

## Development

### Local Development Setup
```bash
# Start development environment
make dev

# View logs
make dev-logs

# Access development tools
open http://localhost:8081  # pgAdmin
open http://localhost:8082  # Redis Commander
```

### Code Changes
The development setup includes hot reloading for both frontend and indexer services.

## Support

### Documentation
- [Frontend Documentation](../l2scan-ce/README.md)
- [Indexer Documentation](../l2scan-indexer-ce/README.md)
- [Helm Chart Values](../helm-chart/values.yaml)

### Getting Help
- Check logs for error messages
- Review configuration files
- Consult troubleshooting section

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
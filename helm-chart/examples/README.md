# Configuration Examples

This directory contains example configuration files for different deployment scenarios.

## Available Examples

### 1. Production Environment (`production-values.yaml`)
**Use case**: Production deployment with high availability and security

**Features**:
- ✅ Multiple replicas for high availability
- ✅ Persistent storage enabled
- ✅ Resource limits and requests configured
- ✅ Ingress with TLS enabled
- ✅ Internal PostgreSQL and Redis with production settings
- ✅ Security configurations (NetworkPolicy, ServiceAccount)

**Deployment**:
```bash
helm install l2scan . -f examples/production-values.yaml \
  --set app.env.RPC="https://your-l2-rpc-endpoint" \
  --set indexer.env.L2_RPC="https://your-l2-rpc-endpoint" \
  --set indexer.env.CMC_API_KEY="your-api-key" \
  --set postgresql.auth.postgresPassword="your-secure-password" \
  --set redis.auth.password="your-secure-password"
```

### 2. Development Environment (`development-values.yaml`)
**Use case**: Local development and testing

**Features**:
- ✅ Single replica for simplicity
- ✅ Minimal resource requirements
- ✅ No persistence (uses emptyDir)
- ✅ Simple passwords for development
- ✅ Network policies disabled
- ✅ Test RPC endpoints configured

**Deployment**:
```bash
helm install l2scan-dev . -f examples/development-values.yaml
```

### 3. External Database (`external-db-values.yaml`)
**Use case**: Using existing PostgreSQL and Redis instances

**Features**:
- ✅ Disables internal databases
- ✅ Configures external database connections
- ✅ Production-ready settings for services
- ✅ Verifier with persistent storage
- ✅ Security configurations enabled

**Deployment**:
```bash
helm install l2scan . -f examples/external-db-values.yaml \
  --set app.env.RPC="https://your-l2-rpc-endpoint" \
  --set app.env.DATABASE_URL="postgresql://user:pass@host:5432/db" \
  --set app.env.REDIS_URL="redis://:pass@host:6379" \
  --set indexer.env.L2_RPC="https://your-l2-rpc-endpoint" \
  --set indexer.env.PGDSN="postgresql://user:pass@host:5432/db"
```

## Customization

You can combine these examples or use them as starting points:

```bash
# Copy an example and customize it
cp examples/production-values.yaml my-values.yaml
# Edit my-values.yaml with your specific settings
helm install l2scan . -f my-values.yaml
```

## Common Customizations

### Setting RPC Endpoints
```yaml
app:
  env:
    RPC: "https://your-l2-rpc-endpoint"
indexer:
  env:
    L2_RPC: "https://your-l2-rpc-endpoint"
```

### Configuring Ingress
```yaml
app:
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: explorer.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: explorer-tls
        hosts:
          - explorer.yourdomain.com
```

### Scaling Services
```yaml
app:
  replicaCount: 3
indexer:
  replicaCount: 2
verifier:
  replicaCount: 1
```

### Resource Management
```yaml
app:
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
```

## Security Considerations

1. **Change default passwords** in production
2. **Use secrets** for sensitive data instead of plain text values
3. **Enable NetworkPolicy** for network isolation
4. **Configure ImagePullSecrets** for private registries
5. **Use TLS** for external access 
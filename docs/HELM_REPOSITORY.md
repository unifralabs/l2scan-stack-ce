# L2Scan Stack Helm Chart - OCI Registry

## 📦 Repository Information

- **OCI Registry**: `oci://ghcr.io/unifralabs/l2scan-stack`
- **Chart Name**: `l2scan-stack`
- **Source**: [GitHub Repository](https://github.com/unifralabs/l2scan-stack-ce)
- **Packages**: [GitHub Packages](https://github.com/unifralabs/l2scan-stack-ce/pkgs/container/l2scan-stack)

## 🚀 Quick Start

### Install L2Scan Stack

```bash
# Basic installation with external database
helm install my-l2scan oci://ghcr.io/unifralabs/l2scan-stack \
  --version 1.0.0 \
  --set l2scan-postgresql.enabled=false \
  --set l2scan-redis.enabled=false \
  --set app.env.DATABASE_URL="postgresql://user:pass@host:5432/dbname" \
  --set app.env.REDIS_URL="redis://:pass@host:6379" \
  --set app.env.RPC="your-rpc-endpoint" \
  --set indexer.env.L2_RPC="your-rpc-endpoint"

# Installation with included PostgreSQL and Redis
helm install my-l2scan oci://ghcr.io/unifralabs/l2scan-stack \
  --version 1.0.0 \
  --set l2scan-postgresql.enabled=true \
  --set l2scan-redis.enabled=true \
  --set app.env.RPC="your-rpc-endpoint" \
  --set indexer.env.L2_RPC="your-rpc-endpoint"
```

### View Available Versions

```bash
# List available versions on GitHub Packages
# Visit: https://github.com/unifralabs/l2scan-stack-ce/pkgs/container/l2scan-stack

# Or check GitHub Releases
# Visit: https://github.com/unifralabs/l2scan-stack-ce/releases
```

### Pull Chart Information

```bash
# Pull chart to local directory for inspection
helm pull oci://ghcr.io/unifralabs/l2scan-stack --version 1.0.0

# Extract and view
tar -xzf l2scan-stack-1.0.0.tgz
cat l2scan-stack/Chart.yaml
cat l2scan-stack/values.yaml
```

## 📋 Configuration Options

### Quick Configuration Examples

#### Development Setup
```bash
helm install l2scan-dev oci://ghcr.io/unifralabs/l2scan-stack \
  --version 1.0.0 \
  -f https://raw.githubusercontent.com/unifralabs/l2scan-stack-ce/main/helm-chart/examples/development-values.yaml
```

#### Production Setup
```bash
helm install l2scan-prod oci://ghcr.io/unifralabs/l2scan-stack \
  --version 1.0.0 \
  -f https://raw.githubusercontent.com/unifralabs/l2scan-stack-ce/main/helm-chart/examples/production-values.yaml
```

#### External Database Setup
```bash
helm install l2scan-external oci://ghcr.io/unifralabs/l2scan-stack \
  --version 1.0.0 \
  -f https://raw.githubusercontent.com/unifralabs/l2scan-stack-ce/main/helm-chart/examples/external-db-values.yaml \
  --set app.env.DATABASE_URL="your-database-url" \
  --set app.env.REDIS_URL="your-redis-url"
```

## 🔧 Essential Configuration

### Required Environment Variables

```yaml
app:
  env:
    RPC: "https://your-rpc-endpoint"           # Required: Blockchain RPC endpoint
    DATABASE_URL: "postgresql://..."          # Required: Database connection
    REDIS_URL: "redis://..."                  # Required: Redis connection

indexer:
  env:
    L2_RPC: "https://your-l2-rpc-endpoint"    # Required: L2 RPC endpoint
    PGDSN: "postgresql://..."                 # Required: Database connection
```

### Optional Configuration

```yaml
app:
  env:
    VERIFICATION_URL: "http://verifier:8050"  # Smart contract verification
    NODE_ENV: "production"                    # Environment mode

indexer:
  env:
    WORKER: "4"                               # Number of workers
    CMC_API_KEY: "your-cmc-key"              # CoinMarketCap API key

verifier:
  enabled: true                               # Enable smart contract verifier
```

### Private Registry Authentication

If using private images, create an image pull secret:

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_TOKEN

# Install with image pull secret
helm install my-l2scan oci://ghcr.io/unifralabs/l2scan-stack \
  --version 1.0.0 \
  --set global.imagePullSecrets[0].name=ghcr-secret \
  -f my-values.yaml
```

## 📊 Components

| Component | Description | Default Port |
|-----------|-------------|--------------|
| **App** | Web-based blockchain explorer | 3000 |
| **Indexer** | Blockchain data indexing service | 8080 |
| **Verifier** | Smart contract verification service | 8050/8051 |
| **PostgreSQL** | Database (optional) | 5432 |
| **Redis** | Cache (optional) | 6379 |

## 🔄 Upgrade

```bash
# Upgrade to a new version
helm upgrade my-l2scan oci://ghcr.io/unifralabs/l2scan-stack \
  --version 1.1.0

# Upgrade with new values
helm upgrade my-l2scan oci://ghcr.io/unifralabs/l2scan-stack \
  --version 1.1.0 \
  -f my-values.yaml
```

## 🗑️ Uninstalling

```bash
# Uninstall the release
helm uninstall my-l2scan

# Optional: Remove persistent volumes
kubectl delete pvc -l app.kubernetes.io/instance=my-l2scan
```

## 🆘 Troubleshooting

### Common Issues

1. **OCI Registry Access**: Ensure Helm 3.8+ for OCI support: `helm version`
2. **Version Not Found**: Check available versions at [GitHub Packages](https://github.com/unifralabs/l2scan-stack-ce/pkgs/container/l2scan-stack)
3. **Image Pull Errors**: Ensure you have created the `ghcr-secret` for private images
4. **Database Connection**: Verify your `DATABASE_URL` and network connectivity
5. **Resource Limits**: Check if your cluster has sufficient CPU/memory resources

### Helm OCI Support

Ensure you're using Helm 3.8+ for full OCI registry support:

```bash
# Check Helm version
helm version

# If needed, upgrade Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/unifralabs/l2scan-stack-ce/issues)
- **Discussions**: [GitHub Discussions](https://github.com/unifralabs/l2scan-stack-ce/discussions)
- **Documentation**: [Main README](../README.md)

## 📝 OCI Registry Benefits

Using GitHub Container Registry as OCI storage provides:

- ✅ **No GitHub Pages**: Simpler setup, no additional branch management
- ✅ **Unified Storage**: Charts and container images in one place
- ✅ **Private Support**: Native private repository support
- ✅ **Better Performance**: Direct registry pulls, no index.yaml parsing
- ✅ **Version Management**: Integrated with GitHub Packages UI

Charts are automatically published to:
**https://github.com/unifralabs/l2scan-stack-ce/pkgs/container/l2scan-stack**

Check the [Releases page](https://github.com/unifralabs/l2scan-stack-ce/releases) for version notes and changelog. 
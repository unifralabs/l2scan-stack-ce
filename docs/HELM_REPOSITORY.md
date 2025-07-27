# L2Scan Stack Helm Repository

## 📦 Repository Information

- **Repository URL**: `https://unifralabs.github.io/l2scan-stack-ce`
- **Chart Name**: `l2scan-stack`
- **Source**: [GitHub Repository](https://github.com/unifralabs/l2scan-stack-ce)

## 🚀 Quick Start

### Add the Helm Repository

```bash
helm repo add l2scan https://unifralabs.github.io/l2scan-stack-ce
helm repo update
```

### Install L2Scan Stack

```bash
# Basic installation with external database
helm install my-l2scan l2scan/l2scan-stack \
  --set postgresql.enabled=false \
  --set redis.enabled=false \
  --set app.env.DATABASE_URL="postgresql://user:pass@host:5432/dbname" \
  --set app.env.REDIS_URL="redis://:pass@host:6379"

# Installation with included PostgreSQL and Redis
helm install my-l2scan l2scan/l2scan-stack \
  --set postgresql.enabled=true \
  --set redis.enabled=true
```

### Search Available Versions

```bash
helm search repo l2scan
```

### View Chart Information

```bash
helm show chart l2scan/l2scan-stack
helm show values l2scan/l2scan-stack
```

## 📋 Configuration Options

### Quick Configuration Examples

#### Development Setup
```bash
helm install l2scan-dev l2scan/l2scan-stack \
  -f https://raw.githubusercontent.com/unifralabs/l2scan-stack-ce/main/helm-chart/examples/development-values.yaml
```

#### Production Setup
```bash
helm install l2scan-prod l2scan/l2scan-stack \
  -f https://raw.githubusercontent.com/unifralabs/l2scan-stack-ce/main/helm-chart/examples/production-values.yaml
```

#### External Database Setup
```bash
helm install l2scan-external l2scan/l2scan-stack \
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
# Update repository
helm repo update

# Upgrade installation
helm upgrade my-l2scan l2scan/l2scan-stack

# Upgrade with new values
helm upgrade my-l2scan l2scan/l2scan-stack \
  -f my-values.yaml
```

## 🗑️ Uninstall

```bash
helm uninstall my-l2scan
```

## 📖 Documentation

- [Main README](https://github.com/unifralabs/l2scan-stack-ce/blob/main/README.md)
- [Configuration Examples](https://github.com/unifralabs/l2scan-stack-ce/tree/main/helm-chart/examples)
- [Contributing Guide](https://github.com/unifralabs/l2scan-stack-ce/blob/main/CONTRIBUTING.md)

## 🐛 Support

- **Issues**: [GitHub Issues](https://github.com/unifralabs/l2scan-stack-ce/issues)
- **Discussions**: [GitHub Discussions](https://github.com/unifralabs/l2scan-stack-ce/discussions)
- **Documentation**: [Project Wiki](https://github.com/unifralabs/l2scan-stack-ce/wiki)

## 📝 Chart Releases

Chart releases are automatically published when new tags are created. Each release includes:

- Packaged Helm chart (`.tgz`)
- Updated repository index
- Release notes
- Changelog

Check the [Releases page](https://github.com/unifralabs/l2scan-stack-ce/releases) for available versions. 
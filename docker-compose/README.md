# L2Scan Stack - Docker Compose Deployment

This directory contains Docker Compose configuration for deploying L2Scan stack locally or in production environments.

## Quick Start

1. **Setup Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Start Services**
   ```bash
   make up
   ```
   
   The stack will automatically:
   - Start PostgreSQL and Redis
   - Run database initialization/migration
   - Start frontend and indexer services

3. **Access Services**
   - Frontend: http://localhost:3000
   - Indexer API: http://localhost:8080

## Database Initialization

The stack includes automatic database initialization using a dedicated init container (`ghcr.io/unifralabs/l2scan-ce-init:v0.0.10`). This ensures the database schema is properly set up before the main services start.

### Manual Database Operations

```bash
# Run database initialization manually (for troubleshooting)
make init-db

# Force database initialization (overwrites existing data)
make init-db-force

# View initialization logs
make db-migrate-logs
```

## Available Commands

```bash
make help          # Show all available commands
make up            # Start all services (includes automatic DB init)
make down          # Stop all services
make logs          # View all logs
make health        # Check service health
make init-db       # Run database initialization manually
make db-backup     # Backup database
make debug         # Show detailed debugging information
make clean         # Remove all containers and volumes
```

## Configuration

### Environment Variables

Edit `.env` file with your configuration:

```env
# Database Configuration (used by init container and services)
DATABASE_URL=postgresql://l2scan:l2scan123@postgres:5432/l2scan

# Frontend Required Variables
CHAIN_RPC_URL=http://10.2.0.76:8545
REDIS_URL=redis://:redis123@redis:6379
VERIFICATION_URL=https://your-verification-service.com

# Optional Frontend Branding (will use defaults if not set)
BRAND_NAME=L2Scan
BRAND_TITLE=L2Scan Blockchain Explorer
BRAND_DESCRIPTION=A powerful and user-friendly blockchain explorer for Layer 2 networks.
# BRAND_LOGO=/path/to/your/logo.svg
# BRAND_LOGO_DARK=/path/to/your/dark-logo.svg

# Optional Chain Configuration (will use defaults if not set)
CHAIN_ID=534352
CHAIN_BLOCK_EXPLORER_URL=https://your-explorer-url
CHAIN_CURRENCY_NAME=Ether
CHAIN_CURRENCY_SYMBOL=ETH
CHAIN_CURRENCY_DECIMALS=18

# Backend (Indexer) Required Variables
#L1_RPC=http://10.2.0.13:8545
L2_RPC=http://10.2.0.76:8545
PGDSN=postgresql://l2scan:l2scan123@postgres:5432/l2scan
WORKER=1
#L1_FORCE_START_BLOCK=17692169
#L2_FORCE_START_BLOCK=0
#CHECK_MISMATCHED_BLOCKS=true
CMC_API_KEY=your-coinmarketcap-api-key
```

### Service Scaling

Scale services horizontally:

```bash
docker-compose up -d --scale frontend=3 --scale indexer=2
```

## Service Architecture

```
┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │     Indexer     │
│   (Port 3000)   │    │   (Port 8080)   │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────┬───────────┘
                     │
         ┌─────────────────┐    ┌─────────────────┐
         │   PostgreSQL    │    │      Redis      │
         │   (Port 5432)   │    │   (Port 6379)   │
         └─────────────────┘    └─────────────────┘
                     │
         ┌─────────────────┐
         │   DB Init       │
         │   (Run once)    │
         └─────────────────┘
```

## Troubleshooting

### Service Won't Start

1. Check overall status and logs:
   ```bash
   make debug
   ```

2. Check specific service logs:
   ```bash
   make frontend-logs
   make indexer-logs
   make postgres-logs
   make db-migrate-logs
   ```

3. Verify configuration:
   ```bash
   cat .env
   ```

### Database Issues

1. Check initialization logs:
   ```bash
   make db-migrate-logs
   ```

2. Re-run initialization:
   ```bash
   make init-db
   ```

3. Reset database completely:
   ```bash
   make down
   docker volume rm l2scan-stack-ce_postgres_data
   make up
   ```

### Network Issues

Check container networking:
```bash
docker network ls
docker network inspect l2scan-stack-ce_l2scan-network
```

## Images Used

- **Frontend**: `ghcr.io/unifralabs/l2scan-ce:v0.0.10` - Main Next.js application
- **Database Init**: `ghcr.io/unifralabs/l2scan-ce-init:v0.0.10` - Lightweight init container for database setup
- **Indexer**: `ghcr.io/unifralabs/l2scan-indexer-ce:main` - Backend indexing service
- **PostgreSQL**: `postgres:15-alpine` - Database
- **Redis**: `redis:7-alpine` - Cache and session store

## Performance Optimization

### Resource Limits

Edit `docker-compose.yml` to add resource limits:

```yaml
services:
  frontend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 1G
```

### PostgreSQL Tuning

Create `postgres.conf` and mount it:

```yaml
volumes:
  - ./postgres.conf:/etc/postgresql/postgresql.conf
```

Example `postgres.conf`:
```
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
```

## Backup and Restore

### Automatic Backups

```bash
# Create backup
make db-backup

# Restore from backup
make db-restore BACKUP=l2scan-20240101_120000.sql
```

### Manual Operations

```bash
# Manual database dump
docker-compose exec postgres pg_dump -U l2scan l2scan > backup.sql

# Manual restore
docker-compose exec -T postgres psql -U l2scan -d l2scan < backup.sql
```

## Security Considerations

### Production Deployment

1. Change default passwords in `.env`
2. Use external database in production
3. Enable SSL/TLS termination
4. Configure firewall rules
5. Regular security updates

### SSL Configuration

1. Obtain SSL certificates
2. Place certificates in `nginx/ssl/`
3. Uncomment HTTPS server block in `nginx/nginx.conf`
4. Update docker-compose to expose port 443

## Monitoring

### Health Checks

Built-in health checks for all services:

```bash
# Overall health
make health

# Individual service health
curl http://localhost:3000/api/health
curl http://localhost:8080/health
```

### Logs Analysis

```bash
# Real-time logs
make logs

# Service-specific logs
make frontend-logs
make indexer-logs
make postgres-logs
make redis-logs

# Log files location
docker-compose logs frontend > frontend.log
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Deploy L2Scan Stack
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy Stack
        run: |
          cd docker-compose
          cp .env.example .env
          echo "RPC_URL=${{ secrets.RPC_URL }}" >> .env
          make up
```

### Custom Images

The stack uses pre-built images from GitHub Container Registry:
- `ghcr.io/unifralabs/l2scan-ce:v0.0.10` - Main application
- `ghcr.io/unifralabs/l2scan-indexer-ce:main` - Blockchain indexer  
- `ghcr.io/unifralabs/l2scan-ce-init:v0.0.10` - Database initialization

These images are automatically pulled when running `make up`.
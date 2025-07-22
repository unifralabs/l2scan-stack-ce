# L2Scan Stack - Docker Compose Deployment

This directory contains Docker Compose configuration for deploying L2Scan stack locally or in development environments.

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

3. **Access Services**
   - Frontend: http://localhost:3000
   - Indexer API: http://localhost:8080
   - Nginx Proxy: http://localhost

## Development Mode

For development with admin tools:

```bash
make dev
```

Additional services in development mode:
- pgAdmin: http://localhost:8081 (admin@l2scan.com / admin123)
- Redis Commander: http://localhost:8082

## Available Commands

```bash
make help          # Show all available commands
make up            # Start production stack
make dev           # Start development stack
make down          # Stop all services
make logs          # View all logs
make health        # Check service health
make db-backup     # Backup database
make clean         # Remove all containers and volumes
```

## Configuration

### Environment Variables

Edit `.env` file with your configuration:

```env
# Frontend Required Variables
DATABASE_URL=postgresql://l2scan:l2scan123@postgres:5432/l2scan
RPC=http://10.2.0.76:8545
REDIS_URL=redis://:redis123@redis:6379
VERIFICATION_URL=https://your-verification-service.com

# Backend (Indexer) Required Variables
L1_RPC=http://10.2.0.13:8545
L2_RPC=http://10.2.0.76:8545
PGDSN=postgres://postgres:mysecretpassword@10.100.1.6:5432/linea
WORKER=1
# L1_FORCE_START_BLOCK=17692169
# L2_FORCE_START_BLOCK=0
# CHECK_MISMATCHED_BLOCKS=true
CMC_API_KEY=
```

### Service Scaling

Scale services horizontally:

```bash
docker-compose up -d --scale frontend=3 --scale indexer=2
```

## Troubleshooting

### Service Won't Start

1. Check logs:
   ```bash
   make logs
   make frontend-logs
   make indexer-logs
   ```

2. Check service status:
   ```bash
   make status
   ```

3. Verify configuration:
   ```bash
   cat .env
   ```

### Database Issues

Reset database:
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

### Build Custom Images

```bash
# Build images from source
cd ../scripts
./build-images.sh

# Use custom images
make up
```
# L2Scan Stack Helm Chart

This Helm chart deploys L2Scan blockchain explorer stack on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support for persistent volumes

## Installation

### Add Dependencies

```bash
helm dependency build
```

### Install Chart

```bash
# Basic installation
helm install l2scan .

# With custom values
helm install l2scan . -f my-values.yaml

# With inline values
helm install l2scan . \
  --set app.env.RPC="https://mainnet.infura.io/v3/YOUR_KEY" \
  --set app.ingress.enabled=true
```

### Upgrade

```bash
helm upgrade l2scan . -f values.yaml
```

### Uninstall

```bash
helm uninstall l2scan
```

## Configuration

### Common Configurations

#### External Database

```yaml
postgresql:
  enabled: false

app:
  env:
    DATABASE_URL: "postgresql://user:pass@external-db:5432/l2scan"

indexer:
  env:
    DATABASE_URL: "postgresql://user:pass@external-db:5432/l2scan"
```

#### Ingress Configuration

```yaml
app:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
      nginx.ingress.kubernetes.io/rate-limit: "100"
    hosts:
      - host: explorer.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: l2scan-tls
        hosts:
          - explorer.yourdomain.com
```

#### Resource Configuration

```yaml
app:
  replicaCount: 3
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi

indexer:
  replicaCount: 2
  resources:
    requests:
      cpu: 1000m
      memory: 2Gi
    limits:
      cpu: 2000m
      memory: 4Gi
```

#### Storage Configuration

```yaml
global:
  storageClass: "fast-ssd"

postgresql:
  primary:
    persistence:
      size: 500Gi
      storageClass: "fast-ssd"

redis:
  master:
    persistence:
      size: 50Gi
```

### Security Configuration

#### Pod Security

```yaml
app:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    fsGroup: 1001

podSecurityPolicy:
  enabled: true

networkPolicy:
  enabled: true
```

#### RBAC

```yaml
rbac:
  create: true

serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/l2scan-role
```

## Values Reference

### Global Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global image registry | `""` |
| `global.imagePullSecrets` | Global pull secrets | `[]` |
| `global.storageClass` | Global storage class | `""` |

### Frontend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.enabled` | Enable app deployment | `true` |
| `app.replicaCount` | Number of replicas | `1` |
| `app.image.repository` | Image repository | `l2scan/app` |
| `app.image.tag` | Image tag | `latest` |
| `app.service.type` | Service type | `ClusterIP` |
| `app.service.port` | Service port | `3000` |
| `app.ingress.enabled` | Enable ingress | `false` |

### Indexer Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `indexer.enabled` | Enable indexer deployment | `true` |
| `indexer.replicaCount` | Number of replicas | `1` |
| `indexer.image.repository` | Image repository | `l2scan/indexer` |
| `indexer.image.tag` | Image tag | `latest` |
| `indexer.env.RPC_URL` | Blockchain RPC URL | `""` |
| `indexer.env.BATCH_SIZE` | Indexing batch size | `"100"` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Enable PostgreSQL | `true` |
| `postgresql.auth.database` | Database name | `l2scan` |
| `postgresql.auth.username` | Database user | `l2scan` |
| `postgresql.primary.persistence.size` | Storage size | `100Gi` |

## Monitoring and Observability

### Health Checks

All services include health checks:

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=l2scan-stack-ce

# Check service health
kubectl exec deployment/l2scan-app -- wget -qO- http://localhost:3000/api/health
kubectl exec deployment/l2scan-indexer -- wget -qO- http://localhost:8080/health
```

### Logs

```bash
# Application logs
kubectl logs -f deployment/l2scan-app
kubectl logs -f deployment/l2scan-indexer

# Database logs  
kubectl logs -f deployment/l2scan-postgresql
```

### Metrics Collection

#### Prometheus Integration

```yaml
# values.yaml
postgresql:
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true

redis:
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
```

## Scaling

### Horizontal Pod Autoscaling

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: l2scan-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: l2scan-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Vertical Pod Autoscaling

```yaml
# vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: l2scan-indexer-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: l2scan-indexer
  updatePolicy:
    updateMode: "Auto"
```

## Backup and Disaster Recovery

### Database Backup

```bash
# Create backup job
kubectl create job --from=cronjob/postgres-backup backup-$(date +%Y%m%d-%H%M%S)

# Manual backup
kubectl exec deployment/l2scan-postgresql -- pg_dump -U l2scan l2scan > backup.sql
```

### Restore Procedure

```bash
# Scale down applications
kubectl scale deployment l2scan-app --replicas=0
kubectl scale deployment l2scan-indexer --replicas=0

# Restore database
kubectl exec -i deployment/l2scan-postgresql -- psql -U l2scan -d l2scan < backup.sql

# Scale up applications
kubectl scale deployment l2scan-app --replicas=3
kubectl scale deployment l2scan-indexer --replicas=2
```

## Troubleshooting

### Common Issues

#### Pods Not Starting

```bash
# Check pod events
kubectl describe pod <pod-name>

# Check resource constraints
kubectl top pods
kubectl describe nodes
```

#### Database Connection Issues

```bash
# Test database connectivity
kubectl exec deployment/l2scan-app -- nc -zv l2scan-postgresql 5432

# Check database logs
kubectl logs deployment/l2scan-postgresql
```

#### Performance Issues

```bash
# Check resource usage
kubectl top pods
kubectl top nodes

# Check storage performance
kubectl describe pv
kubectl describe pvc
```

### Debug Commands

```bash
# Get all resources
kubectl get all -l app.kubernetes.io/instance=l2scan

# Port forward for local access
kubectl port-forward svc/l2scan-app 3000:3000
kubectl port-forward svc/l2scan-indexer 8080:8080

# Exec into containers
kubectl exec -it deployment/l2scan-app -- /bin/sh
kubectl exec -it deployment/l2scan-indexer -- /bin/sh
```

## Production Considerations

### Security

- Use external secrets management (e.g., AWS Secrets Manager, HashiCorp Vault)
- Enable network policies
- Configure pod security standards
- Regular security updates

### Performance

- Use SSD storage for database
- Configure appropriate resource requests/limits
- Enable horizontal pod autoscaling
- Use dedicated node pools for database

### Reliability

- Multi-zone deployment
- Database replication
- Regular backups
- Monitoring and alerting
- Circuit breakers for external dependencies

## Support

For issues and questions:
- Check the troubleshooting section
- Review pod logs and events
- Consult the main documentation
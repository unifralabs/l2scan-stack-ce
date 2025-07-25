# L2Scan Stack Docker Compose Makefile

.PHONY: help up down restart logs build clean status shell-frontend shell-indexer shell-postgres backup restore init-db

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Environment setup
.env:
	@if [ ! -f .env ]; then \
		echo "Creating .env file from .env.example..."; \
		cp .env.example .env; \
		echo "Please edit .env file with your configuration"; \
	fi

# Production deployment
up: .env ## Start all services (includes automatic database initialization)
	docker-compose up -d

down: ## Stop all services
	docker-compose down

restart: ## Restart all services
	docker-compose restart

logs: ## Show logs for all services
	docker-compose logs -f

build: ## Build all images
	docker-compose build --no-cache

clean: ## Remove all containers, networks, and volumes
	docker-compose down -v --remove-orphans
	docker system prune -f

# Database operations
init-db: .env ## Run database initialization manually (for troubleshooting)
	docker-compose run --rm db-migrate

init-db-force: .env ## Force database initialization (overwrites existing data)
	docker-compose run --rm db-migrate ./scripts/init-db.sh --force

# Service management
status: ## Show status of all services
	docker-compose ps

frontend-logs: ## Show frontend service logs
	docker-compose logs -f frontend

indexer-logs: ## Show indexer service logs
	docker-compose logs -f indexer

postgres-logs: ## Show postgres service logs
	docker-compose logs -f postgres

redis-logs: ## Show redis service logs
	docker-compose logs -f redis

db-migrate-logs: ## Show database migration logs
	docker-compose logs db-migrate

# Shell access
shell-frontend: ## Access frontend container shell
	docker-compose exec frontend /bin/sh

shell-indexer: ## Access indexer container shell
	docker-compose exec indexer /bin/sh

shell-postgres: ## Access postgres container shell
	docker-compose exec postgres psql -U l2scan -d l2scan

shell-redis: ## Access redis container shell
	docker-compose exec redis redis-cli -a redis123

# Database operations
db-backup: ## Create database backup
	@mkdir -p backups
	docker-compose exec postgres pg_dump -U l2scan l2scan > backups/l2scan-$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Database backup created in backups/ directory"

db-restore: ## Restore database from backup (usage: make db-restore BACKUP=filename.sql)
	@if [ -z "$(BACKUP)" ]; then \
		echo "Usage: make db-restore BACKUP=filename.sql"; \
		exit 1; \
	fi
	docker-compose exec -T postgres psql -U l2scan -d l2scan < backups/$(BACKUP)

# Monitoring
health: ## Check health of all services
	@echo "Checking service health..."
	@curl -s http://localhost:3000/api/health || echo "Frontend: UNHEALTHY"
	@curl -s http://localhost:8080/health || echo "Indexer: UNHEALTHY"
	@docker-compose exec postgres pg_isready -U l2scan || echo "Postgres: UNHEALTHY"
	@docker-compose exec redis redis-cli -a redis123 ping || echo "Redis: UNHEALTHY"

# Update images
update: ## Pull latest images and restart services
	docker-compose pull
	docker-compose up -d

# Troubleshooting
debug: ## Show detailed information for debugging
	@echo "=== Service Status ==="
	docker-compose ps
	@echo ""
	@echo "=== Recent Init Logs ==="
	docker-compose logs --tail=20 db-migrate || echo "No init logs available"
	@echo ""
	@echo "=== Service Health ==="
	make health
# L2Scan Stack Docker Compose Makefile

.PHONY: help up down restart logs build clean dev prod status shell-frontend shell-indexer shell-postgres backup restore

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
up: .env ## Start all services in production mode
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

# Development deployment  
dev: .env ## Start all services in development mode
	docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

dev-logs: ## Show logs for development services
	docker-compose -f docker-compose.yml -f docker-compose.override.yml logs -f

dev-down: ## Stop development services
	docker-compose -f docker-compose.yml -f docker-compose.override.yml down

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

# Production deployment with SSL
prod-ssl: .env ## Deploy with SSL support (requires SSL certificates)
	@echo "Make sure SSL certificates are in docker-compose/nginx/ssl/"
	@read -p "Continue? [y/N]: " confirm && [ "$$confirm" = "y" ]
	docker-compose -f docker-compose.yml -f docker-compose.ssl.yml up -d
.PHONY: help start stop restart status logs clean rebuild \
        postgres redis bash-backend bash-frontend bash-db \
        install-backend install-frontend health tasks backup

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

help:
	@echo "$(BLUE)================================$(NC)"
	@echo "$(BLUE)Docker Compose Helper$(NC)"
	@echo "$(BLUE)================================$(NC)"
	@echo ""
	@echo "$(GREEN)Service Management:$(NC)"
	@echo "  make start              - Start all services"
	@echo "  make stop               - Stop all services"
	@echo "  make restart            - Restart all services"
	@echo "  make status             - Show service status"
	@echo "  make clean              - Remove all containers and volumes"
	@echo "  make rebuild            - Rebuild images and start"
	@echo ""
	@echo "$(GREEN)Monitoring & Logs:$(NC)"
	@echo "  make logs               - View all logs"
	@echo "  make logs-backend       - View backend logs"
	@echo "  make logs-frontend      - View frontend logs"
	@echo "  make logs-db            - View database logs"
	@echo "  make health             - Check API health"
	@echo "  make tasks              - Fetch tasks from API"
	@echo ""
	@echo "$(GREEN)Database Operations:$(NC)"
	@echo "  make postgres           - Connect to PostgreSQL"
	@echo "  make redis              - Connect to Redis"
	@echo "  make backup             - Backup database"
	@echo ""
	@echo "$(GREEN)Shell Access:$(NC)"
	@echo "  make bash-backend       - Access backend shell"
	@echo "  make bash-frontend      - Access frontend shell"
	@echo "  make bash-db            - Access database shell"
	@echo ""
	@echo "$(GREEN)Dependencies:$(NC)"
	@echo "  make install-backend    - Install backend deps"
	@echo "  make install-frontend   - Install frontend deps"

start:
	@echo "$(BLUE)Starting services...$(NC)"
	docker-compose up -d
	@sleep 5
	@echo "$(GREEN)✓ Services started$(NC)"
	@$(MAKE) status

stop:
	@echo "$(BLUE)Stopping services...$(NC)"
	docker-compose stop
	@echo "$(GREEN)✓ Services stopped$(NC)"

restart:
	@echo "$(BLUE)Restarting services...$(NC)"
	docker-compose restart
	@sleep 5
	@echo "$(GREEN)✓ Services restarted$(NC)"
	@$(MAKE) status

status:
	@echo "$(BLUE)Service Status:$(NC)"
	@docker-compose ps

logs:
	docker-compose logs -f

logs-backend:
	docker-compose logs -f backend

logs-frontend:
	docker-compose logs -f frontend

logs-db:
	docker-compose logs -f postgres

logs-redis:
	docker-compose logs -f redis

clean:
	@echo "$(RED)Warning: This will remove all containers and volumes$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "$(GREEN)✓ Cleaned all containers and volumes$(NC)"; \
	fi

rebuild:
	@echo "$(BLUE)Rebuilding services...$(NC)"
	docker-compose down
	docker-compose up -d --build
	@sleep 5
	@echo "$(GREEN)✓ Services rebuilt and started$(NC)"
	@$(MAKE) status

postgres:
	docker exec -it taskapp_db psql -U postgres -d taskdb

redis:
	docker exec -it taskapp_redis redis-cli

bash-backend:
	docker exec -it taskapp_backend /bin/sh

bash-frontend:
	docker exec -it taskapp_frontend /bin/sh

bash-db:
	docker exec -it taskapp_db /bin/bash

install-backend:
	@echo "$(BLUE)Installing backend dependencies...$(NC)"
	docker exec taskapp_backend npm install
	@echo "$(GREEN)✓ Backend dependencies installed$(NC)"

install-frontend:
	@echo "$(BLUE)Installing frontend dependencies...$(NC)"
	docker exec taskapp_frontend npm install
	@echo "$(GREEN)✓ Frontend dependencies installed$(NC)"

health:
	@echo "$(BLUE)Checking API health...$(NC)"
	@curl -s http://localhost:5000/api/health | jq '.'

tasks:
	@echo "$(BLUE)Fetching tasks...$(NC)"
	@curl -s http://localhost:5000/api/tasks | jq '.'

backup:
	@echo "$(BLUE)Backing up database...$(NC)"
	@docker exec taskapp_db pg_dump -U postgres taskdb > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Database backed up$(NC)"

ps:
	docker-compose ps

build:
	docker-compose build

build-backend:
	docker-compose build backend

build-frontend:
	docker-compose build frontend

pull:
	docker-compose pull

push:
	docker-compose push

down:
	docker-compose down

up:
	docker-compose up

prune:
	docker system prune -f
	docker volume prune -f

.DEFAULT_GOAL := help
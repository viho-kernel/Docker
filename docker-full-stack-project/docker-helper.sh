#!/bin/bash

# Docker Compose Helper Script
# Usage: ./docker-helper.sh [command]

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Commands
start_services() {
    print_header "Starting Services"
    docker-compose up -d
    print_success "All services started"
    sleep 5
    show_status
}

stop_services() {
    print_header "Stopping Services"
    docker-compose stop
    print_success "All services stopped"
}

restart_services() {
    print_header "Restarting Services"
    docker-compose restart
    print_success "All services restarted"
    sleep 5
    show_status
}

show_status() {
    print_header "Service Status"
    docker-compose ps
}

show_logs() {
    print_header "Service Logs"
    docker-compose logs -f "${1:-}"
}

clean_all() {
    print_header "Cleaning Everything"
    print_info "This will remove all containers and volumes (data will be lost)"
    read -p "Are you sure? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose down -v
        print_success "Cleaned all containers and volumes"
    else
        print_info "Cleanup cancelled"
    fi
}

rebuild_services() {
    print_header "Rebuilding Services"
    docker-compose down
    docker-compose up -d --build
    print_success "Services rebuilt and started"
    sleep 5
    show_status
}

connect_postgres() {
    print_header "Connecting to PostgreSQL"
    docker exec -it taskapp_db psql -U postgres -d taskdb
}

connect_redis() {
    print_header "Connecting to Redis"
    docker exec -it taskapp_redis redis-cli
}

bash_backend() {
    print_header "Bash Shell - Backend"
    docker exec -it taskapp_backend /bin/sh
}

bash_frontend() {
    print_header "Bash Shell - Frontend"
    docker exec -it taskapp_frontend /bin/sh
}

bash_database() {
    print_header "Bash Shell - Database"
    docker exec -it taskapp_db /bin/bash
}

install_deps_backend() {
    print_header "Installing Backend Dependencies"
    docker exec taskapp_backend npm install
    print_success "Backend dependencies installed"
}

install_deps_frontend() {
    print_header "Installing Frontend Dependencies"
    docker exec taskapp_frontend npm install
    print_success "Frontend dependencies installed"
}

show_api_health() {
    print_header "API Health Check"
    curl -s http://localhost:5000/api/health | jq '.'
}

show_tasks() {
    print_header "Fetching Tasks from API"
    curl -s http://localhost:5000/api/tasks | jq '.'
}

db_backup() {
    print_header "Backing up Database"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="backup_${TIMESTAMP}.sql"
    docker exec taskapp_db pg_dump -U postgres taskdb > "$BACKUP_FILE"
    print_success "Database backed up to $BACKUP_FILE"
}

db_restore() {
    if [ -z "$1" ]; then
        print_error "Please provide backup file path"
        echo "Usage: ./docker-helper.sh db-restore <backup_file.sql>"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        print_error "File not found: $1"
        exit 1
    fi
    
    print_header "Restoring Database"
    print_info "This will overwrite current database"
    read -p "Are you sure? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker exec -i taskapp_db psql -U postgres taskdb < "$1"
        print_success "Database restored from $1"
    else
        print_info "Restore cancelled"
    fi
}

show_help() {
    cat << EOF
${BLUE}Docker Compose Helper Script${NC}

Usage: ./docker-helper.sh [command]

${GREEN}Service Management:${NC}
  start              Start all services
  stop               Stop all services
  restart            Restart all services
  status             Show service status
  clean              Stop and remove all containers and volumes
  rebuild            Rebuild images and start services

${GREEN}Monitoring & Logs:${NC}
  logs [service]     View logs (all or specific service)
                     Examples: logs, logs backend, logs frontend
  health             Check API health
  tasks              Fetch tasks from API

${GREEN}Database Operations:${NC}
  postgres           Connect to PostgreSQL CLI
  redis              Connect to Redis CLI
  backup             Backup PostgreSQL database
  restore [file]     Restore from backup file
                     Example: restore backup_20240101_120000.sql

${GREEN}Shell Access:${NC}
  bash-backend       Access backend bash shell
  bash-frontend      Access frontend bash shell
  bash-db            Access database bash shell

${GREEN}Dependencies:${NC}
  install-backend    Install/update backend dependencies
  install-frontend   Install/update frontend dependencies

${GREEN}Other:${NC}
  help               Show this help message

${YELLOW}Examples:${NC}
  ./docker-helper.sh start
  ./docker-helper.sh logs backend
  ./docker-helper.sh bash-backend
  ./docker-helper.sh backup
  ./docker-helper.sh restore backup_20240101_120000.sql

EOF
}

# Main script
case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    clean)
        clean_all
        ;;
    rebuild)
        rebuild_services
        ;;
    postgres)
        connect_postgres
        ;;
    redis)
        connect_redis
        ;;
    bash-backend)
        bash_backend
        ;;
    bash-frontend)
        bash_frontend
        ;;
    bash-db)
        bash_database
        ;;
    install-backend)
        install_deps_backend
        ;;
    install-frontend)
        install_deps_frontend
        ;;
    health)
        show_api_health
        ;;
    tasks)
        show_tasks
        ;;
    backup)
        db_backup
        ;;
    restore)
        db_restore "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
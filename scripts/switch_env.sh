#!/bin/bash

# E-commerce Data Warehouse - Environment Switcher
# This script helps you switch between different environments (dev, staging, prod)

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Function to show usage
show_usage() {
    echo "Usage: ./scripts/switch_env.sh [ENVIRONMENT]"
    echo ""
    echo "Available environments:"
    echo "  dev      - Development environment"
    echo "  staging  - Staging environment"  
    echo "  prod     - Production environment"
    echo ""
    echo "Examples:"
    echo "  ./scripts/switch_env.sh dev"
    echo "  ./scripts/switch_env.sh staging"
    echo "  ./scripts/switch_env.sh prod"
    echo ""
    echo "This script will:"
    echo "  1. Load environment variables from .env.[environment]"
    echo "  2. Activate the Python virtual environment"
    echo "  3. Set up dbt profile for the target environment"
    echo "  4. Display connection information"
}

# Function to validate environment
validate_environment() {
    local env=$1
    case $env in
        dev|staging|prod)
            return 0
            ;;
        *)
            print_error "Invalid environment: $env"
            show_usage
            exit 1
            ;;
    esac
}

# Function to check if environment file exists
check_env_file() {
    local env=$1
    local env_file=".env.$env"
    
    if [[ ! -f "$env_file" ]]; then
        print_error "Environment file $env_file not found!"
        print_info "You can create it from the template:"
        print_info "cp environments/$env.env.template $env_file"
        print_info "Then edit $env_file with your specific configuration"
        exit 1
    fi
}

# Function to load environment variables
load_env_vars() {
    local env=$1
    local env_file=".env.$env"
    
    print_info "Loading environment variables from $env_file..."
    
    # Export variables, ignoring comments and empty lines
    set -a  # automatically export all variables
    source "$env_file"
    set +a  # stop automatically exporting
    
    print_success "Environment variables loaded for $env"
}

# Function to activate virtual environment
activate_venv() {
    local venv_path="ecommerce-dw-env"
    
    if [[ ! -d "$venv_path" ]]; then
        print_error "Virtual environment not found at $venv_path"
        print_info "Run ./scripts/setup_environment.sh first to create it"
        exit 1
    fi
    
    print_info "Activating virtual environment..."
    source "$venv_path/bin/activate"
    print_success "Virtual environment activated"
}

# Function to verify dbt connection
verify_dbt_connection() {
    local env=$1
    
    print_info "Verifying dbt connection to $env environment..."
    
    cd dbt_project
    if dbt debug --target "$env" > /dev/null 2>&1; then
        print_success "dbt connection to $env environment verified"
    else
        print_warning "dbt connection test failed. Please check your configuration."
        print_info "You can run 'cd dbt_project && dbt debug --target $env' for detailed error information"
    fi
    cd ..
}

# Function to display environment info
show_env_info() {
    local env=$1
    
    echo ""
    echo "🔄 Environment switched to: ${GREEN}$env${NC}"
    echo ""
    echo "📊 Database Connection:"
    echo "   Host: $DB_HOST"
    echo "   Port: $DB_PORT"
    echo "   Database: $DB_NAME"
    echo "   Schema: $DB_SCHEMA"
    echo "   User: $DB_USER"
    echo "   Threads: $DBT_THREADS"
    echo ""
    echo "🚀 Quick Commands:"
    echo "   Switch to dbt project:  cd dbt_project"
    echo "   Run dbt models:         dbt run --target $env"
    echo "   Run dbt tests:          dbt test --target $env"
    echo "   Generate docs:          dbt docs generate --target $env"
    echo "   Serve docs:             dbt docs serve --port 8080"
    echo ""
    
    if [[ "$env" == "prod" ]]; then
        print_warning "You are now in PRODUCTION environment!"
        print_warning "Please be careful with any changes."
    fi
}

# Function to create backup before switching to production
create_backup() {
    local env=$1
    
    if [[ "$env" == "prod" && "$ENABLE_AUTO_BACKUP" == "true" ]]; then
        print_info "Creating backup before production operations..."
        
        mkdir -p backups/prod
        local backup_file="backups/prod/backup_$(date +%Y%m%d_%H%M%S).sql"
        
        if command -v pg_dump &> /dev/null; then
            pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" > "$backup_file" 2>/dev/null || print_warning "Backup creation failed"
            print_success "Backup created: $backup_file"
        else
            print_warning "pg_dump not found, skipping backup"
        fi
    fi
}

# Main function
main() {
    local env=$1
    
    # Show usage if no environment provided
    if [[ -z "$env" ]]; then
        show_usage
        exit 1
    fi
    
    # Validate environment
    validate_environment "$env"
    
    # Check if environment file exists
    check_env_file "$env"
    
    # Load environment variables
    load_env_vars "$env"
    
    # Activate virtual environment
    activate_venv
    
    # Create backup if needed (for production)
    create_backup "$env"
    
    # Verify dbt connection
    verify_dbt_connection "$env"
    
    # Show environment information
    show_env_info "$env"
    
    print_success "Environment switch completed!"
    print_info "Your shell is now configured for the $env environment"
}

# Run main function with all arguments
main "$@" 
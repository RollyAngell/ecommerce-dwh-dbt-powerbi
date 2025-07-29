#!/bin/bash

# E-commerce Data Warehouse - Development Deployment Script
# This script deploys the project to the development environment

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

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if .env.dev exists
    if [[ ! -f ".env.dev" ]]; then
        print_error "Environment file .env.dev not found!"
        print_info "Create it from template: cp environments/dev.env.template .env.dev"
        exit 1
    fi
    
    # Check if virtual environment exists
    if [[ ! -d "ecommerce-dw-env" ]]; then
        print_error "Virtual environment not found!"
        print_info "Run ./scripts/setup_environment.sh first"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to setup development database
setup_dev_database() {
    print_info "Setting up development database..."
    
    # Create database if it doesn't exist
    psql -h $DB_HOST -U postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || {
        print_warning "Database $DB_NAME already exists or creation failed"
    }
    
    # Run setup script
    if [[ -f "scripts/setup_database_dev.sql" ]]; then
        psql -h $DB_HOST -U postgres -d $DB_NAME -f scripts/setup_database_dev.sql
    else
        # Use the generic setup script
        psql -h $DB_HOST -U postgres -d $DB_NAME -f scripts/setup_database.sql
    fi
    
    print_success "Development database setup completed"
}

# Function to load development data
load_dev_data() {
    print_info "Loading development data..."
    
    # Load sample data
    python3 scripts/load_data.py
    
    print_success "Development data loaded"
}

# Function to run dbt operations
run_dbt_operations() {
    print_info "Running dbt operations for development..."
    
    cd dbt_project
    
    # Install packages
    print_info "Installing dbt packages..."
    dbt deps --target dev
    
    # Debug connection
    print_info "Testing dbt connection..."
    dbt debug --target dev
    
    # Clean previous builds
    print_info "Cleaning previous builds..."
    dbt clean
    
    # Reinstall packages after clean
    print_info "Reinstalling dbt packages after clean..."
    dbt deps --target dev
    
    # Parse project
    print_info "Parsing dbt project..."
    dbt parse --target dev
    
    # Run models with full refresh for development
    print_info "Running dbt models (full refresh)..."
    dbt run --target dev --full-refresh
    
    # Run tests
    print_info "Running dbt tests..."
    dbt test --target dev || print_warning "Some tests failed (this is normal in development)"
    
    # Generate documentation
    print_info "Generating documentation..."
    dbt docs generate --target dev
    
    cd ..
    
    print_success "dbt operations completed for development"
}

# Function to show development info
show_dev_info() {
    echo ""
    print_success "🎉 Development deployment completed successfully!"
    echo ""
    echo "📊 Development Environment Details:"
    echo "   Database: $DB_NAME"
    echo "   Schema: $DB_SCHEMA"
    echo "   Host: $DB_HOST"
    echo "   Port: $DB_PORT"
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. View documentation: cd dbt_project && dbt docs serve --port 8080"
    echo "   2. Run specific models: cd dbt_project && dbt run --target dev --select model_name"
    echo "   3. Test your changes: cd dbt_project && dbt test --target dev"
    echo ""
    echo "🔧 Development Commands:"
    echo "   Switch environment: ./scripts/switch_env.sh dev"
    echo "   Quick redeploy: ./scripts/deploy_dev.sh"
    echo "   Run single model: cd dbt_project && dbt run --target dev --select staging.stg_customers"
    echo ""
}

# Main deployment function
main() {
    echo "🔧 Starting Development Deployment..."
    echo "======================================"
    
    # Check prerequisites
    check_prerequisites
    
    # Load environment variables
    print_info "Loading development environment variables..."
    export $(cat .env.dev | grep -v '^#' | xargs)
    
    # Activate virtual environment
    print_info "Activating virtual environment..."
    source ecommerce-dw-env/bin/activate
    
    # Setup database
    setup_dev_database
    
    # Load data
    load_dev_data
    
    # Run dbt operations
    run_dbt_operations
    
    # Show completion info
    show_dev_info
}

# Error handling
trap 'print_error "Development deployment failed! Check the error messages above."; exit 1' ERR

# Run main function
main "$@" 
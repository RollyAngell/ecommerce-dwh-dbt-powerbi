#!/bin/bash

# E-commerce Data Warehouse - Staging Deployment Script
# This script deploys the project to the staging environment

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
    print_info "Checking prerequisites for staging deployment..."
    
    # Check if .env.staging exists
    if [[ ! -f ".env.staging" ]]; then
        print_error "Environment file .env.staging not found!"
        print_info "Create it from template: cp environments/staging.env.template .env.staging"
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

# Function to create backup
create_backup() {
    if [[ "$ENABLE_AUTO_BACKUP" == "true" ]]; then
        print_info "Creating staging backup..."
        
        mkdir -p backups/staging
        local backup_file="backups/staging/staging_backup_$(date +%Y%m%d_%H%M%S).sql"
        
        if command -v pg_dump &> /dev/null; then
            pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" > "$backup_file" 2>/dev/null || {
                print_warning "Backup creation failed, continuing deployment"
            }
            print_success "Backup created: $backup_file"
        else
            print_warning "pg_dump not found, skipping backup"
        fi
    fi
}

# Function to setup staging database
setup_staging_database() {
    print_info "Setting up staging database..."
    
    # Create database if it doesn't exist
    psql -h $DB_HOST -U postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || {
        print_warning "Database $DB_NAME already exists or creation failed"
    }
    
    # Run setup script
    if [[ -f "scripts/setup_database_staging.sql" ]]; then
        psql -h $DB_HOST -U postgres -d $DB_NAME -f scripts/setup_database_staging.sql
    else
        # Use the generic setup script
        psql -h $DB_HOST -U postgres -d $DB_NAME -f scripts/setup_database.sql
    fi
    
    print_success "Staging database setup completed"
}

# Function to load staging data
load_staging_data() {
    print_info "Loading staging data..."
    
    # Load sample data (larger dataset for staging)
    python3 scripts/load_data.py
    
    print_success "Staging data loaded"
}

# Function to run comprehensive dbt operations
run_dbt_operations() {
    print_info "Running comprehensive dbt operations for staging..."
    
    cd dbt_project
    
    # Install packages
    print_info "Installing dbt packages..."
    dbt deps --target staging
    
    # Debug connection
    print_info "Testing dbt connection..."
    dbt debug --target staging
    
    # Compile project to check for errors
    print_info "Compiling dbt project..."
    dbt compile --target staging
    
    # Run models
    print_info "Running dbt models..."
    dbt run --target staging
    
    # Run ALL tests including extended ones
    print_info "Running comprehensive tests..."
    if [[ "$RUN_EXTENDED_TESTS" == "true" ]]; then
        dbt test --target staging --store-failures
    else
        dbt test --target staging
    fi
    
    # Run data quality checks
    print_info "Running data quality checks..."
    dbt run-operation check_data_quality --target staging || print_warning "Data quality checks not available"
    
    # Generate documentation
    print_info "Generating documentation..."
    dbt docs generate --target staging
    
    cd ..
    
    print_success "dbt operations completed for staging"
}

# Function to run data validation
run_data_validation() {
    print_info "Running data validation tests..."
    
    cd dbt_project
    
    # Check for data freshness
    print_info "Checking data freshness..."
    dbt source freshness --target staging || print_warning "Freshness checks failed"
    
    # Run specific staging validation tests
    print_info "Running staging-specific tests..."
    dbt test --target staging --select tag:staging || print_warning "Some staging tests failed"
    
    cd ..
    
    print_success "Data validation completed"
}

# Function to send notifications
send_notifications() {
    local status=$1
    local message=$2
    
    if [[ "$ENABLE_SLACK_NOTIFICATIONS" == "true" && -n "$SLACK_WEBHOOK_URL" ]]; then
        print_info "Sending Slack notification..."
        
        local emoji="✅"
        if [[ "$status" != "success" ]]; then
            emoji="❌"
        fi
        
        local payload="{\"text\": \"$emoji Staging Deployment: $message\"}"
        
        curl -X POST -H 'Content-type: application/json' \
             --data "$payload" \
             "$SLACK_WEBHOOK_URL" &>/dev/null || print_warning "Slack notification failed"
    fi
    
    if [[ "$ENABLE_EMAIL_NOTIFICATIONS" == "true" && -n "$EMAIL_ALERTS" ]]; then
        print_info "Email notifications configured but not implemented in this script"
    fi
}

# Function to show staging info
show_staging_info() {
    echo ""
    print_success "🎉 Staging deployment completed successfully!"
    echo ""
    echo "📊 Staging Environment Details:"
    echo "   Database: $DB_NAME"
    echo "   Schema: $DB_SCHEMA" 
    echo "   Host: $DB_HOST"
    echo "   Port: $DB_PORT"
    echo "   Backup Retention: $BACKUP_RETENTION_DAYS days"
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. View documentation: cd dbt_project && dbt docs serve --port 8081"
    echo "   2. Run QA tests: cd dbt_project && dbt test --target staging"
    echo "   3. Review test results in: dbt_project/target/"
    echo ""
    echo "🔧 Staging Commands:"
    echo "   Switch environment: ./scripts/switch_env.sh staging"
    echo "   Redeploy: ./scripts/deploy_staging.sh"
    echo "   Deploy to prod: ./scripts/deploy_prod.sh (after QA approval)"
    echo ""
}

# Function to run pre-deployment checks
run_pre_deployment_checks() {
    print_info "Running pre-deployment checks..."
    
    # Check if development tests pass
    print_info "Verifying development tests pass first..."
    cd dbt_project
    
    # Switch to dev temporarily to check
    export DBT_TARGET_TEMP=$DBT_ENV
    export DBT_ENV=dev
    
    if [[ -f "../.env.dev" ]]; then
        source ../.env.dev
        dbt test --target dev > /dev/null 2>&1 || {
            print_warning "Development tests are failing. Consider fixing them before staging deployment."
        }
    fi
    
    # Switch back to staging
    export DBT_ENV=$DBT_TARGET_TEMP
    source ../.env.staging
    
    cd ..
    
    print_success "Pre-deployment checks completed"
}

# Main deployment function
main() {
    echo "🚀 Starting Staging Deployment..."
    echo "=================================="
    
    # Check prerequisites
    check_prerequisites
    
    # Load environment variables
    print_info "Loading staging environment variables..."
    export $(cat .env.staging | grep -v '^#' | xargs)
    
    # Activate virtual environment
    print_info "Activating virtual environment..."
    source ecommerce-dw-env/bin/activate
    
    # Run pre-deployment checks
    run_pre_deployment_checks
    
    # Create backup
    create_backup
    
    # Setup database
    setup_staging_database
    
    # Load data
    load_staging_data
    
    # Run dbt operations
    run_dbt_operations
    
    # Run data validation
    run_data_validation
    
    # Send success notification
    send_notifications "success" "Staging deployment completed successfully"
    
    # Show completion info
    show_staging_info
}

# Error handling
trap 'send_notifications "failure" "Staging deployment failed"; print_error "Staging deployment failed! Check the error messages above."; exit 1' ERR

# Run main function
main "$@" 
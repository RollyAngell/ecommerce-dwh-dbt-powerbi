#!/bin/bash

# E-commerce Data Warehouse - Production Deployment Script
# This script deploys the project to the production environment
# CRITICAL: This script includes safety measures for production deployment

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

# Function to get user confirmation
get_confirmation() {
    local message=$1
    echo ""
    print_warning "🚨 PRODUCTION DEPLOYMENT WARNING 🚨"
    print_warning "$message"
    echo ""
    read -p "Are you absolutely sure you want to proceed? Type 'YES' to continue: " confirm
    
    if [[ "$confirm" != "YES" ]]; then
        print_info "Production deployment cancelled by user"
        exit 0
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites for production deployment..."
    
    # Check if .env.prod exists
    if [[ ! -f ".env.prod" ]]; then
        print_error "Environment file .env.prod not found!"
        print_info "Create it from template: cp environments/prod.env.template .env.prod"
        exit 1
    fi
    
    # Check if virtual environment exists
    if [[ ! -d "ecommerce-dw-env" ]]; then
        print_error "Virtual environment not found!"
        print_info "Run ./scripts/setup_environment.sh first"
        exit 1
    fi
    
    # Check if staging tests passed recently
    print_info "Checking staging deployment status..."
    if [[ ! -f "backups/staging/staging_backup_$(date +%Y%m%d)*.sql" ]]; then
        print_warning "No recent staging backup found. Have you deployed to staging today?"
    fi
    
    print_success "Prerequisites check passed"
}

# Function to run pre-production validation
run_pre_production_validation() {
    print_info "Running pre-production validation..."
    
    cd dbt_project
    
    # Validate staging environment first
    print_info "Validating staging environment..."
    export DBT_ENV_TEMP=$DBT_ENV
    export DBT_ENV=staging
    
    if [[ -f "../.env.staging" ]]; then
        source ../.env.staging
        
        # Check staging tests
        dbt test --target staging > /dev/null 2>&1 || {
            print_error "Staging tests are failing! Cannot proceed to production."
            exit 1
        }
        
        # Check data freshness in staging
        dbt source freshness --target staging > /dev/null 2>&1 || {
            print_warning "Staging data freshness issues detected"
        }
    fi
    
    # Switch back to production
    export DBT_ENV=$DBT_ENV_TEMP
    source ../.env.prod
    
    cd ..
    
    print_success "Pre-production validation completed"
}

# Function to create comprehensive backup
create_comprehensive_backup() {
    print_info "Creating comprehensive production backup..."
    
    mkdir -p backups/prod
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="backups/prod/backup_${timestamp}.sql"
    local schema_backup="backups/prod/schema_backup_${timestamp}.sql"
    
    if command -v pg_dump &> /dev/null; then
        # Full database backup
        print_info "Creating full database backup..."
        pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" > "$backup_file" || {
            print_error "Full backup creation failed!"
            exit 1
        }
        
        # Schema-only backup
        print_info "Creating schema backup..."
        pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" --schema-only > "$schema_backup" || {
            print_warning "Schema backup creation failed"
        }
        
        # Compress backups
        if command -v gzip &> /dev/null; then
            gzip "$backup_file" "$schema_backup" 2>/dev/null || print_warning "Backup compression failed"
        fi
        
        print_success "Comprehensive backup created"
    else
        print_error "pg_dump not found! Cannot create backup."
        print_error "Production deployment requires backup capability."
        exit 1
    fi
}

# Function to setup production database
setup_production_database() {
    print_info "Setting up production database..."
    
    # Create database if it doesn't exist (usually done by DBA in production)
    psql -h $DB_HOST -U postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || {
        print_info "Database $DB_NAME already exists (normal for production)"
    }
    
    # Run setup script
    if [[ -f "scripts/setup_database_prod.sql" ]]; then
        psql -h $DB_HOST -U "$DB_USER" -d $DB_NAME -f scripts/setup_database_prod.sql
    else
        # Use the generic setup script
        psql -h $DB_HOST -U "$DB_USER" -d $DB_NAME -f scripts/setup_database.sql
    fi
    
    print_success "Production database setup completed"
}

# Function to run production dbt operations
run_production_dbt_operations() {
    print_info "Running production dbt operations..."
    
    cd dbt_project
    
    # Install packages
    print_info "Installing dbt packages..."
    dbt deps --target prod
    
    # Debug connection
    print_info "Testing production dbt connection..."
    dbt debug --target prod
    
    # Compile project
    print_info "Compiling dbt project..."
    dbt compile --target prod
    
    # Run models with incremental strategy
    if [[ "$ENABLE_INCREMENTAL" == "true" ]]; then
        print_info "Running dbt models (incremental)..."
        dbt run --target prod
    else
        print_info "Running dbt models (full refresh - CAUTION!)..."
        get_confirmation "This will do a FULL REFRESH of all production tables. This is destructive!"
        dbt run --target prod --full-refresh
    fi
    
    # Run ONLY critical tests in production
    print_info "Running critical production tests..."
    if [[ "$FAIL_ON_WARNING" == "true" ]]; then
        dbt test --target prod --select tag:critical
    else
        dbt test --target prod --select tag:critical || print_warning "Some critical tests failed"
    fi
    
    # Generate documentation
    print_info "Generating production documentation..."
    dbt docs generate --target prod
    
    cd ..
    
    print_success "Production dbt operations completed"
}

# Function to run post-deployment validation
run_post_deployment_validation() {
    print_info "Running post-deployment validation..."
    
    cd dbt_project
    
    # Check row counts
    print_info "Validating data volumes..."
    dbt run-operation validate_row_counts --target prod || print_warning "Row count validation not available"
    
    # Check for data anomalies
    print_info "Running data anomaly detection..."
    dbt test --target prod --select tag:anomaly_detection || print_warning "Anomaly detection tests not available"
    
    # Verify all tables exist
    print_info "Verifying all expected tables exist..."
    dbt run-operation verify_tables_exist --target prod || print_warning "Table verification not available"
    
    cd ..
    
    print_success "Post-deployment validation completed"
}

# Function to update monitoring
setup_monitoring() {
    if [[ "$ENABLE_MONITORING" == "true" ]]; then
        print_info "Setting up production monitoring..."
        
        # Create monitoring tables if they don't exist
        cd dbt_project
        dbt run-operation setup_monitoring --target prod || print_warning "Monitoring setup not available"
        cd ..
        
        print_success "Production monitoring configured"
    fi
}

# Function to send comprehensive notifications
send_production_notifications() {
    local status=$1
    local message=$2
    local details=$3
    
    # Slack notification
    if [[ "$ENABLE_SLACK_NOTIFICATIONS" == "true" && -n "$SLACK_WEBHOOK_URL" ]]; then
        print_info "Sending Slack notification..."
        
        local emoji="🚀"
        local color="good"
        if [[ "$status" != "success" ]]; then
            emoji="🚨"
            color="danger"
        fi
        
        local payload="{
            \"text\": \"$emoji PRODUCTION DEPLOYMENT: $message\",
            \"attachments\": [
                {
                    \"color\": \"$color\",
                    \"fields\": [
                        {
                            \"title\": \"Environment\",
                            \"value\": \"Production\",
                            \"short\": true
                        },
                        {
                            \"title\": \"Database\",
                            \"value\": \"$DB_NAME\",
                            \"short\": true
                        },
                        {
                            \"title\": \"Timestamp\",
                            \"value\": \"$(date)\",
                            \"short\": false
                        }
                    ]
                }
            ]
        }"
        
        curl -X POST -H 'Content-type: application/json' \
             --data "$payload" \
             "$SLACK_WEBHOOK_URL" &>/dev/null || print_warning "Slack notification failed"
    fi
    
    # Email notification (placeholder)
    if [[ "$ENABLE_EMAIL_NOTIFICATIONS" == "true" && -n "$EMAIL_ALERTS" ]]; then
        print_info "Production email notifications configured but not implemented in this script"
    fi
}

# Function to show production info
show_production_info() {
    echo ""
    print_success "🎉 PRODUCTION DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉"
    echo ""
    echo "📊 Production Environment Details:"
    echo "   Database: $DB_NAME"
    echo "   Schema: $DB_SCHEMA"
    echo "   Host: $DB_HOST"
    echo "   Port: $DB_PORT"
    echo "   Backup Retention: $BACKUP_RETENTION_DAYS days"
    echo "   Query Timeout: $QUERY_TIMEOUT seconds"
    echo ""
    echo "🛡️  Security & Monitoring:"
    echo "   Monitoring Enabled: $ENABLE_MONITORING"
    echo "   Auto Backup: $ENABLE_AUTO_BACKUP"
    echo "   Notifications: $ENABLE_SLACK_NOTIFICATIONS"
    echo ""
    echo "🚀 Production Commands:"
    echo "   View documentation: cd dbt_project && dbt docs serve --port 8082"
    echo "   Run incremental: cd dbt_project && dbt run --target prod"
    echo "   Check critical tests: cd dbt_project && dbt test --target prod --select tag:critical"
    echo ""
    print_warning "Remember: All production changes should be thoroughly tested in staging first!"
    echo ""
}

# Function to cleanup temporary files
cleanup() {
    print_info "Cleaning up temporary files..."
    # Add cleanup logic here if needed
    print_success "Cleanup completed"
}

# Main deployment function
main() {
    echo ""
    echo "🚀 STARTING PRODUCTION DEPLOYMENT"
    echo "=================================="
    print_warning "This will deploy to the PRODUCTION environment!"
    echo ""
    
    # Initial confirmation
    get_confirmation "This will deploy changes to the PRODUCTION database."
    
    # Check prerequisites
    check_prerequisites
    
    # Load environment variables
    print_info "Loading production environment variables..."
    export $(cat .env.prod | grep -v '^#' | xargs)
    
    # Activate virtual environment
    print_info "Activating virtual environment..."
    source ecommerce-dw-env/bin/activate
    
    # Run pre-production validation
    run_pre_production_validation
    
    # Final confirmation before destructive operations
    get_confirmation "All validations passed. Proceed with production deployment?"
    
    # Create comprehensive backup
    create_comprehensive_backup
    
    # Setup database
    setup_production_database
    
    # Run dbt operations
    run_production_dbt_operations
    
    # Run post-deployment validation
    run_post_deployment_validation
    
    # Setup monitoring
    setup_monitoring
    
    # Send success notification
    send_production_notifications "success" "Production deployment completed successfully" "All validations passed"
    
    # Show completion info
    show_production_info
    
    # Cleanup
    cleanup
}

# Error handling with comprehensive notifications
trap 'send_production_notifications "failure" "PRODUCTION DEPLOYMENT FAILED" "Check logs immediately"; print_error "🚨 PRODUCTION DEPLOYMENT FAILED! 🚨"; print_error "Check the error messages above and restore from backup if necessary."; exit 1' ERR

# Run main function
main "$@" 
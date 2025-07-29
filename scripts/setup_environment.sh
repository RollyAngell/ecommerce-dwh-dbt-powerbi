#!/bin/bash

# E-commerce Data Warehouse - Environment Setup Script
# This script sets up the complete environment for the project

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

echo "🏗️  Setting up E-commerce Data Warehouse environment..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is required but not installed. Please install Python 3.8+"
    exit 1
fi

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    print_error "PostgreSQL is required but not installed."
    print_info "Please install PostgreSQL and ensure it's running."
    print_info "macOS: brew install postgresql"
    print_info "Ubuntu: sudo apt-get install postgresql postgresql-contrib"
    exit 1
fi

print_success "Prerequisites check passed"

# Create Python virtual environment with project-specific name
print_info "Creating Python virtual environment (ecommerce-dw-env)..."
if [[ ! -d "ecommerce-dw-env" ]]; then
    python3 -m venv ecommerce-dw-env
    print_success "Virtual environment created"
else
    print_info "Virtual environment already exists"
fi

# Activate virtual environment
print_info "Activating virtual environment..."
source ecommerce-dw-env/bin/activate

# Install Python dependencies
print_info "Installing Python dependencies..."
pip install --upgrade pip
pip install -r dbt_project/requirements.txt
pip install -r scripts/requirements.txt

# Create necessary directories
print_info "Creating project directories..."
mkdir -p logs
mkdir -p reports
mkdir -p backups/{dev,staging,prod}

# Setup environment files from templates
print_info "Setting up environment configuration files..."

# Create .env files from templates if they don't exist
for env in dev staging prod; do
    if [[ ! -f ".env.$env" ]]; then
        print_info "Creating .env.$env from template..."
        cp "environments/$env.env.template" ".env.$env"
        print_warning "Please edit .env.$env with your specific configuration"
    else
        print_info ".env.$env already exists"
    fi
done

# Setup PostgreSQL databases for all environments
print_info "Setting up PostgreSQL databases..."
print_warning "You may be prompted for PostgreSQL superuser password multiple times"

# Setup development database
print_info "Setting up development database..."
psql -U postgres -c "CREATE DATABASE ecommerce_dw_dev;" 2>/dev/null || print_info "Development database already exists"

# Setup staging database  
print_info "Setting up staging database..."
psql -U postgres -c "CREATE DATABASE ecommerce_dw_staging;" 2>/dev/null || print_info "Staging database already exists"

# Run database setup script for development (as example)
print_info "Running database setup script for development..."
psql -U postgres -d ecommerce_dw_dev -f scripts/setup_database.sql

print_info "Loading sample data into development database..."
# Load environment variables for development
export $(cat .env.dev | grep -v '^#' | xargs) 2>/dev/null || print_warning "Could not load .env.dev variables"
python3 scripts/load_data.py

print_info "Setting up dbt profile..."
mkdir -p ~/.dbt
cp dbt_project/profiles.yml ~/.dbt/profiles.yml

print_info "Installing dbt packages..."
cd dbt_project
dbt deps
cd ..

print_success "✅ Environment setup completed!"
echo ""
print_info "🚀 Next Steps:"
echo "   1. Edit environment files:"
echo "      - .env.dev (development configuration)"
echo "      - .env.staging (staging configuration)" 
echo "      - .env.prod (production configuration)"
echo ""
echo "   2. Switch to development environment:"
echo "      ./scripts/switch_env.sh dev"
echo ""
echo "   3. Deploy to development:"
echo "      ./scripts/deploy_dev.sh"
echo ""
echo "   4. After testing, deploy to staging:"
echo "      ./scripts/deploy_staging.sh"
echo ""
echo "   5. Finally, deploy to production:"
echo "      ./scripts/deploy_prod.sh"
echo ""
print_info "🔧 Environment Management Commands:"
echo "   Switch environments: ./scripts/switch_env.sh [dev|staging|prod]"
echo "   Monitor production: ./scripts/monitor_prod.py"
echo ""
print_warning "Remember to configure your database credentials in the .env files!"
echo ""
print_success "Setup completed successfully! 🎉" 
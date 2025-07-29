# E-commerce Data Warehouse with PostgreSQL, dbt and Power BI

A complete Data Warehouse project for e-commerce using modern data analysis tools. This project implements a star schema optimized for sales analysis, customer behavior and product performance.

## Project Objectives

- **Data modeling**: Implement a star schema with dimensions and facts
- **Transformation**: Use dbt for reproducible and testable transformations
- **Automation**: Scripts for configuration and automated execution
- **Documentation**: Complete documentation of data models
- **Visualization**: Ready-to-use dashboards for Power BI

## Quick Start (15 minutes)

### Prerequisites
```bash
# Verify Python (requires 3.8+) and PostgreSQL (requires 12+)
python3 --version && psql --version

# If you don't have them:
# macOS: brew install python postgresql
# Ubuntu: sudo apt-get install python3 postgresql postgresql-contrib
```

### Express Installation
```bash
# 1. Clone and enter the project
git clone https://github.com/RollyAngell/ecommerce-dwh-dbt-powerbi.git
cd ecommerce-dwh-dbt-powerbi

# 2. Configure PostgreSQL
psql -U postgres -c "CREATE DATABASE ecommerce_dw;"
psql -U postgres -d ecommerce_dw -f scripts/setup_database.sql

# 3. Configure Python
python3 -m venv ecommerce-dw-env
source ecommerce-dw-env/bin/activate
pip install -r dbt_project/requirements.txt
pip install -r scripts/requirements.txt

# 4. Load data
python3 scripts/load_data.py

# 5. Run dbt
mkdir -p ~/.dbt
cp dbt_project/profiles.yml ~/.dbt/profiles.yml
cd dbt_project
dbt deps && dbt run && dbt test && dbt docs generate
```

### Quick Verification
```sql
-- Connect to PostgreSQL and verify data
psql -U postgres -d ecommerce_dw

SELECT 'customers' as table_name, count(*) FROM analytics.dim_customers
UNION ALL SELECT 'products', count(*) FROM analytics.dim_products  
UNION ALL SELECT 'orders', count(*) FROM analytics.fct_orders
UNION ALL SELECT 'visits', count(*) FROM analytics.fct_visits;
```

**Expected result**:
```
 table_name | count 
------------+-------
 customers  |    20
 products   |    25
 orders     |    30
 visits     |    30
```

### Access Documentation
```bash
# Serve dbt documentation
dbt docs serve
# Open: http://localhost:8080
```

---

## Multi-Environment Architecture Deployment

This project supports a complete 3-environment architecture: Development, Staging, and Production.

### Environment Setup Prerequisites

#### Required Software
- **Python 3.8+**: `python3 --version`
- **PostgreSQL 12+**: `psql --version`
- **Git**: `git --version`

#### Software Installation

**macOS:**
```bash
brew install python postgresql git
brew services start postgresql
```

**Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install python3 python3-pip postgresql postgresql-contrib git
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Complete Multi-Environment Deployment

#### STEP 1: Initial Setup

```bash
# 1. Clone the repository (if you don't have it)
git clone https://github.com/RollyAngell/ecommerce-dwh-dbt-powerbi.git
cd ecommerce-dwh-dbt-powerbi

# 2. Run automatic setup
./scripts/setup_environment.sh
```

**What does setup_environment.sh do?**
- ✅ Verifies dependencies (Python, PostgreSQL)
- ✅ Creates virtual environment `ecommerce-dw-env`
- ✅ Installs Python dependencies
- ✅ Creates necessary directories (logs, reports, backups)
- ✅ Generates `.env` files from templates
- ✅ Creates development and staging databases
- ✅ Loads sample data in development
- ✅ Configures dbt profiles

#### STEP 2: Configure Environment Variables

After setup, edit the configuration files:

**`.env.dev` (Development)**
```bash
# Edit development configuration
nano .env.dev
```

Typical configuration:
```env
DBT_ENV=dev
DB_HOST=localhost
DB_PORT=5432
DB_USER=dbt_dev_user
DB_PASSWORD=dev_password_123
DB_NAME=ecommerce_dw_dev
DB_SCHEMA=analytics_dev
DBT_THREADS=2
```

**`.env.staging` (Staging)**
```bash
# Edit staging configuration
nano .env.staging
```

**`.env.prod` (Production)**
```bash
# Edit production configuration
nano .env.prod
```

**⚠️ IMPORTANT:** Use secure passwords and consider using secret managers for production.

#### STEP 3: Development Deployment

```bash
# Switch to development environment
./scripts/switch_env.sh dev

# Deploy to development
./scripts/deploy_dev.sh
```

**What does deploy_dev.sh do?**
- ✅ Verifies prerequisites
- ✅ Configures development database
- ✅ Loads sample data
- ✅ Executes dbt models with full refresh
- ✅ Executes tests (allows failures)
- ✅ Generates documentation

**Verify deployment:**
```bash
# View documentation
cd dbt_project && dbt docs serve --port 8080
# Open: http://localhost:8080

# Execute tests
dbt test --target dev

# View specific models
dbt run --target dev --select dim_customers
```

#### STEP 4: Development and Testing

While developing, use these commands frequently:

```bash
# Switch to development environment
./scripts/switch_env.sh dev

# Execute specific model
cd dbt_project
dbt run --target dev --select stg_customers

# Execute tests for a model
dbt test --target dev --select dim_customers

# View data lineage
dbt docs serve --port 8080
```

#### STEP 5: Staging Deployment

When your development is ready:

```bash
# Switch to staging environment
./scripts/switch_env.sh staging

# Deploy to staging
./scripts/deploy_staging.sh
```

**What does deploy_staging.sh do?**
- ✅ Verifies that development tests pass
- ✅ Creates automatic backup
- ✅ Configures staging database
- ✅ Executes dbt models (incremental)
- ✅ Executes ALL tests (store failures)
- ✅ Executes data quality validations
- ✅ Sends notifications (if configured)

**Verify staging:**
```bash
# View staging documentation
cd dbt_project && dbt docs serve --port 8081

# Execute specific tests
dbt test --target staging --select tag:critical
```

#### STEP 6: Production Deployment

**⚠️ CRITICAL:** Only after completely validating in staging.

```bash
# Switch to production environment
./scripts/switch_env.sh prod

# Deploy to production (requires confirmations)
./scripts/deploy_prod.sh
```

**What does deploy_prod.sh do?**
- 🔒 Requires multiple user confirmation
- ✅ Validates that staging tests pass
- ✅ Creates complete and compressed backup
- ✅ Executes models with incremental strategy
- ✅ Executes ONLY critical tests
- ✅ Configures automatic monitoring
- ✅ Sends detailed notifications
- ✅ Post-deployment validation

**The script will ask for confirmation 2 times:**
1. Initial confirmation
2. Confirmation after validations

You must type exactly `YES` to continue.

### Production Monitoring

#### Manual Monitoring

```bash
# Switch to production environment
./scripts/switch_env.sh prod

# Execute complete monitoring
./scripts/monitor_prod.py
```

**The monitoring script verifies:**
- 📊 Data freshness (< 24 hours)
- 🔍 Data quality (null values, negatives, etc.)
- 📈 Row count in main tables
- ⚡ Database performance
- 📧 Sends automatic alerts

#### Automatic Monitoring (Recommended)

Configure cron job for monitoring every hour:

```bash
# Edit crontab
crontab -e

# Add line (execute every hour)
0 * * * * cd /path/to/project && ./scripts/switch_env.sh prod && ./scripts/monitor_prod.py
```

#### Alerts

Alerts are sent automatically via:
- **Slack**: Configure `SLACK_WEBHOOK_URL` in `.env.prod`
- **Email**: Configure `EMAIL_ALERTS` in `.env.prod`

### Useful Commands by Environment

#### Development
```bash
./scripts/switch_env.sh dev
cd dbt_project

# Iterative development
dbt run --target dev --select +dim_customers  # With dependencies
dbt test --target dev --select dim_customers

# Restart everything
dbt run --target dev --full-refresh

# View compiled SQL
dbt compile --target dev
```

#### Staging
```bash
./scripts/switch_env.sh staging
cd dbt_project

# Complete execution
dbt run --target staging
dbt test --target staging --store-failures

# View failures
select * from analytics_staging.dbt_test_failures;

# Data validation
dbt run-operation check_data_quality --target staging
```

#### Production
```bash
./scripts/switch_env.sh prod
cd dbt_project

# Only incremental models
dbt run --target prod

# Only critical tests
dbt test --target prod --select tag:critical

# Operational validations
dbt run-operation validate_row_counts --target prod
dbt run-operation verify_tables_exist --target prod
```

### Environment Troubleshooting

#### Error: "Environment file not found"
```bash
# Copy from template
cp environments/dev.env.template .env.dev
# Edit with your configurations
nano .env.dev
```

#### Error: "Database connection failed"
```bash
# Verify PostgreSQL is running
sudo systemctl status postgresql  # Linux
brew services list | grep postgresql  # macOS

# Verify credentials in .env files
# Test manual connection
psql -h localhost -U postgres -d ecommerce_dw_dev
```

#### Error: "Virtual environment not found"
```bash
# Recreate virtual environment
python3 -m venv ecommerce-dw-env
source ecommerce-dw-env/bin/activate
pip install -r dbt_project/requirements.txt
```

#### Error: "dbt compilation failed"
```bash
# Verify syntax
cd dbt_project
dbt parse --target dev

# Verify dependencies
dbt deps

# Clean and rebuild
dbt clean
dbt deps
dbt run --target dev
```

#### Error: "Tests failing in production"
```bash
# View failure details (only staging/prod)
select * from analytics.dbt_test_failures 
where created_at > current_date;

# Execute specific test with verbose
dbt test --target prod --select dim_customers --store-failures
```

### Resulting Environment Structure

After complete deployment you will have:

```
PostgreSQL Instance
├── ecommerce_dw_dev (development)
│   ├── raw (source data)
│   └── analytics_dev (dbt models)
├── ecommerce_dw_staging (staging)  
│   ├── raw (source data)
│   ├── analytics_staging (dbt models)
│   └── dbt_test_failures (failed tests)
└── ecommerce_dw_prod (production)
    ├── raw (source data)
    ├── analytics (dbt models)
    ├── monitoring (metrics)
    └── analytics_snapshots (snapshots)
```

### Recommended Development Workflow

1. **Develop**: Create/modify models in `dev`
2. **Test**: Execute tests in `dev`
3. **Validate**: Deploy to `staging` and validate completely
4. **Review**: Code review and documentation
5. **Produce**: Deploy to `prod` only after approval
6. **Monitor**: Verify health and alerts

---

## Project Structure

```
ecommerce-dwh-dbt-powerbi/
├── data/                      # Source data in CSV
│   ├── customers.csv          # Customer data
│   ├── products.csv           # Product catalog
│   ├── orders.csv             # Order transactions
│   └── visits.csv             # Web visit data
├── dbt_project/               # dbt project
│   ├── dbt_project.yml        # Project configuration
│   ├── profiles.yml           # Connection configuration
│   ├── packages.yml           # dbt dependencies
│   ├── requirements.txt       # Python dependencies
│   └── models/
│       ├── staging/           # Staging models (cleaning)
│       │   ├── stg_customers.sql
│       │   ├── stg_products.sql
│       │   ├── stg_orders.sql
│       │   ├── stg_visits.sql
│       │   └── schema.yml
│       └── marts/             # Final models (star schema)
│           ├── dimensions/    # Dimension tables
│           │   ├── dim_customers.sql
│           │   ├── dim_products.sql
│           │   ├── dim_date.sql
│           │   └── schema.yml
│           └── facts/         # Fact tables
│               ├── fct_orders.sql
│               ├── fct_visits.sql
│               └── schema.yml
└── scripts/                   # Automation scripts
    ├── setup_environment.sh   # Complete environment setup
    ├── setup_database.sql     # SQL script to create DB
    ├── load_data.py           # Load CSV data to PostgreSQL
    ├── run_dbt.sh             # Complete dbt execution
    └── requirements.txt       # Project dependencies
```

## Data Warehouse Architecture

### Star Schema

**Dimensions:**
- `dim_customers` - Customer information with aggregated metrics
- `dim_products` - Product catalog with sales performance
- `dim_date` - Time dimension with hierarchies

**Facts:**
- `fct_orders` - Order transactions with business metrics
- `fct_visits` - Web behavior analysis and conversions

### Data Flow

1. **Raw Layer** (`raw` schema): Unprocessed source data from CSV
2. **Staging Layer** (`stg_*` models): Cleaning and standardization
3. **Marts Layer** (`dim_*` and `fct_*`): Optimized star schema

## Installation and Configuration

### Prerequisites

- **Python 3.8+**
- **PostgreSQL 12+**
- **Git**

### Automatic Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd ecommerce-dwh-dbt-powerbi

# 2. Run complete configuration script
chmod +x scripts/setup_environment.sh
./scripts/setup_environment.sh
```

### Manual Installation

#### 1. Configure PostgreSQL

```bash
# Create the database
psql -U postgres -c "CREATE DATABASE ecommerce_dw;"

# Run configuration script
psql -U postgres -d ecommerce_dw -f scripts/setup_database.sql
```

#### 2. Configure Python

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r dbt_project/requirements.txt
pip install -r scripts/requirements.txt
```

#### 3. Load Data

```bash
# Load CSV data to PostgreSQL
python3 scripts/load_data.py
```

#### 4. Configure dbt

```bash
# Copy connection profile
mkdir -p ~/.dbt
cp dbt_project/profiles.yml ~/.dbt/profiles.yml

# Install dbt packages
cd dbt_project
dbt deps
```

## Pipeline Execution

### Automated Complete Execution

```bash
# Activate virtual environment
source venv/bin/activate

# Run complete dbt pipeline
chmod +x scripts/run_dbt.sh
./scripts/run_dbt.sh
```

### Step by Step Execution

```bash
cd dbt_project

# 1. Verify connections
dbt debug

# 2. Install dependencies
dbt deps

# 3. Run models
dbt run

# 4. Run tests
dbt test

# 5. Generate documentation
dbt docs generate

# 6. Serve documentation
dbt docs serve
```

## Data Models

### Staging Models

#### `stg_customers`
- Name and email cleaning
- Date normalization
- Integrity validations

#### `stg_products`
- Category standardization
- Price range classification
- Price validation

#### `stg_orders`
- Unit price calculation
- Date component extraction
- Reference validations

#### `stg_visits`
- Session categorization
- Engagement metrics
- Behavior classification

### Dimension Tables  

#### `dim_customers`
```sql
-- Key metrics per customer
- customer_segment: Segmentation by purchase behavior
- total_orders: Total number of orders
- total_spent: Total amount spent
- conversion_rate_percent: Visit to order conversion rate
- avg_order_value: Average order value
```

#### `dim_products`
```sql
-- Product performance
- performance_tier: Classification by sales performance
- total_revenue: Total revenue generated
- total_quantity_sold: Units sold
- avg_quantity_per_order: Average units per order
```

#### `dim_date`
```sql
-- Complete time dimension
- Hierarchies: year, quarter, month, week, day
- Indicators: weekend, weekdays
- Metadata: month names, days, seasons
```

### Fact Tables

#### `fct_orders`
```sql
-- Transaction facts
- Metrics: quantity, unit_price, total_amount
- Calculated: discount_amount, estimated_profit
- Classifications: order_size, profit_margin_percent
```

#### `fct_visits`
```sql
-- Web behavior facts
- Metrics: duration_minutes, pages_viewed
- Engagement: pages_per_minute, engagement_score
- Conversion: converted_flag, conversion_value
- Attribution: traffic_source
```

## Testing and Validation

### Implemented Tests

1. **Uniqueness**: Unique primary keys
2. **Referential Integrity**: Relationships between facts and dimensions
3. **Not Nulls**: Required critical fields
4. **Ranges**: Numeric value validation
5. **Consistency**: Business logic validations

### Run Tests

```bash
# All tests
dbt test

# Specific tests per model
dbt test --select stg_customers

# Tests by tag
dbt test --select tag:staging
```

## Calculated Business Metrics

### Customer Analytics
- **Customer Lifetime Value**: Based on historical orders
- **RFM Segmentation**: Recency, Frequency, Monetary
- **Customer Acquisition Cost**: By traffic channel
- **Churn Rate**: Retention analysis

### Product Performance
- **Product Velocity**: Rotation speed
- **Cross-sell Analysis**: Products purchased together
- **Seasonal Trends**: Seasonal patterns
- **Margin Analysis**: Profitability by product

### Web Analytics
- **Conversion Funnel**: Visits to Orders
- **Engagement Metrics**: Time, pages, bounce rate
- **Traffic Attribution**: Performance by source
- **User Journey**: Behavior analysis

## Connect to Power BI

### Connection Configuration

1. **Open Power BI Desktop**
2. **Get Data** > **PostgreSQL**
3. **Configure connection**:
   - Server: `localhost:5432`
   - Database: `ecommerce_dw`
   - User: `postgres`

### Recommended Tables for Dashboards

```sql
-- For sales analysis
analytics.fct_orders
analytics.dim_customers  
analytics.dim_products
analytics.dim_date

-- For web analysis
analytics.fct_visits
analytics.dim_customers
analytics.dim_date
```

### Suggested Dashboards

#### Sales Dashboard
- Sales by month/quarter
- Top 10 best-selling products
- Analysis by category
- Performance by customer segment

#### Customer Dashboard  
- Customer segmentation
- Customer Lifetime Value
- Conversion rate
- Retention analysis

#### Web Analytics Dashboard
- Conversion funnel
- Engagement by traffic source
- Bounce rate and session time
- Most viewed pages analysis

## Customization

### Add New Data Sources

1. **Add CSV** to `data/` folder
2. **Create table** in `scripts/setup_database.sql`
3. **Add mapping** in `scripts/load_data.py`
4. **Create staging model** in `models/staging/`
5. **Update schema.yml**

### Modify Business Logic

- **Customer segmentation**: Edit `dim_customers.sql`
- **Product metrics**: Modify `dim_products.sql`
- **Fact calculations**: Adjust `fct_orders.sql` and `fct_visits.sql`

### Add New Tests

```yaml
# In schema.yml
tests:
  - unique
  - not_null
  - accepted_values:
      values: ['value1', 'value2']
  - relationships:
      to: ref('other_table')
      field: column_name
```

## Troubleshooting

### Common Problems

#### PostgreSQL Connection Error
```bash
# Verify PostgreSQL is running
pg_ctl status

# Restart service
brew services restart postgresql  # macOS
sudo service postgresql restart   # Linux
```

#### dbt deps Error
```bash
# Clean cache
dbt clean
dbt deps --force
```

#### Permission Error
```bash
# Verify database permissions
psql -U postgres -d ecommerce_dw -c "\dp"
```

#### PostgreSQL doesn't connect
```bash
# Start service
brew services start postgresql  # macOS
sudo service postgresql start   # Linux

# Verify
pg_isready
```

#### dbt doesn't find tables
```bash
cd dbt_project
dbt debug  # Verify connection
dbt deps   # Install dependencies
```

### Logs and Debugging

```bash
# See detailed logs
dbt run --debug

# Compile queries without executing
dbt compile

# View compiled query
cat target/compiled/ecommerce_dw/models/marts/facts/fct_orders.sql
```
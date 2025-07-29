-- Setup script for E-commerce Data Warehouse
-- Run this script as a PostgreSQL superuser to create the database and schemas
-- This script creates users and permissions for all environments

-- Create schemas (using DO block for conditional creation)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'raw') THEN
        CREATE SCHEMA raw;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'analytics') THEN
        CREATE SCHEMA analytics;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'analytics_dev') THEN
        CREATE SCHEMA analytics_dev;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'analytics_staging') THEN
        CREATE SCHEMA analytics_staging;
    END IF;
END $$;

-- Create users for each environment (using DO block for conditional creation)
DO $$
BEGIN
    -- Development user (with advanced privileges for full dbt functionality)
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'dbt_dev_user') THEN
        CREATE USER dbt_dev_user WITH 
            PASSWORD 'dev_password_123'
            CREATEDB
            CREATEROLE
            LOGIN;
    END IF;
    
    -- Staging user (with advanced privileges for full dbt functionality)
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'dbt_staging_user') THEN
        CREATE USER dbt_staging_user WITH 
            PASSWORD 'staging_password_456'
            CREATEDB
            CREATEROLE
            LOGIN;
    END IF;
    
    -- Production user (with advanced privileges for full dbt functionality)
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'dbt_prod_user') THEN
        CREATE USER dbt_prod_user WITH 
            PASSWORD 'super_secure_prod_password_change_me'
            CREATEDB
            CREATEROLE
            LOGIN;
    END IF;
    
    -- Generic user for backward compatibility
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'dbt_user') THEN
        CREATE USER dbt_user WITH PASSWORD 'dbt_password';
    END IF;
END $$;

-- Grant comprehensive permissions to all dbt users
-- This section grants all necessary permissions for full dbt functionality including tests

-- Grant database-level permissions
GRANT ALL PRIVILEGES ON DATABASE ecommerce_dw_dev TO dbt_dev_user;
GRANT ALL PRIVILEGES ON DATABASE ecommerce_dw_staging TO dbt_staging_user;
GRANT ALL PRIVILEGES ON DATABASE ecommerce_dw_prod TO dbt_prod_user;

-- Grant permissions on all existing schemas (dynamic approach)
DO $$
DECLARE
    schema_name text;
BEGIN
    -- Loop through all schemas and grant comprehensive permissions
    FOR schema_name IN 
        SELECT nspname FROM pg_namespace 
        WHERE nspname NOT LIKE 'pg_%' AND nspname != 'information_schema'
    LOOP
        -- Development user
        EXECUTE format('GRANT ALL PRIVILEGES ON SCHEMA %I TO dbt_dev_user', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO dbt_dev_user', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO dbt_dev_user', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA %I TO dbt_dev_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON TABLES TO dbt_dev_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON SEQUENCES TO dbt_dev_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON FUNCTIONS TO dbt_dev_user', schema_name);
        
        -- Staging user
        EXECUTE format('GRANT ALL PRIVILEGES ON SCHEMA %I TO dbt_staging_user', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO dbt_staging_user', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO dbt_staging_user', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA %I TO dbt_staging_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON TABLES TO dbt_staging_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON SEQUENCES TO dbt_staging_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON FUNCTIONS TO dbt_staging_user', schema_name);
        
        -- Production user
        EXECUTE format('GRANT ALL PRIVILEGES ON SCHEMA %I TO dbt_prod_user', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO dbt_prod_user', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO dbt_prod_user', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA %I TO dbt_prod_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON TABLES TO dbt_prod_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON SEQUENCES TO dbt_prod_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON FUNCTIONS TO dbt_prod_user', schema_name);
    END LOOP;
END $$;

-- Grant permissions on system schemas (essential for dbt tests and operations)
GRANT USAGE ON SCHEMA information_schema TO dbt_dev_user, dbt_staging_user, dbt_prod_user;
GRANT USAGE ON SCHEMA pg_catalog TO dbt_dev_user, dbt_staging_user, dbt_prod_user;
GRANT SELECT ON ALL TABLES IN SCHEMA information_schema TO dbt_dev_user, dbt_staging_user, dbt_prod_user;
GRANT SELECT ON ALL TABLES IN SCHEMA pg_catalog TO dbt_dev_user, dbt_staging_user, dbt_prod_user;

-- Grant additional PostgreSQL built-in roles for comprehensive testing capabilities
GRANT pg_read_all_settings TO dbt_dev_user, dbt_staging_user, dbt_prod_user;
GRANT pg_read_all_stats TO dbt_dev_user, dbt_staging_user, dbt_prod_user;

-- Note: All permissions are now handled dynamically in the loop above
-- This includes permissions for all environments and the generic user

-- Create tables in raw schema for CSV data (using DO blocks for conditional creation)
DO $$
BEGIN
    -- Create customers table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'raw' AND table_name = 'customers') THEN
        CREATE TABLE raw.customers (
            customer_id INTEGER PRIMARY KEY,
            first_name VARCHAR(100),
            last_name VARCHAR(100),
            email VARCHAR(255) UNIQUE,
            registration_date DATE
        );
    END IF;

    -- Create products table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'raw' AND table_name = 'products') THEN
        CREATE TABLE raw.products (
            product_id INTEGER PRIMARY KEY,
            product_name VARCHAR(255),
            category VARCHAR(100),
            price DECIMAL(10,2)
        );
    END IF;

    -- Create orders table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'raw' AND table_name = 'orders') THEN
        CREATE TABLE raw.orders (
            order_id INTEGER PRIMARY KEY,
            customer_id INTEGER,
            order_date DATE,
            product_id INTEGER,
            quantity INTEGER,
            total_amount DECIMAL(10,2),
            FOREIGN KEY (customer_id) REFERENCES raw.customers(customer_id),
            FOREIGN KEY (product_id) REFERENCES raw.products(product_id)
        );
    END IF;

    -- Create visits table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'raw' AND table_name = 'visits') THEN
        CREATE TABLE raw.visits (
            visit_id VARCHAR(10) PRIMARY KEY,
            customer_id INTEGER,
            visit_date DATE,
            duration_minutes INTEGER,
            pages_viewed INTEGER,
            FOREIGN KEY (customer_id) REFERENCES raw.customers(customer_id)
        );
    END IF;
END $$;

-- Add indexes for better performance (using DO block for conditional creation)
DO $$
BEGIN
    -- Index for orders.customer_id
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE schemaname = 'raw' AND tablename = 'orders' 
                   AND indexname = 'idx_orders_customer_id') THEN
        CREATE INDEX idx_orders_customer_id ON raw.orders(customer_id);
    END IF;

    -- Index for orders.product_id
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE schemaname = 'raw' AND tablename = 'orders' 
                   AND indexname = 'idx_orders_product_id') THEN
        CREATE INDEX idx_orders_product_id ON raw.orders(product_id);
    END IF;

    -- Index for orders.order_date
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE schemaname = 'raw' AND tablename = 'orders' 
                   AND indexname = 'idx_orders_date') THEN
        CREATE INDEX idx_orders_date ON raw.orders(order_date);
    END IF;

    -- Index for visits.customer_id
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE schemaname = 'raw' AND tablename = 'visits' 
                   AND indexname = 'idx_visits_customer_id') THEN
        CREATE INDEX idx_visits_customer_id ON raw.visits(customer_id);
    END IF;

    -- Index for visits.visit_date
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE schemaname = 'raw' AND tablename = 'visits' 
                   AND indexname = 'idx_visits_date') THEN
        CREATE INDEX idx_visits_date ON raw.visits(visit_date);
    END IF;
END $$;

-- Add comments to document the schema and tables
COMMENT ON SCHEMA raw IS 'Raw data loaded from CSV files';
COMMENT ON SCHEMA analytics IS 'Transformed data models created by dbt (production)';
COMMENT ON SCHEMA analytics_dev IS 'Transformed data models created by dbt (development)';
COMMENT ON SCHEMA analytics_staging IS 'Transformed data models created by dbt (staging)';
COMMENT ON TABLE raw.customers IS 'Customer master data';
COMMENT ON TABLE raw.products IS 'Product catalog data';
COMMENT ON TABLE raw.orders IS 'Order transaction data';
COMMENT ON TABLE raw.visits IS 'Website visit tracking data'; 
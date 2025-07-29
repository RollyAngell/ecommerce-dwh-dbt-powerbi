#!/bin/bash

# E-commerce Data Warehouse - dbt Run Script
# This script runs the complete dbt workflow

set -e  # Exit on any error

echo "🚀 Starting E-commerce Data Warehouse dbt workflow..."

# Change to dbt project directory
cd dbt_project

# Check if profiles.yml exists in the right location
if [ ! -f ~/.dbt/profiles.yml ]; then
    echo "📋 Copying profiles.yml to ~/.dbt/"
    mkdir -p ~/.dbt
    cp profiles.yml ~/.dbt/profiles.yml
fi

echo "📦 Installing dbt packages..."
dbt deps

echo "🧪 Running dbt debug to check connections..."
dbt debug

echo "🔍 Parsing dbt project..."
dbt parse

echo "🏗️  Running dbt models..."
dbt run

echo "🧪 Running dbt tests..."
dbt test

echo "📊 Generating and serving documentation..."
dbt docs generate

echo "✅ dbt workflow completed successfully!"
echo ""
echo "📈 To view documentation, run: dbt docs serve"
echo "🔗 Then open: http://localhost:8080"
echo ""
echo "📊 Your data warehouse tables are ready in PostgreSQL:"
echo "   - analytics.dim_customers"
echo "   - analytics.dim_products" 
echo "   - analytics.dim_date"
echo "   - analytics.fct_orders"
echo "   - analytics.fct_visits" 
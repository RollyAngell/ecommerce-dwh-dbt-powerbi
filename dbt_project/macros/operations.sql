{% macro grant_select_on_schemas(schemas, role) %}
  {# Macro to grant SELECT permissions on schemas to a specific role #}
  
  {% if target.name == 'prod' %}
    {% for schema in schemas %}
      GRANT USAGE ON SCHEMA {{ schema }} TO {{ role }};
      GRANT SELECT ON ALL TABLES IN SCHEMA {{ schema }} TO {{ role }};
      ALTER DEFAULT PRIVILEGES IN SCHEMA {{ schema }} GRANT SELECT ON TABLES TO {{ role }};
    {% endfor %}
  {% endif %}
  
{% endmacro %}

{% macro check_data_quality() %}
  {# Macro to run data quality checks #}
  
  {% set quality_checks = [
    "SELECT 'dim_customers' as table_name, count(*) as null_ids FROM " ~ ref('dim_customers') ~ " WHERE customer_id IS NULL",
    "SELECT 'fct_orders' as table_name, count(*) as negative_amounts FROM " ~ ref('fct_orders') ~ " WHERE total_amount < 0",
    "SELECT 'fct_orders' as table_name, count(*) as future_dates FROM " ~ ref('fct_orders') ~ " WHERE order_date > CURRENT_DATE"
  ] %}
  
  {% if execute %}
    {% for check in quality_checks %}
      {% set results = run_query(check) %}
      {% if results.rows|length > 0 %}
        {% for row in results.rows %}
          {{ log("Data Quality Check - " ~ row[0] ~ ": " ~ row[1] ~ " issues found", info=true) }}
        {% endfor %}
      {% endif %}
    {% endfor %}
  {% endif %}
  
{% endmacro %}

{% macro validate_row_counts() %}
  {# Macro to validate expected row counts #}
  
  {% set tables_to_check = [
    {'name': 'dim_customers', 'min_rows': 1},
    {'name': 'dim_products', 'min_rows': 1}, 
    {'name': 'fct_orders', 'min_rows': 1},
    {'name': 'fct_visits', 'min_rows': 1}
  ] %}
  
  {% if execute %}
    {% for table in tables_to_check %}
      {% set row_count_query %}
        SELECT count(*) as row_count FROM {{ ref(table.name) }}
      {% endset %}
      
      {% set results = run_query(row_count_query) %}
      {% if results.rows|length > 0 %}
        {% set row_count = results.rows[0][0] %}
        {% if row_count < table.min_rows %}
          {{ log("❌ Row count validation failed for " ~ table.name ~ ": " ~ row_count ~ " rows (minimum: " ~ table.min_rows ~ ")", info=true) }}
        {% else %}
          {{ log("✅ Row count validation passed for " ~ table.name ~ ": " ~ row_count ~ " rows", info=true) }}
        {% endif %}
      {% endif %}
    {% endfor %}
  {% endif %}
  
{% endmacro %}

{% macro verify_tables_exist() %}
  {# Macro to verify all expected tables exist #}
  
  {% set expected_tables = [
    'dim_customers',
    'dim_products', 
    'dim_date',
    'fct_orders',
    'fct_visits'
  ] %}
  
  {% if execute %}
    {% for table in expected_tables %}
      {% set table_exists_query %}
        SELECT count(*) 
        FROM information_schema.tables 
        WHERE table_schema = '{{ target.schema }}' 
        AND table_name = '{{ table }}'
      {% endset %}
      
      {% set results = run_query(table_exists_query) %}
      {% if results.rows|length > 0 %}
        {% set table_exists = results.rows[0][0] > 0 %}
        {% if table_exists %}
          {{ log("✅ Table " ~ table ~ " exists", info=true) }}
        {% else %}
          {{ log("❌ Table " ~ table ~ " does not exist", info=true) }}
        {% endif %}
      {% endif %}
    {% endfor %}
  {% endif %}
  
{% endmacro %}

{% macro setup_monitoring() %}
  {# Macro to setup monitoring tables and functions #}
  
  {% if target.name == 'prod' %}
    {% set monitoring_sql %}
      -- Create monitoring schema if it doesn't exist
      CREATE SCHEMA IF NOT EXISTS monitoring;
      
      -- Create table to track dbt runs
      CREATE TABLE IF NOT EXISTS monitoring.dbt_run_log (
        id SERIAL PRIMARY KEY,
        run_started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        run_completed_at TIMESTAMP,
        target_name VARCHAR(50),
        success BOOLEAN,
        models_run INTEGER,
        tests_run INTEGER,
        failures INTEGER,
        execution_time_seconds INTEGER
      );
      
      -- Create table to track data quality metrics
      CREATE TABLE IF NOT EXISTS monitoring.data_quality_log (
        id SERIAL PRIMARY KEY,
        check_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        table_name VARCHAR(100),
        check_name VARCHAR(100),
        check_result INTEGER,
        threshold_value INTEGER,
        passed BOOLEAN
      );
      
      {{ log("✅ Monitoring tables created/verified", info=true) }}
    {% endset %}
    
    {% do run_query(monitoring_sql) %}
  {% endif %}
  
{% endmacro %}

{% macro log_dbt_run(success, models_run, tests_run, failures, execution_time) %}
  {# Macro to log dbt run statistics #}
  
  {% if target.name == 'prod' %}
    {% set log_sql %}
      INSERT INTO monitoring.dbt_run_log 
      (run_completed_at, target_name, success, models_run, tests_run, failures, execution_time_seconds)
      VALUES (
        CURRENT_TIMESTAMP,
        '{{ target.name }}',
        {{ success }},
        {{ models_run }},
        {{ tests_run }},
        {{ failures }},
        {{ execution_time }}
      )
    {% endset %}
    
    {% do run_query(log_sql) %}
    {{ log("📊 dbt run logged to monitoring table", info=true) }}
  {% endif %}
  
{% endmacro %} 
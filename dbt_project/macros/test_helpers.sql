-- Custom test macros for e-commerce data warehouse
-- These macros provide additional data quality tests

{% macro test_positive_values(model, column_name) %}
    -- Test that numeric values are positive
    select count(*) as failures
    from {{ model }}
    where {{ column_name }} <= 0
{% endmacro %}

{% macro test_email_format(model, column_name) %}
    -- Test that email addresses contain @ symbol and domain
    select count(*) as failures
    from {{ model }}
    where {{ column_name }} not like '%@%.%'
       or {{ column_name }} is null
{% endmacro %}

{% macro test_date_range(model, column_name, start_date, end_date) %}
    -- Test that dates fall within expected range
    select count(*) as failures
    from {{ model }}
    where {{ column_name }} < '{{ start_date }}'
       or {{ column_name }} > '{{ end_date }}'
{% endmacro %}

{% macro generate_alias_name(custom_alias_name, node) -%}
    {%- if custom_alias_name is none -%}
        {{ node.name }}
    {%- else -%}
        {{ custom_alias_name | trim }}
    {%- endif -%}
{%- endmacro %} 
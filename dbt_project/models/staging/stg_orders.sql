{{ config(materialized='view') }}

with source_data as (
    select
        order_id,
        customer_id,
        order_date,
        product_id,
        quantity,
        total_amount
    from {{ source('raw', 'orders') }}
)

select
    order_id,
    customer_id,
    order_date::date as order_date,
    product_id,
    quantity::integer as quantity,
    total_amount::decimal(10,2) as total_amount,
    -- Create derived fields
    (total_amount / quantity)::decimal(10,2) as unit_price,
    extract(year from order_date::date) as order_year,
    extract(month from order_date::date) as order_month,
    extract(quarter from order_date::date) as order_quarter,
    current_timestamp as _loaded_at
from source_data
where order_id is not null
  and customer_id is not null
  and product_id is not null
  and order_date is not null
  and quantity > 0
  and total_amount > 0 
{{ config(materialized='table') }}

with orders as (
    select * from {{ ref('stg_orders') }}
),

-- Add surrogate keys for dimensions
final as (
    select
        o.order_id,
        o.customer_id,
        o.product_id,
        o.order_date,
        
        -- Fact measures
        o.quantity,
        o.unit_price,
        o.total_amount,
        
        -- Additional calculated measures
        o.total_amount - (o.unit_price * o.quantity) as discount_amount,
        
        -- Time dimensions
        o.order_year,
        o.order_month,
        o.order_quarter,
        
        -- Additional business logic
        case
            when o.total_amount < 50 then 'Small Order'
            when o.total_amount between 50 and 200 then 'Medium Order'
            when o.total_amount between 200 and 500 then 'Large Order'
            else 'Bulk Order'
        end as order_size,
        
        -- Profitability assumptions (simplified)
        round(o.total_amount * 0.3, 2) as estimated_profit,
        round((o.total_amount * 0.3) / o.total_amount * 100, 2) as profit_margin_percent,
        
        current_timestamp as _loaded_at
        
    from orders o
)

select * from final 
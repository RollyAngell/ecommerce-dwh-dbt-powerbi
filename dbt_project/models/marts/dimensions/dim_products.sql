{{ config(materialized='table') }}

with products as (
    select * from {{ ref('stg_products') }}
),

product_sales as (
    select
        product_id,
        count(distinct order_id) as total_orders,
        sum(quantity) as total_quantity_sold,
        sum(total_amount) as total_revenue,
        min(order_date) as first_sale_date,
        max(order_date) as last_sale_date
    from {{ ref('stg_orders') }}
    group by product_id
)

select
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.price_tier,
    
    -- Sales performance metrics
    coalesce(ps.total_orders, 0) as total_orders,
    coalesce(ps.total_quantity_sold, 0) as total_quantity_sold,
    coalesce(ps.total_revenue, 0) as total_revenue,
    ps.first_sale_date,
    ps.last_sale_date,
    
    -- Product performance indicators
    case
        when ps.total_orders is null then 'Never Sold'
        when ps.total_orders = 1 then 'Single Sale'
        when ps.total_orders between 2 and 5 then 'Low Performer'
        when ps.total_orders between 6 and 15 then 'Good Performer'
        else 'Top Performer'
    end as performance_tier,
    
    -- Calculated metrics
    case
        when ps.total_orders > 0
        then round(ps.total_quantity_sold::numeric / ps.total_orders::numeric, 2)
        else 0
    end as avg_quantity_per_order,
    
    case
        when ps.total_orders > 0
        then round(ps.total_revenue / ps.total_orders, 2)
        else 0
    end as avg_revenue_per_order,
    
    current_timestamp as _loaded_at

from products p
left join product_sales ps on p.product_id = ps.product_id 
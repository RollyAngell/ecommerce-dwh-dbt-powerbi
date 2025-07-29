{{ config(materialized='table') }}

with customers as (
    select * from {{ ref('stg_customers') }}
),

customer_summary as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        sum(total_amount) as total_spent,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from {{ ref('stg_orders') }}
    group by customer_id
),

visit_summary as (
    select
        customer_id,
        count(distinct visit_id) as total_visits,
        sum(duration_minutes) as total_duration,
        sum(pages_viewed) as total_pages_viewed,
        min(visit_date) as first_visit_date,
        max(visit_date) as last_visit_date
    from {{ ref('stg_visits') }}
    group by customer_id
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.full_name,
    c.email,
    c.registration_date,
    
    -- Customer segmentation
    case
        when cs.total_orders is null then 'Never Purchased'
        when cs.total_orders = 1 then 'One-time Buyer'
        when cs.total_orders between 2 and 5 then 'Regular Customer'  
        when cs.total_orders between 6 and 10 then 'Frequent Customer'
        else 'VIP Customer'
    end as customer_segment,
    
    -- Order metrics
    coalesce(cs.total_orders, 0) as total_orders,
    coalesce(cs.total_spent, 0) as total_spent,
    cs.first_order_date,
    cs.last_order_date,
    
    -- Visit metrics
    coalesce(vs.total_visits, 0) as total_visits,
    coalesce(vs.total_duration, 0) as total_duration_minutes,
    coalesce(vs.total_pages_viewed, 0) as total_pages_viewed,
    vs.first_visit_date,
    vs.last_visit_date,
    
    -- Calculated metrics
    case
        when vs.total_visits > 0 and cs.total_orders > 0
        then round((cs.total_orders::numeric / vs.total_visits::numeric) * 100, 2)
        else 0
    end as conversion_rate_percent,
    
    case
        when cs.total_orders > 0
        then round(cs.total_spent / cs.total_orders, 2)
        else 0
    end as avg_order_value,
    
    current_timestamp as _loaded_at

from customers c
left join customer_summary cs on c.customer_id = cs.customer_id
left join visit_summary vs on c.customer_id = vs.customer_id 
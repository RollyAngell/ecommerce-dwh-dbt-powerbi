{{ config(materialized='table') }}

with visits as (
    select * from {{ ref('stg_visits') }}
),

-- Check if visit resulted in an order (conversion)
visit_conversions as (
    select
        v.visit_id,
        v.customer_id,
        v.visit_date,
        case 
            when o.order_id is not null then 1 
            else 0 
        end as converted_flag,
        o.order_id as converted_order_id,
        o.total_amount as conversion_value
    from visits v
    left join {{ ref('stg_orders') }} o 
        on v.customer_id = o.customer_id 
        and v.visit_date = o.order_date
),

final as (
    select
        v.visit_id,
        v.customer_id,
        v.visit_date,
        
        -- Visit fact measures
        v.duration_minutes,
        v.pages_viewed,
        
        -- Engagement metrics
        round(v.pages_viewed::numeric / v.duration_minutes::numeric, 2) as pages_per_minute,
        
        -- Session quality score (0-100)
        least(100, 
            (v.duration_minutes * 2) + 
            (v.pages_viewed * 5) + 
            case when v.duration_minutes > 10 then 20 else 0 end
        ) as engagement_score,
        
        -- Conversion metrics
        vc.converted_flag,
        vc.converted_order_id,
        coalesce(vc.conversion_value, 0) as conversion_value,
        
        -- Categorized dimensions
        v.session_type,
        v.engagement_level,
        
        -- Time dimensions
        v.visit_year,
        v.visit_month,
        
        -- Traffic source (simulated - would come from UTM parameters in real data)
        case v.customer_id % 4
            when 0 then 'Direct'
            when 1 then 'Google Search'
            when 2 then 'Social Media'
            else 'Email Marketing'
        end as traffic_source,
        
        current_timestamp as _loaded_at
        
    from visits v
    left join visit_conversions vc on v.visit_id = vc.visit_id
)

select * from final 
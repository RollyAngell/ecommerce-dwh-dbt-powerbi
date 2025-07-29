{{ config(materialized='view') }}

with source_data as (
    select
        visit_id,
        customer_id,
        visit_date,
        duration_minutes,
        pages_viewed
    from {{ source('raw', 'visits') }}
)

select
    visit_id,
    customer_id,
    visit_date::date as visit_date,
    duration_minutes::integer as duration_minutes,
    pages_viewed::integer as pages_viewed,
    -- Create derived fields
    case
        when duration_minutes < 5 then 'Bounce'
        when duration_minutes between 5 and 15 then 'Short'
        when duration_minutes between 15 and 30 then 'Medium'
        else 'Long'
    end as session_type,
    case
        when pages_viewed = 1 then 'Single Page'
        when pages_viewed between 2 and 5 then 'Browse'
        when pages_viewed between 6 and 10 then 'Engaged'
        else 'Deep Exploration'
    end as engagement_level,
    extract(year from visit_date::date) as visit_year,
    extract(month from visit_date::date) as visit_month,
    current_timestamp as _loaded_at
from source_data
where visit_id is not null
  and customer_id is not null
  and visit_date is not null
  and duration_minutes >= 0
  and pages_viewed > 0 
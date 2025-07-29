{{ config(materialized='view') }}

with source_data as (
    select
        customer_id,
        first_name,
        last_name,
        email,
        registration_date
    from {{ source('raw', 'customers') }}
)

select
    customer_id,
    trim(first_name) as first_name,
    trim(last_name) as last_name,
    lower(trim(email)) as email,
    registration_date::date as registration_date,
    -- Create derived fields
    concat(trim(first_name), ' ', trim(last_name)) as full_name,
    current_timestamp as _loaded_at
from source_data
where customer_id is not null
  and email is not null
  and registration_date is not null 
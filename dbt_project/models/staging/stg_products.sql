{{ config(materialized='view') }}

with source_data as (
    select
        product_id,
        product_name,
        category,
        price
    from {{ source('raw', 'products') }}
)

select
    product_id,
    trim(product_name) as product_name,
    trim(upper(category)) as category,
    price::decimal(10,2) as price,
    -- Create derived fields
    case
        when price < 50 then 'Low'
        when price between 50 and 200 then 'Medium'
        when price between 200 and 500 then 'High'
        else 'Premium'
    end as price_tier,
    current_timestamp as _loaded_at
from source_data
where product_id is not null
  and product_name is not null
  and price is not null
  and price > 0 
{{ config(materialized='table') }}

-- Generate a date dimension for the range of dates in our data
with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2023-01-01' as date)",
        end_date="cast('2023-12-31' as date)"
    ) }}
)

select
    date_day as date_key,
    date_day,
    
    -- Date parts
    extract(year from date_day) as year,
    extract(quarter from date_day) as quarter,
    extract(month from date_day) as month,
    extract(week from date_day) as week_of_year,
    extract(day from date_day) as day_of_month,
    extract(dow from date_day) as day_of_week, -- 0=Sunday, 6=Saturday
    extract(doy from date_day) as day_of_year,
    
    -- Formatted date strings
    to_char(date_day, 'YYYY-MM-DD') as date_string,
    to_char(date_day, 'YYYY-MM') as year_month,
    to_char(date_day, 'YYYY-Q') as year_quarter,
    to_char(date_day, 'Month') as month_name,
    to_char(date_day, 'Day') as day_name,
    
    -- Date flags
    case when extract(dow from date_day) in (0, 6) then true else false end as is_weekend,
    case when extract(dow from date_day) between 1 and 5 then true else false end as is_weekday,
    
    -- Quarter info
    case extract(quarter from date_day)
        when 1 then 'Q1'
        when 2 then 'Q2'
        when 3 then 'Q3'
        when 4 then 'Q4'
    end as quarter_name,
    
    -- Season (Northern Hemisphere)
    case 
        when extract(month from date_day) in (12, 1, 2) then 'Winter'
        when extract(month from date_day) in (3, 4, 5) then 'Spring'
        when extract(month from date_day) in (6, 7, 8) then 'Summer'
        when extract(month from date_day) in (9, 10, 11) then 'Fall'
    end as season,
    
    current_timestamp as _loaded_at

from date_spine
order by date_day 
with base as (
    select distinct datetime_ordered
    from {{ ref('fct_orders') }}
)

select
    datetime_ordered,
    date(datetime_ordered) as order_date,
    extract(hour from datetime_ordered) as order_hour,
    extract(minute from datetime_ordered) as order_minute,
    format_date('%A', date(datetime_ordered)) as order_weekday,
    extract(dayofweek from datetime_ordered) as order_dayofweek,  
    extract(month from datetime_ordered) as order_month_num,
    format_date('%B', date(datetime_ordered)) as order_month,
    extract(year from datetime_ordered) as order_year,

    -- Weekend flag: Friday (6), Saturday (7), Sunday (1)
    case
        when extract(dayofweek from datetime_ordered) in (1, 6, 7) then true
        else false
    end as is_weekend

from base

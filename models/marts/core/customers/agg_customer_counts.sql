with base as (
    select
        datetime_trunc(datetime_ordered, hour) as order_hour_dt,
        date(datetime_ordered) as order_date,
        category
    from {{ ref('fct_orders') }}
    where production_department = 'kitchen'
),

hourly as (
    select
        order_hour_dt,
        order_date,
        count(*) as total_mains_ordered_per_hour
    from base
    where category in ('Mains', 'Large Cuts', 'Steaks')
    group by order_hour_dt, order_date
)

select
    order_hour_dt,
    order_date,
    total_mains_ordered_per_hour
    
from hourly 
with orders_with_hour as (
    select
        datetime_trunc(datetime_ordered, hour) as order_hour_dt,
        quantity,
        total_item_revenue
    from {{ ref('fct_orders') }}
),

aggregated as (
    select
        order_hour_dt,
        sum(quantity) as items_sold,
        sum(total_item_revenue) as total_revenue
    from orders_with_hour
    group by order_hour_dt
)

select
    order_hour_dt,
    date(order_hour_dt) as order_date,
    extract(hour from order_hour_dt) as hour_of_day,
    items_sold,
    total_revenue
from aggregated
order by order_hour_dt

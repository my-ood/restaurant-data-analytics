with enriched_orders as (
    select
        datetime_trunc(o.datetime_ordered, hour) as order_hour_dt,
        date(o.datetime_ordered) as order_date,
        extract(hour from o.datetime_ordered) as hour_of_day,
        extract(dayofweek from o.datetime_ordered) as day_of_week,
        o.order_uuid,
        o.table_no,
        o.item_uuid,
        o.quantity,
        o.total_item_revenue,
        m.category
    from {{ ref('fct_orders') }} o
    join {{ ref('dim_menu_items') }} m using (item_uuid)
),

top_category_per_hour as (
    select
        order_hour_dt,
        any_value(category) as top_category,
        max(category_revenue) as top_category_revenue
    from (
        select
            order_hour_dt,
            category,
            sum(total_item_revenue) as category_revenue
        from enriched_orders
        group by order_hour_dt, category
    )
    group by order_hour_dt
),

aggregated as (
    select
        e.order_hour_dt,
        e.order_date,
        e.hour_of_day,
        count(distinct e.table_no) as distinct_tables,
        count(distinct e.order_uuid) as total_orders,
        sum(e.quantity) as items_sold,
        sum(e.total_item_revenue) as total_revenue,
        count(distinct e.item_uuid) as unique_items_ordered,
        max(extract(dayofweek from e.order_hour_dt) in (1, 6, 7)) as is_weekend,
        t.top_category,
        t.top_category_revenue
    from enriched_orders e
    left join top_category_per_hour t on e.order_hour_dt = t.order_hour_dt
    group by e.order_hour_dt, e.order_date, e.hour_of_day, t.top_category, t.top_category_revenue
),

final as (
    select
        order_hour_dt,
        order_date,
        hour_of_day,
        items_sold,
        total_revenue,
        distinct_tables,
        total_orders,
        round(total_revenue / nullif(total_orders, 0), 2) as avg_spend_per_order,
        round(items_sold / nullif(total_orders, 0), 2) as avg_items_per_order,
        unique_items_ordered,
        top_category,
        top_category_revenue,
        is_weekend
    from aggregated
)

select
    order_hour_dt,
    order_date,
    hour_of_day,
    items_sold,
    total_revenue,
    distinct_tables,
    total_orders,
    avg_spend_per_order,
    avg_items_per_order,
    unique_items_ordered,
    top_category,
    top_category_revenue,
    is_weekend,
    dense_rank() over (order by total_revenue desc) <= 5 as is_peak_hour
from final
order by order_hour_dt

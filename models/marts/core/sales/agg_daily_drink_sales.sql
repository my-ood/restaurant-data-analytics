with hourly as (
    select *
    from {{ ref('agg_hourly_drink_sales') }}
),

metadata as (
    select
        order_date,
        drink_category_diversity_all_day,
        distinct_drink_tables_used_all_day,
        unique_drink_items_ordered_all_day
    from {{ ref('agg_daily_metadata') }}
),

customers as (
    select
        order_date,
        sum(new_customers_per_hour) as total_customers_all_day
    from {{ ref('agg_hourly_drink_sales') }}
    group by order_date
),



peak_hours as (
    select
        order_date,
        string_agg(cast(hour_of_day as string), ',' order by hour_of_day) as bar_peak_hours,
        max(is_weekend) as is_weekend
    from {{ ref('agg_hourly_drink_sales') }}
    where is_bar_peak_hour
    group by order_date
)

select
    h.order_date,

    sum(h.total_drink_items_ordered_per_hour) as total_drink_items_ordered_all_day,
    sum(h.total_drink_revenue_per_hour) as total_daily_drink_revenue,
    round(
        sum(h.total_drink_revenue_per_hour) / nullif(sum(h.total_drink_items_ordered_per_hour), 0), 2
    ) as avg_daily_revenue_per_drink_item,

    coalesce(max(m.drink_category_diversity_all_day), 0) as drink_category_diversity_all_day,
    max_by(h.top_drink_category_name_per_hour, h.top_drink_category_revenue_per_hour) as top_daily_drink_category_name,
    max(h.top_drink_category_revenue_per_hour) as top_daily_drink_category_revenue,
    round(
        max(h.top_drink_category_revenue_per_hour) / nullif(sum(h.total_drink_revenue_per_hour), 0), 2
    ) as pct_top_drink_cat_from_daily_drink_revenue,

    coalesce(max(m.distinct_drink_tables_used_all_day), 0) as distinct_drink_tables_all_day,
    sum(h.total_drink_orders_per_hour) as total_drink_orders_all_day,

    -- New metrics
    round(sum(h.total_drink_revenue_per_hour) / nullif(sum(h.total_drink_orders_per_hour), 0), 2) as avg_revenue_per_drink_order_all_day,
    round(sum(h.total_drink_items_ordered_per_hour) / nullif(sum(h.total_drink_orders_per_hour), 0), 2) as avg_items_per_drink_order_all_day,

    c.total_customers_all_day,
    round(sum(h.total_drink_revenue_per_hour) / nullif(c.total_customers_all_day, 0), 2) as avg_drink_revenue_per_head_all_day,
    round(sum(h.total_drink_items_ordered_per_hour) / nullif(c.total_customers_all_day, 0), 2) as avg_drink_items_per_head_all_day,

    coalesce(max(m.unique_drink_items_ordered_all_day), 0) as unique_drink_items_ordered_all_day,
    ph.bar_peak_hours,
    ph.is_weekend

from hourly h
left join metadata m on h.order_date = m.order_date
left join customers c on h.order_date = c.order_date
left join peak_hours ph on h.order_date = ph.order_date
group by h.order_date, c.total_customers_all_day, ph.bar_peak_hours, ph.is_weekend
order by h.order_date desc

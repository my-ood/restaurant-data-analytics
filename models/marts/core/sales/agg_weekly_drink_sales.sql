with daily as (
    select *
    from {{ ref('agg_daily_drink_sales') }}
),

metadata as (
    select
        order_week,
        drink_category_diversity_all_week,
        unique_drink_items_ordered_all_week
    from {{ ref('agg_weekly_metadata') }}
),

peak_hours as (
    select
        format_date('%G-%V', order_date) as order_week,
        array_to_string(array_agg(distinct hour_str order by hour_str), ',') as bar_peak_hours_weekly
    from (
        select
            order_date,
            cast(hour as string) as hour_str
        from {{ ref('agg_daily_drink_sales') }},
        unnest(split(bar_peak_hours, ',')) as hour
    )
    group by order_week
),

aggregated as (
    select
        format_date('%G-%V', order_date) as order_week,
        min(order_date) as week_start_date,
        max(order_date) as week_end_date,

        sum(total_drink_items_ordered_all_day) as total_drink_items_sold_weekly,
        sum(total_daily_drink_revenue) as total_weekly_drink_revenue,
        round(sum(total_daily_drink_revenue) / nullif(sum(total_drink_items_ordered_all_day), 0), 2) as avg_weekly_revenue_per_drink_item,

        max_by(top_daily_drink_category_name, top_daily_drink_category_revenue) as top_weekly_drink_category_name,
        max(top_daily_drink_category_revenue) as top_weekly_drink_category_revenue,
        round(max(top_daily_drink_category_revenue) / nullif(sum(total_daily_drink_revenue), 0), 2) as pct_top_drink_cat_from_weekly_drink_revenue,

        round(avg(distinct_drink_tables_all_day), 2) as avg_distinct_drink_tables_per_day_weekly,
        sum(total_drink_orders_all_day) as total_drink_orders_weekly,
        round(sum(total_daily_drink_revenue) / nullif(sum(total_drink_orders_all_day), 0), 2) as avg_revenue_per_drink_order_weekly,
        round(sum(total_drink_items_ordered_all_day) / nullif(sum(total_drink_orders_all_day), 0), 2) as avg_items_per_drink_order_weekly,
        sum(total_customers_all_day) as total_customers_weekly,
        round(sum(total_daily_drink_revenue) / nullif(sum(total_customers_all_day), 0), 2) as avg_drink_revenue_per_head_weekly,
        round(sum(total_drink_items_ordered_all_day) / nullif(sum(total_customers_all_day), 0), 2) as avg_drink_items_per_haed_weekly

    from daily
    group by order_week
),

final as (
    select
        a.*,
        m.drink_category_diversity_all_week as drink_category_diversity_weekly,
        m.unique_drink_items_ordered_all_week as unique_drink_items_ordered_weekly,
        p.bar_peak_hours_weekly
    from aggregated a
    left join metadata m using (order_week)
    left join peak_hours p using (order_week)

)

select *
from final
order by order_week desc

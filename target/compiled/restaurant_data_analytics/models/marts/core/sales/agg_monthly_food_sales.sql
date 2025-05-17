with daily as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`
),

metadata as (
    select
        order_month,
        food_category_diversity_all_month,
        unique_food_items_ordered_all_month
    from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_metadata`
),

peak_hours as (
    select
        format_date('%Y-%m', order_date) as order_month,
        array_to_string(array_agg(distinct hour_str order by hour_str), ',') as kitchen_peak_hours_monthly
    from (
        select
            order_date,
            cast(hour as string) as hour_str
        from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`,
        unnest(split(kitchen_peak_hours, ',')) as hour
    )
    group by order_month
),

aggregated as (
    select
        format_date('%Y-%m', order_date) as order_month,
        sum(total_food_items_sold_all_day) as total_food_items_sold_monthly,
        sum(total_daily_food_revenue) as total_monthly_food_revenue,
        round(sum(total_daily_food_revenue) / nullif(sum(total_food_items_sold_all_day), 0), 2) as avg_monthly_revenue_per_food_item,

        max_by(top_daily_food_category_name, top_daily_food_category_revenue) as top_monthly_food_category_name,
        max(top_daily_food_category_revenue) as top_monthly_food_category_revenue,
        round(
            max(top_daily_food_category_revenue) / nullif(sum(total_daily_food_revenue), 0),
            2
        ) as pct_top_food_cat_from_monthly_food_revenue,

        round(avg(distinct_food_tables_all_day), 2) as avg_distinct_food_tables_per_day_monthly,
        sum(total_food_orders_all_day) as total_food_orders_monthly,
        round(sum(total_daily_food_revenue) / nullif(sum(total_food_orders_all_day), 0), 2) as avg_revenue_per_food_order_monthly,
        round(sum(total_food_items_sold_all_day) / nullif(sum(total_food_orders_all_day), 0), 2) as avg_items_per_food_order_monthly,

        sum(total_customers_all_day) as total_customers_monthly,
        round(sum(total_daily_food_revenue) / nullif(sum(total_customers_all_day), 0), 2) as avg_food_revenue_per_head_monthly,
        round(sum(total_food_items_sold_all_day) / nullif(sum(total_customers_all_day), 0), 2) as avg_food_items_per_head_monthly

    from daily
    group by order_month
)

select
    a.order_month,
    a.total_food_items_sold_monthly,
    a.total_monthly_food_revenue,
    a.avg_monthly_revenue_per_food_item,
    a.top_monthly_food_category_name,
    a.top_monthly_food_category_revenue,
    a.pct_top_food_cat_from_monthly_food_revenue,
    a.avg_distinct_food_tables_per_day_monthly,
    a.total_food_orders_monthly,
    a.avg_revenue_per_food_order_monthly,
    a.avg_items_per_food_order_monthly,
    a.total_customers_monthly,
    a.avg_food_revenue_per_head_monthly,
    a.avg_food_items_per_head_monthly,
    coalesce(m.food_category_diversity_all_month, 0) as food_category_diversity_monthly,
    coalesce(m.unique_food_items_ordered_all_month, 0) as unique_food_items_ordered_monthly,
    p.kitchen_peak_hours_monthly
from aggregated a
left join metadata m using (order_month)
left join peak_hours p using (order_month)
order by order_month desc
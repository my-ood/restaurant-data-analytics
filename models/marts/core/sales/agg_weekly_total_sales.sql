with food as (
    select *
    from {{ ref('agg_weekly_food_sales') }}
),

drink as (
    select *
    from {{ ref('agg_weekly_drink_sales') }}
),

peak_hours as (
    select
        f.order_week,
        array_to_string(
            array(
                select distinct hour
                from unnest(
                    split(coalesce(f.kitchen_peak_hours_weekly, '') || ',' || coalesce(d.bar_peak_hours_weekly, ''), ',')
                ) as hour
                where safe_cast(hour as int) is not null
                order by cast(hour as int)
            ), ','
        ) as peak_hours_weekly
    from {{ ref('agg_weekly_food_sales') }} f
    join {{ ref('agg_weekly_drink_sales') }} d using (order_week)
),

combined as (
    select
        f.order_week,
        f.week_start_date,
        f.week_end_date,

        f.total_food_items_sold_weekly + d.total_drink_items_sold_weekly as total_items_ordered_weekly,
        f.total_weekly_food_revenue + d.total_weekly_drink_revenue as total_weekly_revenue,
        round(
            (f.total_weekly_food_revenue + d.total_weekly_drink_revenue) /
            nullif(f.total_food_items_sold_weekly + d.total_drink_items_sold_weekly, 0),
            2
        ) as avg_revenue_per_item_weekly,

        f.food_category_diversity_weekly + d.drink_category_diversity_weekly as category_diversity_weekly,

        case
            when f.top_weekly_food_category_revenue >= d.top_weekly_drink_category_revenue
                then f.top_weekly_food_category_name
            else d.top_weekly_drink_category_name
        end as top_weekly_category_name,

        greatest(f.top_weekly_food_category_revenue, d.top_weekly_drink_category_revenue) as top_weekly_category_revenue,

        round(f.total_weekly_food_revenue / nullif(f.total_weekly_food_revenue + d.total_weekly_drink_revenue, 0), 2) as pct_food_from_weekly_revenue,
        round(d.total_weekly_drink_revenue / nullif(f.total_weekly_food_revenue + d.total_weekly_drink_revenue, 0), 2) as pct_drink_from_weekly_revenue,
        round(
            greatest(f.top_weekly_food_category_revenue, d.top_weekly_drink_category_revenue) /
            nullif(f.total_weekly_food_revenue + d.total_weekly_drink_revenue, 0),
            2
        ) as pct_top_cat_of_total_weekly_revenue,

        f.total_customers_weekly as total_weekly_customers,
        round((f.total_weekly_food_revenue + d.total_weekly_drink_revenue) / nullif(f.total_customers_weekly, 0), 2) as avg_weekly_revenue_per_head,
        round((f.total_food_items_sold_weekly + d.total_drink_items_sold_weekly) / nullif(f.total_customers_weekly, 0), 2) as avg_items_ordered_per_head_weekly,

        f.total_food_orders_weekly + d.total_drink_orders_weekly as total_orders_weekly,
        round((f.total_food_items_sold_weekly + d.total_drink_items_sold_weekly) / nullif((f.total_food_orders_weekly + d.total_drink_orders_weekly), 0), 2) as avg_items_per_order_weekly,
        round((f.total_weekly_food_revenue + d.total_weekly_drink_revenue) / nullif((f.total_food_orders_weekly + d.total_drink_orders_weekly), 0), 2) as avg_revenue_per_order_weekly,

        f.unique_food_items_ordered_weekly + d.unique_drink_items_ordered_weekly as unique_items_ordered_weekly,

        round((f.avg_distinct_food_tables_per_day_weekly + d.avg_distinct_drink_tables_per_day_weekly) / 2, 2) as avg_distinct_tables_per_day_weekly

    from food f
    join drink d using (order_week)
),

weekly_totals as (
    select c.*,
        p.peak_hours_weekly
    from combined c
    left join peak_hours p using (order_week)
),

revenue_trends as (
    select
        *,
        round((total_weekly_revenue - lag(total_weekly_revenue) over (order by order_week)), 2) as weekly_revenue_change_amount,
        round((total_weekly_revenue - lag(total_weekly_revenue) over (order by order_week)) / nullif(lag(total_weekly_revenue) over (order by order_week), 0), 4) as pct_change_in_weekly_revenue,
        round(avg(total_weekly_revenue) over (order by order_week rows between 3 preceding and current row), 2) as rolling_avg_revenue_4wk,
        round(avg(total_items_ordered_weekly) over (order by order_week rows between 3 preceding and current row), 2) as rolling_avg_items_sold_4wk
    from weekly_totals
)

select *
from revenue_trends
order by order_week desc

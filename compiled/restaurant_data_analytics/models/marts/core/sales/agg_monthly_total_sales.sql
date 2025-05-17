

with food as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_food_sales`
),

drink as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_drink_sales`
),

metadata as (
    select
        order_month,
        weekend_days_in_month,
        unique_items_ordered_all_month,
        food_category_diversity_all_month,
        drink_category_diversity_all_month
    from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_metadata`
),

combined as (
    select
        f.order_month,
        
        f.total_food_items_sold_monthly + d.total_drink_items_sold_monthly as total_items_ordered_monthly,
        f.total_monthly_food_revenue + d.total_monthly_drink_revenue as total_monthly_revenue,
        
        round(
            (f.total_monthly_food_revenue + d.total_monthly_drink_revenue) /
            nullif(f.total_food_items_sold_monthly + d.total_drink_items_sold_monthly, 0), 2
        ) as avg_revenue_per_item_monthly,

        f.food_category_diversity_monthly + d.drink_category_diversity_monthly as category_diversity_monthly,

        case
            when f.top_monthly_food_category_revenue >= d.top_monthly_drink_category_revenue
                then f.top_monthly_food_category_name
            else d.top_monthly_drink_category_name
        end as top_monthly_category_name,

        greatest(f.top_monthly_food_category_revenue, d.top_monthly_drink_category_revenue) as top_monthly_category_revenue,

        round(f.total_monthly_food_revenue / nullif(f.total_monthly_food_revenue + d.total_monthly_drink_revenue, 0), 2) as pct_food_from_monthly_revenue,
        round(d.total_monthly_drink_revenue / nullif(f.total_monthly_food_revenue + d.total_monthly_drink_revenue, 0), 2) as pct_drink_from_monthly_revenue,
        round(
            greatest(f.top_monthly_food_category_revenue, d.top_monthly_drink_category_revenue) /
            nullif(f.total_monthly_food_revenue + d.total_monthly_drink_revenue, 0), 2
        ) as pct_top_cat_of_total_monthly_revenue,

        f.total_customers_monthly as total_monthly_customers,
        round((f.total_monthly_food_revenue + d.total_monthly_drink_revenue) / nullif(f.total_customers_monthly, 0), 2) as avg_monthly_revenue_per_head,
        round((f.total_food_items_sold_monthly + d.total_drink_items_sold_monthly) / nullif(f.total_customers_monthly, 0), 2) as avg_items_ordered_per_head_monthly,

        f.total_food_orders_monthly + d.total_drink_orders_monthly as total_orders_monthly,
        round((f.total_food_items_sold_monthly + d.total_drink_items_sold_monthly) / nullif((f.total_food_orders_monthly + d.total_drink_orders_monthly), 0), 2) as avg_items_per_order_monthly,
        round((f.total_monthly_food_revenue + d.total_monthly_drink_revenue) / nullif((f.total_food_orders_monthly + d.total_drink_orders_monthly), 0), 2) as avg_revenue_per_order_monthly,

        m.unique_items_ordered_all_month as unique_items_ordered_monthly,
        round((f.avg_distinct_food_tables_per_day_monthly + d.avg_distinct_drink_tables_per_day_monthly) / 2, 2) as avg_distinct_tables_per_day_monthly,

        m.weekend_days_in_month

    from food f
    join drink d using (order_month)
    left join metadata m using (order_month)
),

final as (
    select
        *,
        round(total_monthly_revenue - lag(total_monthly_revenue) over (order by order_month), 2) as monthly_revenue_change_amount,
        round(
            (total_monthly_revenue - lag(total_monthly_revenue) over (order by order_month)) /
            nullif(lag(total_monthly_revenue) over (order by order_month), 0), 4
        ) as pct_change_in_monthly_revenue,
        round(avg(total_monthly_revenue) over (order by order_month rows between 2 preceding and current row), 2) as rolling_avg_revenue_3mo,
        round(avg(total_items_ordered_monthly) over (order by order_month rows between 2 preceding and current row), 2) as rolling_avg_items_sold_3mo
    from combined
)

select *
from final
order by order_month desc
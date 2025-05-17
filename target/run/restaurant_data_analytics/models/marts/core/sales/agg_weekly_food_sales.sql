
  
    

    create or replace table `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_food_sales`
      
    
    

    OPTIONS()
    as (
      with daily as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`
),

metadata as (
    select
        order_week,
        food_category_diversity_all_week,
        unique_food_items_ordered_all_week
    from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_metadata`
),

peak_hours as (
    select
        format_date('%G-%V', order_date) as order_week,
        array_to_string(array_agg(distinct hour_str order by hour_str), ',') as kitchen_peak_hours_weekly
    from (
        select
            order_date,
            cast(hour as string) as hour_str
        from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`,
        unnest(split(kitchen_peak_hours, ',')) as hour
    )
    group by order_week
),

aggregated as (
    select
        format_date('%G-%V', order_date) as order_week,
        min(order_date) as week_start_date,
        max(order_date) as week_end_date,

        sum(total_food_items_sold_all_day) as total_food_items_sold_weekly,
        sum(total_daily_food_revenue) as total_weekly_food_revenue,
        round(sum(total_daily_food_revenue) / nullif(sum(total_food_items_sold_all_day), 0), 2) as avg_weekly_revenue_per_food_item,

        max_by(top_daily_food_category_name, top_daily_food_category_revenue) as top_weekly_food_category_name,
        max(top_daily_food_category_revenue) as top_weekly_food_category_revenue,
        round(max(top_daily_food_category_revenue) / nullif(sum(total_daily_food_revenue), 0), 2) as pct_top_food_cat_from_weekly_food_revenue,

        round(avg(distinct_food_tables_all_day), 2) as avg_distinct_food_tables_per_day_weekly,
        sum(total_food_orders_all_day) as total_food_orders_weekly,
        round(sum(total_daily_food_revenue) / nullif(sum(total_food_orders_all_day), 0), 2) as avg_revenue_per_food_order_weekly,
        round(sum(total_food_items_sold_all_day) / nullif(sum(total_food_orders_all_day), 0), 2) as avg_items_per_food_order_weekly,
        sum(total_customers_all_day) as total_customers_weekly,
        round(sum(total_daily_food_revenue) / nullif(sum(total_customers_all_day), 0), 2) as avg_food_revenue_per_head_weekly,
        round(sum(total_food_items_sold_all_day) / nullif(sum(total_customers_all_day), 0), 2) as avg_food_items_per_head_weekly

    from daily
    group by order_week
),

final as (
    select
        a.*,
        m.food_category_diversity_all_week as food_category_diversity_weekly,
        m.unique_food_items_ordered_all_week as unique_food_items_ordered_weekly,
        p.kitchen_peak_hours_weekly
    from aggregated a
    left join metadata m using (order_week)
    left join peak_hours p using (order_week)
)

select *
from final
order by order_week desc
    );
  
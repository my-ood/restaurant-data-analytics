
  
    

    create or replace table `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`
      
    
    

    OPTIONS()
    as (
      with hourly as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_food_sales`
),

metadata as (
    select
        order_date,
        food_category_diversity_all_day,
        distinct_food_tables_used_all_day,
        unique_food_items_ordered_all_day
    from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_metadata`
),

peak_hours as (
    select
        order_date,
        string_agg(cast(hour_of_day as string), ',' order by hour_of_day) as kitchen_peak_hours,
        max(is_weekend) as is_weekend
    from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_food_sales`
    where is_kitchen_peak_hour
    group by order_date
)

select
    h.order_date,

    sum(h.total_food_items_ordered_per_hour) as total_food_items_sold_all_day,
    sum(h.total_food_revenue_per_hour) as total_daily_food_revenue,
    round(sum(h.total_food_revenue_per_hour) / nullif(sum(h.total_food_items_ordered_per_hour), 0), 2) as avg_daily_revenue_per_food_item,

    coalesce(max(m.food_category_diversity_all_day), 0) as food_category_diversity_all_day,
    max_by(h.top_food_category_name_per_hour, h.top_food_category_revenue_per_hour) as top_daily_food_category_name,
    max(h.top_food_category_revenue_per_hour) as top_daily_food_category_revenue,
    round(max(h.top_food_category_revenue_per_hour) / nullif(sum(h.total_food_revenue_per_hour), 0), 2) as pct_top_food_cat_from_daily_food_revenue,

    coalesce(max(m.distinct_food_tables_used_all_day), 0) as distinct_food_tables_all_day,
    sum(h.total_food_orders_per_hour) as total_food_orders_all_day,
    round(sum(h.total_food_revenue_per_hour) / nullif(sum(h.total_food_orders_per_hour), 0), 2) as avg_revenue_per_food_order_all_day,
    round(sum(h.total_food_items_ordered_per_hour) / nullif(sum(h.total_food_orders_per_hour), 0), 2) as avg_items_per_food_order_all_day,

    sum(h.total_mains_ordered_per_hour) as total_customers_all_day,
    round(sum(h.total_food_revenue_per_hour) / nullif(sum(h.total_mains_ordered_per_hour), 0), 2) as avg_food_revenue_per_head_all_day,
    round(sum(h.total_food_items_ordered_per_hour) / nullif(sum(h.total_mains_ordered_per_hour), 0), 2) as avg_food_items_per_head_all_day,

    coalesce(max(m.unique_food_items_ordered_all_day), 0) as unique_food_items_ordered_all_day,
    ph.kitchen_peak_hours,
    ph.is_weekend

from hourly h
left join metadata m on h.order_date = m.order_date
left join peak_hours ph on h.order_date = ph.order_date
group by h.order_date, ph.kitchen_peak_hours, ph.is_weekend
order by h.order_date desc
    );
  

  
    

    create or replace table `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_metadata`
      
    
    

    OPTIONS()
    as (
      

with base as (
    select
        format_date('%Y-%m', order_date) as order_month,
        order_date,
        item_uuid,
        category,
        production_department
    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
),

unique_items_ordered as (
    select
        order_month,
        count(distinct item_uuid) as unique_items_ordered_all_month
    from base
    group by order_month
),

monthly_food_stats as (
    select
        order_month,
        count(distinct category) as food_category_diversity_all_month,
        count(distinct item_uuid) as unique_food_items_ordered_all_month
    from base
    where production_department = 'kitchen'
    group by order_month
),

monthly_drink_stats as (
    select
        order_month,
        count(distinct category) as drink_category_diversity_all_month,
        count(distinct item_uuid) as unique_drink_items_ordered_all_month
    from base
    where production_department = 'bar'
    group by order_month
),

weekend_counts as (
    select
        format_date('%Y-%m', order_date) as order_month,
        count(distinct order_date) as weekend_days_in_month
    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
    where extract(dayofweek from order_date) in (1, 6, 7)  -- Sunday = 1, Friday = 6, Saturday = 7
    group by order_month
)

select
    uio.order_month,
    uio.unique_items_ordered_all_month,
    fds.food_category_diversity_all_month,
    fds.unique_food_items_ordered_all_month,
    dds.drink_category_diversity_all_month,
    dds.unique_drink_items_ordered_all_month,
    wc.weekend_days_in_month
from unique_items_ordered uio
left join monthly_food_stats fds using (order_month)
left join monthly_drink_stats dds using (order_month)
left join weekend_counts wc using (order_month)
order by uio.order_month desc
    );
  
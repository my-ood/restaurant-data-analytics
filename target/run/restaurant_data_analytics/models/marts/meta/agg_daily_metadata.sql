
  
    

    create or replace table `annular-mesh-453913-r6`.`dbt_`.`agg_daily_metadata`
      
    
    

    OPTIONS()
    as (
      

with base as (
    select
        order_date,
        item_uuid,
        category,
        production_department,
        table_no
    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
),

daily_table_stats  as (
    select
        order_date,
        count(distinct table_no) as distinct_tables_used_all_day
    from base
    group by order_date
),

daily_food_stats  as (
    select
        order_date,
        count(distinct category) as food_category_diversity_all_day,
        count(distinct table_no) as food_tables_used_all_day,
        count(distinct item_uuid) as unique_food_items_ordered_all_day
    from base
    where production_department = 'kitchen'
    group by order_date
),

daily_drink_stats  as (
    select
        order_date,
        count(distinct category) as drink_category_diversity_all_day,
        count(distinct table_no) as drink_tables_used_all_day,
        count(distinct item_uuid) as unique_drink_items_ordered_all_day
    from base
    where production_department = 'bar'
    group by order_date
)

select
    dts.order_date,
    dts.distinct_tables_used_all_day,
    coalesce(dfs.food_category_diversity_all_day, 0) as food_category_diversity_all_day,
    coalesce(dfs.food_tables_used_all_day, 0) as distinct_food_tables_used_all_day,
    coalesce(dfs.unique_food_items_ordered_all_day, 0) as unique_food_items_ordered_all_day,
    coalesce(dds.drink_category_diversity_all_day, 0) as drink_category_diversity_all_day,
    coalesce(dds.drink_tables_used_all_day, 0) as distinct_drink_tables_used_all_day,
    coalesce(dds.unique_drink_items_ordered_all_day, 0) as unique_drink_items_ordered_all_day
from daily_table_stats dts
left join daily_food_stats dfs using (order_date)
left join daily_drink_stats dds using (order_date)
order by order_date desc
    );
  
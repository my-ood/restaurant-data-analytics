
  
    

    create or replace table `annular-mesh-453913-r6`.`dbt_`.`agg_category_performance`
      
    
    

    OPTIONS()
    as (
      with enriched_orders as (
    select
        o.item_uuid,
        o.quantity,
        o.total_item_revenue,
        m.category,
        m.menu_source,
        m.price,
        date(o.datetime_ordered) as order_date
    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders` o
    join `annular-mesh-453913-r6`.`dbt_`.`dim_menu_items` m using (item_uuid)
),

category_metrics as (
    select
        category,
        menu_source,
        sum(quantity) as total_units_sold,
        sum(total_item_revenue) as total_revenue,
        avg(price) as avg_price,
        round(sum(total_item_revenue) / nullif(sum(quantity), 0), 2) as avg_price_per_unit
    from enriched_orders
    group by category, menu_source
),

category_metrics_last_30_days as (
    select
        category,
        menu_source,
        sum(quantity) as total_units_sold_30d,
        sum(total_item_revenue) as total_revenue_30d
    from enriched_orders
    where order_date >= current_date - interval 30 day
    group by category, menu_source
),

category_metrics_last_7_days as (
    select
        category,
        menu_source,
        sum(quantity) as total_units_sold_7d,
        sum(total_item_revenue) as total_revenue_7d
    from enriched_orders
    where order_date >= current_date - interval 7 day
    group by category, menu_source
)

select
    cm.*,
    coalesce(cm30.total_units_sold_30d, 0) as total_units_sold_30d,
    coalesce(cm30.total_revenue_30d, 0.0) as total_revenue_30d,
    coalesce(cm7.total_units_sold_7d, 0) as total_units_sold_7d,
    coalesce(cm7.total_revenue_7d, 0.0) as total_revenue_7d
from category_metrics cm
left join category_metrics_last_30_days cm30 using (category, menu_source)
left join category_metrics_last_7_days cm7 using (category, menu_source)
order by cm.total_revenue desc
    );
  
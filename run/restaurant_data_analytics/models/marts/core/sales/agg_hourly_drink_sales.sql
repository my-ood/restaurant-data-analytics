
  
    

    create or replace table `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_drink_sales`
      
    
    

    OPTIONS()
    as (
      with base as (
    select
        datetime_trunc(datetime_ordered, hour) as order_hour_dt,
        date(datetime_ordered) as order_date,
        extract(hour from datetime_ordered) as hour_of_day,
        order_uuid,
        table_no,
        item_uuid,
        quantity,
        total_item_revenue,
        price,
        category
    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
    where production_department = 'bar'
),

top_drink_category as (
    select
        order_hour_dt,
        category as top_drink_category_name_per_hour,
        sum(quantity * price) as top_drink_category_revenue_per_hour,
        rank() over (partition by order_hour_dt order by sum(quantity * price) desc) as rnk
    from base
    group by order_hour_dt, category
),

bar_peak_hours as (
    select
        order_hour_dt,
        row_number() over (partition by order_date order by sum(quantity) desc) as bar_hour_rank
    from base
    group by order_hour_dt, order_date
),

drink_agg as (
    select
        order_hour_dt,
        order_date,
        hour_of_day,
        count(distinct table_no) as distinct_drink_tables_per_hour,
        array_to_string(array_agg(distinct cast(table_no as string) order by table_no), ',') as open_table_ids_per_hour,
        count(distinct order_uuid) as total_drink_orders_per_hour,
        sum(quantity) as total_drink_items_ordered_per_hour,
        sum(total_item_revenue) as total_drink_revenue_per_hour,
        round(sum(total_item_revenue) / nullif(sum(quantity), 0), 2) as avg_revenue_per_drink_item_per_hour,
        count(distinct item_uuid) as unique_drink_items_ordered_per_hour,
        count(distinct category) as drink_category_diversity_per_hour
    from base
    group by order_hour_dt, order_date, hour_of_day
)


select
    d.order_hour_dt,
    d.order_date,
    d.hour_of_day,
    d.total_drink_items_ordered_per_hour,
    d.total_drink_revenue_per_hour,
    d.avg_revenue_per_drink_item_per_hour,
    td.top_drink_category_name_per_hour,
    td.top_drink_category_revenue_per_hour,
    round(td.top_drink_category_revenue_per_hour / nullif(d.total_drink_revenue_per_hour, 0), 2) as pct_top_drink_cat_of_drink_revenue_per_hour,
    d.distinct_drink_tables_per_hour,
    d.open_table_ids_per_hour,
    d.total_drink_orders_per_hour,
    round(d.total_drink_revenue_per_hour / nullif(d.total_drink_orders_per_hour, 0), 2) as avg_revenue_per_drink_order_per_hour,
    round(d.total_drink_items_ordered_per_hour / nullif(d.total_drink_orders_per_hour, 0), 2) as avg_items_per_drink_order_per_hour,
    cc.total_mains_ordered_per_hour as new_customers_per_hour,
    coalesce(round(d.total_drink_items_ordered_per_hour / nullif(cc.total_mains_ordered_per_hour, 0), 2), 0) as avg_drink_items_per_head_per_hour,
    coalesce(round(d.total_drink_revenue_per_hour / nullif(cc.total_mains_ordered_per_hour, 0), 2), 0) as avg_drink_revenue_per_head_per_hour,
    d.unique_drink_items_ordered_per_hour,
    d.drink_category_diversity_per_hour,
    b.bar_hour_rank <= 2 as is_bar_peak_hour,
    case 
      when extract(dayofweek from d.order_date) in (1, 6, 7) then true
      else false
    end as is_weekend
from drink_agg d
left join top_drink_category td on d.order_hour_dt = td.order_hour_dt and td.rnk = 1
left join bar_peak_hours b on d.order_hour_dt = b.order_hour_dt
left join `annular-mesh-453913-r6`.`dbt_`.`agg_customer_counts` cc on d.order_hour_dt = cc.order_hour_dt
order by d.order_hour_dt desc
    );
  
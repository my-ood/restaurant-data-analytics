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
    from {{ ref('fct_orders') }}
    where production_department = 'kitchen'
),

top_food_category as (
    select
        order_hour_dt,
        category as top_food_category_name_per_hour,
        sum(quantity * price) as top_food_category_revenue_per_hour,
        rank() over (partition by order_hour_dt order by sum(quantity * price) desc) as rnk
    from base
    group by order_hour_dt, category
),

kitchen_peak_hours as (
    select
        order_hour_dt,
        row_number() over (partition by order_date order by sum(quantity) desc) as kitchen_hour_rank
    from base
    group by order_hour_dt, order_date
),

food_agg as (
    select
        order_hour_dt,
        order_date,
        hour_of_day,
        count(distinct table_no) as distinct_food_tables_per_hour,
        array_to_string(array_agg(distinct cast(table_no as string) order by table_no), ',') as open_table_ids_per_hour,
        count(distinct order_uuid) as total_food_orders_per_hour,
        sum(quantity) as total_food_items_ordered_per_hour,
        round(sum(total_item_revenue), 2) as total_food_revenue_per_hour,
        round(sum(total_item_revenue) / nullif(sum(quantity), 0), 2) as avg_revenue_per_food_item_per_hour,
        count(distinct item_uuid) as unique_food_items_ordered_per_hour,
        count(distinct category) as food_category_diversity_per_hour
    from base
    group by order_hour_dt, order_date, hour_of_day
)


select
    f.order_hour_dt,
    f.order_date,
    f.hour_of_day,
    f.total_food_items_ordered_per_hour,
    f.total_food_revenue_per_hour,
    f.avg_revenue_per_food_item_per_hour,
    tf.top_food_category_name_per_hour,
    tf.top_food_category_revenue_per_hour,
    coalesce(round(tf.top_food_category_revenue_per_hour / nullif(f.total_food_revenue_per_hour, 0), 2),0) as pct_top_food_cat_of_food_revenue_per_hour,
    f.distinct_food_tables_per_hour,
    f.open_table_ids_per_hour,
    coalesce(cc.total_mains_ordered_per_hour, 0) as total_mains_ordered_per_hour,
    coalesce(round(f.total_food_revenue_per_hour / nullif(cc.total_mains_ordered_per_hour, 0), 2),0) as avg_food_revenue_per_head_per_hour,
    coalesce(round(f.total_food_items_ordered_per_hour / nullif(cc.total_mains_ordered_per_hour, 0), 2), 0) as avg_food_items_per_head_per_hour,
    f.total_food_orders_per_hour,
    coalesce(round(f.total_food_revenue_per_hour / nullif(f.total_food_orders_per_hour, 0), 2),0) as avg_revenue_per_food_order_per_hour,
    coalesce(round(f.total_food_items_ordered_per_hour / nullif(f.total_food_orders_per_hour, 0), 2),0) as avg_items_per_food_order_per_hour,
    f.unique_food_items_ordered_per_hour,
    f.food_category_diversity_per_hour,
    (k.kitchen_hour_rank <= 2) as is_kitchen_peak_hour,
    case 
      when extract(dayofweek from f.order_date) in (1, 6, 7) then true
      else false
    end as is_weekend
from food_agg f
left join top_food_category tf on f.order_hour_dt = tf.order_hour_dt and tf.rnk = 1
left join kitchen_peak_hours k on f.order_hour_dt = k.order_hour_dt
left join {{ ref('agg_customer_counts') }} cc on f.order_hour_dt = cc.order_hour_dt
order by f.order_hour_dt desc


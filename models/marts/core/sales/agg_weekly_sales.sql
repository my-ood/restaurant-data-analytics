with base as (
    select *,
           format_date('%G-%V', order_date) as order_week
    from {{ ref('agg_daily_sales') }}
),

weekly_kpis as (
    select
        order_week,
        min(order_date) as week_start_date,
        max(order_date) as week_end_date,
        sum(total_revenue) as total_revenue,
        sum(total_items_sold) as total_items_sold,
        avg(distinct_tables) as avg_distinct_tables,
        round(sum(total_revenue) / sum(total_items_sold), 2) as revenue_per_item,
        sum(total_customers) as total_customers,
        sum(total_food_revenue) as total_food_revenue,
        sum(total_drinks_revenue) as total_drinks_revenue,
    from base
    group by order_week
),


top_food as (
    select
        order_week,
        top_food_category as category,
        sum(top_food_category_revenue) as category_revenue,
        row_number() over (
            partition by order_week
            order by sum(top_food_category_revenue) desc
        ) as rnk
    from base
    group by order_week, top_food_category
),

top_drinks as (
    select
        order_week,
        top_drinks_category as category,
        sum(top_drinks_category_revenue) as category_revenue,
        row_number() over (
            partition by order_week
            order by sum(top_drinks_category_revenue) desc
        ) as rnk
    from base
    group by order_week, top_drinks_category
),

busiest_hours as (
    select
        order_week,
        busiest_hour,
        count(*) as frequency,
        row_number() over (
            partition by order_week
            order by count(*) desc
        ) as hour_rank
    from base
    group by order_week, busiest_hour
),

with_changes as (
    select
        *,
        round(total_revenue - lag(total_revenue) over (order by order_week), 2) as revenue_change,
        round(
            (total_revenue - lag(total_revenue) over (order by order_week)) /
            nullif(lag(total_revenue) over (order by order_week), 0), 4
        ) as revenue_change_pct,
        round(avg(total_revenue) over (
            order by order_week rows between 3 preceding and current row
        ), 2) as rolling_avg_revenue_4w,
        round(avg(total_items_sold) over (
            order by order_week rows between 3 preceding and current row
        ), 2) as rolling_avg_items_sold_4w
    from weekly_kpis
)

select
    d.order_week,
    d.week_start_date,
    d.week_end_date,
    d.total_revenue,
    d.total_food_revenue,
    round(d.total_food_revenue / d.total_revenue, 2) as pct_food_revenue,
    d.total_drinks_revenue,
    round(d.total_drinks_revenue / d.total_revenue, 2) as pct_drinks_revenue,

    tf.category as top_food_category,
    tf.category_revenue as top_food_category_revenue,
    round(tf.category_revenue / d.total_food_revenue, 2) as pct_top_food_cat_revenue,

    td.category as top_drinks_category,
    td.category_revenue as top_drinks_category_revenue,
    round(td.category_revenue / d.total_drinks_revenue, 2) as pct_top_drinks_cat_revenue,

    d.total_items_sold,
    d.avg_distinct_tables,
    d.total_customers,
    round(d.total_revenue / d.total_customers, 2) as avg_spend_per_head,
    d.revenue_per_item,
    round(d.total_items_sold / d.total_customers, 2) as items_per_customer,
    d.revenue_change,
    d.revenue_change_pct,
    d.rolling_avg_revenue_4w,
    d.rolling_avg_items_sold_4w,
    bh.busiest_hour
from with_changes d
left join {{ ref('agg_weekly_item_metadata') }} using (order_week)
left join top_food tf on d.order_week = tf.order_week and tf.rnk = 1
left join top_drinks td on d.order_week = td.order_week and td.rnk = 1
left join busiest_hours bh on d.order_week = bh.order_week and bh.hour_rank = 1
order by d.order_week

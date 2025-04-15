with base as (
    select *, format_date('%Y-%m', order_date) as order_month
    from {{ ref('agg_daily_sales') }}
),

monthly_kpis as (
    select
        order_month,
        sum(total_revenue) as total_revenue,
        sum(total_items_sold) as total_items_sold,
        round(avg(distinct_tables), 2) as avg_distinct_tables,
        round(sum(total_revenue) / nullif(sum(total_items_sold), 0), 2) as revenue_per_item,
        sum(total_customers) as total_customers,
        sum(total_food_revenue) as total_food_revenue,
        sum(total_drinks_revenue) as total_drinks_revenue,
        countif(is_weekend) as weekend_days
    from base
    group by order_month
),

top_food as (
    select
        order_month,
        top_food_category as category,
        sum(top_food_category_revenue) as category_revenue,
        row_number() over (
            partition by order_month
            order by sum(top_food_category_revenue) desc
        ) as rnk
    from base
    group by order_month, top_food_category
),

top_drinks as (
    select
        order_month,
        top_drinks_category as category,
        sum(top_drinks_category_revenue) as category_revenue,
        row_number() over (
            partition by order_month
            order by sum(top_drinks_category_revenue) desc
        ) as rnk
    from base
    group by order_month, top_drinks_category
),

monthly_hour_counts as (
    select
        order_month,
        busiest_hour,
        count(*) as hour_count
    from base
    group by order_month, busiest_hour
),

busiest_hours as (
    select *,
        row_number() over (
            partition by order_month
            order by hour_count desc
        ) as hour_rank
    from monthly_hour_counts
),

unique_items_ordered as (
    select
        format_date('%Y-%m', order_date) as order_month,
        count(distinct item_uuid) as unique_items_ordered
    from {{ ref('fct_orders') }}
    group by order_month
),

monthly_food_category_diversity as (
    select
        format_date('%Y-%m', order_date) as order_month,
        count(distinct category) as food_category_diversity
    from {{ ref('fct_orders') }}
    where production_department = 'kitchen'
    group by order_month
),

monthly_drinks_category_diversity as (
    select
        format_date('%Y-%m', order_date) as order_month,
        count(distinct category) as drinks_category_diversity
    from {{ ref('fct_orders') }}
    where production_department = 'bar'
    group by order_month
),

with_changes as (
    select
        *,
        round(total_revenue - lag(total_revenue) over (order by order_month), 2) as revenue_change,
        round(
            (total_revenue - lag(total_revenue) over (order by order_month)) /
            nullif(lag(total_revenue) over (order by order_month), 0), 4
        ) as revenue_change_pct,
        round(avg(total_revenue) over (
            order by order_month rows between 2 preceding and current row
        ), 2) as rolling_avg_revenue_3m,
        round(avg(total_items_sold) over (
            order by order_month rows between 2 preceding and current row
        ), 2) as rolling_avg_items_sold_3m
    from monthly_kpis
)

select
    d.order_month,
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
    round(d.total_revenue / nullif(d.total_customers, 0), 2) as avg_spend_per_head,
    d.revenue_per_item,
    round(d.total_items_sold / nullif(d.total_customers, 0), 2) as items_per_customer,
    uio.unique_items_ordered,
    mfd.food_category_diversity as food_category_diversity,
    mdd.drinks_category_diversity as drinks_category_diversity,
    d.weekend_days,
    d.revenue_change,
    d.revenue_change_pct,
    d.rolling_avg_revenue_3m,
    d.rolling_avg_items_sold_3m,
    bh.busiest_hour
from with_changes d
left join unique_items_ordered uio using (order_month)
left join monthly_food_category_diversity mfd using (order_month)
left join monthly_drinks_category_diversity mdd using (order_month)
left join top_food tf on d.order_month = tf.order_month and tf.rnk = 1
left join top_drinks td on d.order_month = td.order_month and td.rnk = 1
left join busiest_hours bh on d.order_month = bh.order_month and bh.hour_rank = 1
order by d.order_month

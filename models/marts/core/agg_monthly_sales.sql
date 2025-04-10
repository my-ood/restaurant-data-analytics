with base as (
    select *, 
           format_date('%Y-%m', order_date) as order_month
    from {{ ref('fct_orders') }}
),

total_customers as (
    select
        order_month,
        count(*) as total_customers
    from base
    where category in ('Mains', 'Large Cuts', 'Steaks')
    group by order_month
),

monthly_kpis as (
    select
        order_month,
        sum(total_item_revenue) as total_revenue,
        sum(quantity) as total_items_sold,
        round(count(distinct order_date || '-' || table_no) * 1.0 / count(distinct order_date), 2) as avg_distinct_tables,
        round(sum(total_item_revenue) / sum(quantity), 2) as revenue_per_item,
        count(distinct item_uuid) as unique_items_ordered,
        count(distinct case when format_date('%A', order_date) in ('Friday', 'Saturday', 'Sunday') then order_date end) as weekend_days
    from base
    group by order_month
),

total_food_revenue as (
    select
        order_month,
        sum(quantity * price) as total_food_revenue,
        count(distinct category) as food_category_diversity
    from base
    where production_department = 'kitchen'
    group by order_month
),

top_food as (
    select
        order_month,
        category as top_food_category,
        sum(quantity * price) as top_food_category_revenue,
        rank() over (partition by order_month order by sum(quantity * price) desc) as rnk
    from base
    where production_department = 'kitchen'
    group by order_month, category
),

total_drinks_revenue as (
    select
        order_month,
        sum(quantity * price) as total_drinks_revenue,
        count(distinct category) as drinks_category_diversity
    from base
    where production_department = 'bar'
    group by order_month
),

top_drinks as (
    select
        order_month,
        category as top_drinks_category,
        sum(quantity * price) as top_drinks_category_revenue,
        rank() over (partition by order_month order by sum(quantity * price) desc) as rnk
    from base
    where production_department = 'bar'
    group by order_month, category
),

busiest_hours as (
    select
        order_month,
        order_hour,
        sum(quantity) as items_per_hour,
        row_number() over (partition by order_month order by sum(quantity) desc) as hour_rank
    from base
    group by order_month, order_hour
),

with_changes as (
    select
        *,
        round(total_revenue - lag(total_revenue) over (order by order_month), 2) as revenue_change,
        round((total_revenue - lag(total_revenue) over (order by order_month)) / lag(total_revenue) over (order by order_month), 4) as revenue_change_pct,
        round(avg(total_revenue) over (order by order_month rows between 2 preceding and current row), 2) as rolling_avg_revenue_3m,
        round(avg(total_items_sold) over (order by order_month rows between 2 preceding and current row), 2) as rolling_avg_items_sold_3m
    from monthly_kpis
)

select
    d.order_month,
    d.total_revenue,
    f.total_food_revenue,
    round(f.total_food_revenue / d.total_revenue, 2) as pct_food_revenue,
    dr.total_drinks_revenue,
    round(dr.total_drinks_revenue / d.total_revenue, 2) as pct_drinks_revenue,
    tf.top_food_category,
    tf.top_food_category_revenue,
    round(tf.top_food_category_revenue / f.total_food_revenue, 2) as pct_top_food_cat_revenue,
    td.top_drinks_category,
    td.top_drinks_category_revenue,
    round(td.top_drinks_category_revenue / dr.total_drinks_revenue, 2) as pct_top_drinks_cat_revenue,
    d.total_items_sold,
    d.avg_distinct_tables,
    tc.total_customers,
    round(d.total_revenue / tc.total_customers, 2) as avg_spend_per_head,
    d.revenue_per_item,
    round(d.total_items_sold / tc.total_customers, 2) as items_per_customer,
    d.unique_items_ordered,
    f.food_category_diversity,
    dr.drinks_category_diversity,
    d.weekend_days,
    d.revenue_change,
    d.revenue_change_pct,
    d.rolling_avg_revenue_3m,
    d.rolling_avg_items_sold_3m,
    bh.order_hour as busiest_hour
from with_changes d
left join total_food_revenue f
    on d.order_month = f.order_month
left join total_drinks_revenue dr
    on d.order_month = dr.order_month
left join top_food tf
    on d.order_month = tf.order_month and tf.rnk = 1
left join top_drinks td
    on d.order_month = td.order_month and td.rnk = 1
left join busiest_hours bh
    on d.order_month = bh.order_month and bh.hour_rank = 1
left join total_customers tc
    on d.order_month = tc.order_month
order by d.order_month

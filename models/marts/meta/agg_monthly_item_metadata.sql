{{ config(
    tags=['meta', 'intermediate'],
    materialized='table'
) }}

with base as (
    select
        format_date('%Y-%m', order_date) as order_month,
        item_uuid,
        category,
        production_department
    from {{ ref('fct_orders') }}
),

unique_items_ordered as (
    select
        order_month,
        count(distinct item_uuid) as unique_items_ordered
    from base
    group by order_month
),

monthly_food_category_diversity as (
    select
        order_month,
        count(distinct category) as food_category_diversity
    from base
    where production_department = 'kitchen'
    group by order_month
),

monthly_drinks_category_diversity as (
    select
        order_month,
        count(distinct category) as drinks_category_diversity
    from base
    where production_department = 'bar'
    group by order_month
)

select
    uio.order_month,
    uio.unique_items_ordered,
    fcd.food_category_diversity,
    dcd.drinks_category_diversity
from unique_items_ordered uio
left join monthly_food_category_diversity fcd using (order_month)
left join monthly_drinks_category_diversity dcd using (order_month)

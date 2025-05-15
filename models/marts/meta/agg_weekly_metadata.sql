{{ config(
    tags=['meta', 'intermediate'],
    materialized='table'
) }}

-- Base table extracting order week, item, category, and department
with base as (
    select
        format_date('%G-%V', order_date) as order_week,
        item_uuid,
        category,
        production_department
    from {{ ref('fct_orders') }}
),

-- Count of unique food items ordered per week (kitchen only)
unique_food_items_ordered as (
    select
        order_week,
        count(distinct item_uuid) as unique_food_items_ordered_all_week
    from base
    where production_department = 'kitchen'
    group by order_week
),

-- Count of unique drink items ordered per week (bar only)
unique_drink_items_ordered as (
    select
        order_week,
        count(distinct item_uuid) as unique_drink_items_ordered_all_week
    from base
    where production_department = 'bar'
    group by order_week
),

-- Count of unique food categories per week
weekly_food_category_diversity as (
    select
        order_week,
        count(distinct category) as food_category_diversity_all_week
    from base
    where production_department = 'kitchen'
    group by order_week
),

-- Count of unique drink categories per week
weekly_drink_category_diversity as (
    select
        order_week,
        count(distinct category) as drink_category_diversity_all_week
    from base
    where production_department = 'bar'
    group by order_week
)

select
    fio.order_week,
    fio.unique_food_items_ordered_all_week,
    dio.unique_drink_items_ordered_all_week,
    fcd.food_category_diversity_all_week,
    dcd.drink_category_diversity_all_week
from unique_food_items_ordered fio
-- Using INNER JOIN here because we assume every week has both food and drink orders,
-- so there will always be matching order_week values in both tables.
inner join unique_drink_items_ordered dio using (order_week)
-- LEFT JOINs used for category diversity tables in case any week is missing categories
left join weekly_food_category_diversity fcd using (order_week)
left join weekly_drink_category_diversity dcd using (order_week)
order by order_week desc

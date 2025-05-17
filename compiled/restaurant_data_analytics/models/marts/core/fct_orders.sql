with base_orders as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`stg_orders`
),

menu_lookup as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`dim_menu_items`
)

select
    o.item_ordered_id,
    o.table_no,
    o.item_uuid,
    o.datetime_ordered,
    o.production_department,
    o.order_uuid,
    o.quantity,

    -- Date/time breakdown
    date(o.datetime_ordered) as order_date,
    extract(hour from o.datetime_ordered) as order_hour,
    format_date('%A', date(o.datetime_ordered)) as order_weekday,

    -- Menu info
    m.item_name,
    m.category,
    m.price,
    m.menu_source,

    -- Revenue
    o.quantity * m.price as total_item_revenue

from base_orders o
left join menu_lookup m
  on o.item_uuid = m.item_uuid


  create or replace view `annular-mesh-453913-r6`.`dbt_`.`stg_orders`
  OPTIONS()
  as with aggregated_orders as (
    select
        table_no,
        item_uuid,
        datetime_ordered,
        dep,
        order_uuid,
        count(*) as quantity
    from `annular-mesh-453913-r6`.`restaurant_data`.`orders`
    group by table_no, item_uuid, datetime_ordered, dep, order_uuid
)

select
    to_hex(md5(cast(coalesce(cast(table_no as string), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(item_uuid as string), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(datetime_ordered as string), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(dep as string), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(order_uuid as string), '_dbt_utils_surrogate_key_null_') as string))) as item_ordered_id,
    table_no,
    item_uuid,
    datetime_ordered,
    dep as production_department,
    order_uuid,
    quantity
from aggregated_orders;


with aggregated_orders as (
    select
        table_no,
        item_uuid,
        datetime_ordered,
        dep,
        order_uuid,
        count(*) as quantity
    from {{ source('restaurant_data', 'orders') }}
    group by table_no, item_uuid, datetime_ordered, dep, order_uuid
)

select
    {{ dbt_utils.generate_surrogate_key(['table_no', 'item_uuid', 'datetime_ordered', 'dep', 'order_uuid']) }} as item_ordered_id,
    table_no,
    item_uuid,
    datetime_ordered,
    dep as production_department,
    order_uuid,
    quantity
from aggregated_orders

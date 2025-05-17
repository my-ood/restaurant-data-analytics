
    
    

with child as (
    select item_uuid as from_field
    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
    where item_uuid is not null
),

parent as (
    select item_uuid as to_field
    from `annular-mesh-453913-r6`.`dbt_`.`dim_menu_items`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



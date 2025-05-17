
    
    

with all_values as (

    select
        menu_source as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
    group by menu_source

)

select *
from all_values
where value_field not in (
    'a_la_carte','wine','dessert','cocktails_and_beer'
)



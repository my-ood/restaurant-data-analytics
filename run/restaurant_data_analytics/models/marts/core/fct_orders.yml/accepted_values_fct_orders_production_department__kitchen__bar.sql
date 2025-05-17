select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        production_department as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
    group by production_department

)

select *
from all_values
where value_field not in (
    'kitchen','bar'
)



      
    ) dbt_internal_test
select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        order_weekday as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
    group by order_weekday

)

select *
from all_values
where value_field not in (
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
)



      
    ) dbt_internal_test
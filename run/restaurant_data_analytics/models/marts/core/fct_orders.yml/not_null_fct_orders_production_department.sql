select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select production_department
from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
where production_department is null



      
    ) dbt_internal_test
select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select item_uuid
from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
where item_uuid is null



      
    ) dbt_internal_test
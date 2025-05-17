select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select item_ordered_id
from `annular-mesh-453913-r6`.`dbt_`.`stg_orders`
where item_ordered_id is null



      
    ) dbt_internal_test
select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_item_revenue
from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
where total_item_revenue is null



      
    ) dbt_internal_test
select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select order_week
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_food_sales`
where order_week is null



      
    ) dbt_internal_test
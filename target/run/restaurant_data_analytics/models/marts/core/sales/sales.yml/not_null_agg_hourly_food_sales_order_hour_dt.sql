select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select order_hour_dt
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_food_sales`
where order_hour_dt is null



      
    ) dbt_internal_test
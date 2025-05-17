select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select order_date
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_total_sales`
where order_date is null



      
    ) dbt_internal_test
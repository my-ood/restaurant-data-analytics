select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select hour_of_day
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_total_sales`
where hour_of_day is null



      
    ) dbt_internal_test
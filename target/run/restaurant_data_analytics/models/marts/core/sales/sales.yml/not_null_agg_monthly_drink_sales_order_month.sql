select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select order_month
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_drink_sales`
where order_month is null



      
    ) dbt_internal_test
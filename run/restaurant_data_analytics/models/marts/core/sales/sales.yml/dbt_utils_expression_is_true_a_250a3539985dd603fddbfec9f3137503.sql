select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_drink_sales`

where not(avg_revenue_per_drinks_order_monthly >= 0)


      
    ) dbt_internal_test
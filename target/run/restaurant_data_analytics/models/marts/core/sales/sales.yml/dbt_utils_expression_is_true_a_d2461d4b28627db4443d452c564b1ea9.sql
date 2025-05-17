select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_total_sales`

where not(avg_monthly_revenue_per_head >= 0)


      
    ) dbt_internal_test
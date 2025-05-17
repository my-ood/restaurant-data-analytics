select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_total_sales`

where not(avg_weekly_revenue_per_head <= total_weekly_revenue)


      
    ) dbt_internal_test
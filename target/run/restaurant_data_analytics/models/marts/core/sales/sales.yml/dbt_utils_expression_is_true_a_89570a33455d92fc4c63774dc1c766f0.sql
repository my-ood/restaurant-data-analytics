select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_total_sales`

where not(avg_items_per_order_monthly <= total_items_ordered_monthly)


      
    ) dbt_internal_test
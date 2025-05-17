select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_total_sales`

where not(avg_items_per_order_weekly <= total_items_ordered_weekly)


      
    ) dbt_internal_test
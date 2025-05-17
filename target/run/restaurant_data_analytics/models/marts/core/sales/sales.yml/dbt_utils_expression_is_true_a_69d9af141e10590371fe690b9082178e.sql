select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_drink_sales`

where not(avg_drink_items_per_haed_weekly <= total_drink_items_sold_weekly)


      
    ) dbt_internal_test
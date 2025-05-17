select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_drink_sales`

where not(unique_drink_items_ordered_per_hour >= 0)


      
    ) dbt_internal_test
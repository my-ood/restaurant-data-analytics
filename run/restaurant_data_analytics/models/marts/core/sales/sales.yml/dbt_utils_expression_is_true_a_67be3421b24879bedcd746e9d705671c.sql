select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_drink_sales`

where not(avg_items_per_drink_order_per_hour >= 1)


      
    ) dbt_internal_test
select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`

where not(total_food_items_sold_all_day >= 0)


      
    ) dbt_internal_test
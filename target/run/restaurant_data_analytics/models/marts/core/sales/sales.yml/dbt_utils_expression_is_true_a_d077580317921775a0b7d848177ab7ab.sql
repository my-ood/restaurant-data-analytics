select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_food_sales`

where not(top_food_category_revenue_per_hour <= total_food_revenue_per_hour)


      
    ) dbt_internal_test
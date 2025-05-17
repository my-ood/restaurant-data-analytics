select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`

where not(avg_food_revenue_per_head_all_day <= total_daily_food_revenue)


      
    ) dbt_internal_test
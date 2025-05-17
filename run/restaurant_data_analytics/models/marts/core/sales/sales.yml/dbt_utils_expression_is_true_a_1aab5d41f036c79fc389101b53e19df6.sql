select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_drink_sales`

where not(top_weekly_drink_category_revenue <= total_weekly_drink_revenue)


      
    ) dbt_internal_test




select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_food_sales`

where not(top_monthly_food_category_revenue <= total_monthly_food_revenue)


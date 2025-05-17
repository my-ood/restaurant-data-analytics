



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_food_sales`

where not(avg_monthly_revenue_per_food_item <= total_monthly_food_revenue)


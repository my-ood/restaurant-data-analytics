



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_food_sales`

where not(avg_food_revenue_per_head_monthly <= total_monthly_food_revenue)


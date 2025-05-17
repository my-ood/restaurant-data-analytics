



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_food_sales`

where not(avg_food_revenue_per_head_weekly <= total_weekly_food_revenue)


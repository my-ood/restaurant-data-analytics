



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`

where not(avg_revenue_per_food_order_all_day >= 0)


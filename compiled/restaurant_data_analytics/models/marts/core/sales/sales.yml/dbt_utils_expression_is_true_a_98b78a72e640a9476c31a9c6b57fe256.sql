



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_food_sales`

where not(avg_revenue_per_food_item_per_hour <= total_food_revenue_per_hour)


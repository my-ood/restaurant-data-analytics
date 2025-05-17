



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_food_sales`

where not(avg_food_items_per_head_per_hour >= 0)


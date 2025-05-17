



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_food_sales`

where not(avg_food_items_per_head_monthly >= 0)


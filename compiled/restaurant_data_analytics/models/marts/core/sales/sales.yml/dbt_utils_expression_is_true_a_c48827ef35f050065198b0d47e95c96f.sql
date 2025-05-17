



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_food_sales`

where not(avg_items_per_food_order_monthly <= total_food_items_sold_monthly)


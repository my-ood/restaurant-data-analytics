



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`

where not(avg_items_per_food_order_all_day <= total_food_items_sold_all_day)


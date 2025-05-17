



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`

where not(unique_food_items_ordered_all_day >= 0)


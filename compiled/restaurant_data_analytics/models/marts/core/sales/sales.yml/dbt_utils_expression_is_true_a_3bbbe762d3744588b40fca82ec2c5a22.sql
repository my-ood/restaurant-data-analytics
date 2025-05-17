



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_drink_sales`

where not(total_drink_items_ordered_all_day >= 0)






select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_drink_sales`

where not(unique_drink_items_ordered_weekly >= 0)


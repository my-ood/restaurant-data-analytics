



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_drink_sales`

where not(unique_drink_items_ordered_monthly >= 0)


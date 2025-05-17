



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_total_sales`

where not(unique_items_ordered_per_hour >= 0)


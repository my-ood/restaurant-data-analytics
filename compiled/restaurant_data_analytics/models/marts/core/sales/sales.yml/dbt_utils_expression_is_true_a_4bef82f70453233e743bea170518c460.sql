



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_drink_sales`

where not(avg_items_per_drink_order_per_hour <= total_drink_items_ordered_per_hour)


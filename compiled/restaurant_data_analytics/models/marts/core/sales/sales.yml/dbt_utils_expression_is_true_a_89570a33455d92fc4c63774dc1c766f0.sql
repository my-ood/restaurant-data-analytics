



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_total_sales`

where not(avg_items_per_order_monthly <= total_items_ordered_monthly)


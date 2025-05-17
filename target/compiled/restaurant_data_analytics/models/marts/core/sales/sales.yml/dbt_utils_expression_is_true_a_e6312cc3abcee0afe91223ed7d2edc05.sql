



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_drink_sales`

where not(avg_revenue_per_drink_order_weekly >= 0)






select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_drink_sales`

where not(avg_drink_revenue_per_head_weekly >= 0)






select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_total_sales`

where not(avg_daily_revenue_per_head >= 0)


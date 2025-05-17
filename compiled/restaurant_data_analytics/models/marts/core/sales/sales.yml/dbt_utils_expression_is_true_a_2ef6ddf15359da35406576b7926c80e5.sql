



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_total_sales`

where not(rolling_avg_revenue_4wk >= 0)






select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_total_sales`

where not(avg_monthly_revenue_per_head <= total_monthly_revenue)






select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_total_sales`

where not(avg_revenue_per_item_monthly <= total_monthly_revenue)


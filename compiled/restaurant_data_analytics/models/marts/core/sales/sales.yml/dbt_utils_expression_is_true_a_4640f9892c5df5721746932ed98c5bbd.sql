



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_drink_sales`

where not(avg_drinks_revenue_per_head_monthly <= total_monthly_drink_revenue)


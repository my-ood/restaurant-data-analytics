



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_drink_sales`

where not(total_monthly_drink_revenue >= 0)


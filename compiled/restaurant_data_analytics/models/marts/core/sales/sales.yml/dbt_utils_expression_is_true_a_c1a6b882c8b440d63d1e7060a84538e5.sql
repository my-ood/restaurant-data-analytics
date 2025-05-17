



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_total_sales`

where not(total_weekly_revenue >= 0)


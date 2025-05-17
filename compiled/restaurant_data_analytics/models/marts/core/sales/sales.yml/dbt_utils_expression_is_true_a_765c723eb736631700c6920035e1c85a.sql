



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_drink_sales`

where not(avg_weekly_revenue_per_drink_item >= 0)






select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_total_sales`

where not(top_daily_category_revenue >= 0)


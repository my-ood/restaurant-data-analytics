



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_total_sales`

where not(pct_top_cat_of_total_daily_revenue  <= 1)


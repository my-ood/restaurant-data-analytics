



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_total_sales`

where not(rolling_avg_items_sold_3mo >= 0)


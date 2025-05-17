



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_drink_sales`

where not(top_daily_drink_category_revenue <= total_daily_drink_revenue)


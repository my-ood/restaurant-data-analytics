



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_drink_sales`

where not(distinct_drink_tables_all_day >= 0)






select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_drink_sales`

where not(avg_distinct_drink_tables_per_day_monthly >= 0)






select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_total_sales`

where not(distinct_tables_per_hour <= 50)


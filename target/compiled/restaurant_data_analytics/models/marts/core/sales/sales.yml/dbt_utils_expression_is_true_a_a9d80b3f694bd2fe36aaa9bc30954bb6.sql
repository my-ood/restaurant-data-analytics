



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_monthly_food_sales`

where not(avg_distinct_food_tables_per_day_monthly >= 0)


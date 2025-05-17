



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`

where not(total_customers_all_day >= 0)


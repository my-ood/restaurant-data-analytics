



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_category_performance`

where not(total_units_sold_7d >= 0)


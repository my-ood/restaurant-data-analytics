



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_category_performance`

where not(avg_price_per_unit >= 0)


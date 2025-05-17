



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_item_performance_total`

where not(total_revenue >= 0)


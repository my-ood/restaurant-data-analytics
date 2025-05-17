



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_total_sales`

where not(avg_items_ordered_per_head_weekly >= 0)


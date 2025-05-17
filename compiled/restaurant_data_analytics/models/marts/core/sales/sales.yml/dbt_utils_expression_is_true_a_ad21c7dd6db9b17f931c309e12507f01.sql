



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_total_sales`

where not(avg_items_ordered_per_head_per_day  <= total_items_ordered_all_day)






select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_food_sales`

where not(food_category_diversity_per_hour >= 1)


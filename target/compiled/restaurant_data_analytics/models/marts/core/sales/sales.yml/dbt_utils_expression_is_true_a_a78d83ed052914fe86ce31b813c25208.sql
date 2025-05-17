



select
    1
from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_food_sales`

where not(top_weekly_food_category_revenue <= total_weekly_food_revenue)




  create or replace view `annular-mesh-453913-r6`.`dbt_`.`stg_wine_menu`
  OPTIONS()
  as select
  item_uuid,
  item_name,
  category,
  origin_region,
  origin_country,
  serving_size,
  price
from `annular-mesh-453913-r6`.`restaurant_data`.`wine_menu`;


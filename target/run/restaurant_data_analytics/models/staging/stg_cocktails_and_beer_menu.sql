

  create or replace view `annular-mesh-453913-r6`.`dbt_`.`stg_cocktails_and_beer_menu`
  OPTIONS()
  as select
  item_uuid,
  item_name,
  category,
  `desc` as description,
  price,
  
from `annular-mesh-453913-r6`.`restaurant_data`.`cocktails_and_beer_menu`;


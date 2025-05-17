

  create or replace view `annular-mesh-453913-r6`.`dbt_`.`stg_a_la_carte_menu`
  OPTIONS()
  as select
  item_uuid,
  item_name,
  category,
  `desc` as description,
  price,
  is_priced_per_weight
from `annular-mesh-453913-r6`.`restaurant_data`.`a_la_carte_menu`;


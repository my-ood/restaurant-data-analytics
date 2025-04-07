select
  item_uuid,
  item_name,
  category,
  `desc` as description,
  price,
  is_priced_per_weight
from {{ source('restaurant_data', 'a_la_carte_menu') }}

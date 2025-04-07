select
  item_uuid,
  item_name,
  category,
  `desc` as description,
  price,
  
from {{ source('restaurant_data', 'cocktails_and_beer_menu') }}

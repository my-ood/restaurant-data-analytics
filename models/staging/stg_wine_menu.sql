select
  item_uuid,
  item_name,
  category,
  origin_region,
  origin_country,
  serving_size,
  price
from {{ source('restaurant_data', 'wine_menu') }}

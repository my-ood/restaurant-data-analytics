with a_la_carte as (
    select
        item_uuid,
        item_name,
        category,
        description,  
        coalesce(safe_cast(price as float64), 0.0) as price,
        is_priced_per_weight,
        ' ' as origin_region,
        ' ' as origin_country,
        null as serving_size,
        'a_la_carte' as menu_source
    from `annular-mesh-453913-r6`.`dbt_`.`stg_a_la_carte_menu`
),
cocktails_and_beer as (
    select
        item_uuid,
        item_name,
        category,
        description,
        coalesce(safe_cast(price as float64), 0.0) as price,
        false as is_priced_per_weight,
        ' ' as origin_region,
        ' ' as origin_country,
        null as serving_size,
        'cocktails_and_beer' as menu_source
    from `annular-mesh-453913-r6`.`dbt_`.`stg_cocktails_and_beer_menu`
),
dessert as (
    select
        item_uuid,
        item_name,
        category,
        description,
        coalesce(safe_cast(price as float64), 0.0) as price,
        false as is_priced_per_weight,
        ' ' as origin_region,
        ' ' as origin_country,
        null as serving_size,
        'dessert' as menu_source
    from `annular-mesh-453913-r6`.`dbt_`.`stg_dessert_menu`
),
wine as (
    select
        item_uuid,
        item_name,
        category,
        ' ' as description,   
        coalesce(safe_cast(price as float64), 0.0) as price,
        false  as is_priced_per_weight,
        origin_region,
        origin_country,
        serving_size,         
        'wine' as menu_source
    from `annular-mesh-453913-r6`.`dbt_`.`stg_wine_menu`
)

select *
from a_la_carte

union all

select *
from cocktails_and_beer

union all

select *
from dessert

union all

select *
from wine
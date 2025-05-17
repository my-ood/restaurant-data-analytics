
    
    

with dbt_test__target as (

  select item_uuid as unique_field
  from `annular-mesh-453913-r6`.`dbt_`.`stg_cocktails_and_beer_menu`
  where item_uuid is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1



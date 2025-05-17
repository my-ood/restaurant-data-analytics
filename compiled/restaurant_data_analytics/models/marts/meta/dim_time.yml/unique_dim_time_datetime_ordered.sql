
    
    

with dbt_test__target as (

  select datetime_ordered as unique_field
  from `annular-mesh-453913-r6`.`dbt_`.`dim_time`
  where datetime_ordered is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1




    
    

with dbt_test__target as (

  select order_hour_dt as unique_field
  from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_drink_sales`
  where order_hour_dt is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1



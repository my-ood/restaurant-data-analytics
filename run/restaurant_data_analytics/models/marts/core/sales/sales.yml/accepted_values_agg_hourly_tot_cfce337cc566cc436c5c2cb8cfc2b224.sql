select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        is_peak_hour as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_total_sales`
    group by is_peak_hour

)

select *
from all_values
where value_field not in (
    True,False
)



      
    ) dbt_internal_test
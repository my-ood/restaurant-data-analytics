
    
    

with all_values as (

    select
        is_weekend as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_drink_sales`
    group by is_weekend

)

select *
from all_values
where value_field not in (
    True,False
)



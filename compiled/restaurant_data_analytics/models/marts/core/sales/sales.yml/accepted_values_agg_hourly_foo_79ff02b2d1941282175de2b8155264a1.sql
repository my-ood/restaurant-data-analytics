
    
    

with all_values as (

    select
        top_food_category_name_per_hour as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_food_sales`
    group by top_food_category_name_per_hour

)

select *
from all_values
where value_field not in (
    'Mains','Large Cuts','Steaks','Cheese','Sides','Sauces','Puddings','Ice-Cream & Sorbet','Extras','Chocolates','Starters'
)



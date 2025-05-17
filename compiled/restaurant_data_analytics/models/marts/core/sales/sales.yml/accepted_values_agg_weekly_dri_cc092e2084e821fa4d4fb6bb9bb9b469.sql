
    
    

with all_values as (

    select
        top_weekly_drink_category_name as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`agg_weekly_drink_sales`
    group by top_weekly_drink_category_name

)

select *
from all_values
where value_field not in (
    'Beers & Cider','Lo & No Alc','Port & Sherry','Ultimate Steakhouse Cocktails','Time & A Place','Rarities','The Sacred Six','Red Wines','Champagne & Sparkling','Rose Wines','Dessert Wines','White Wines','Magnums','Bordeaux','Burgundy'
)



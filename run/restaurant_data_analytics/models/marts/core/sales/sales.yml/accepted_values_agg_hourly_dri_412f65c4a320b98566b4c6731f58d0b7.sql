select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        top_drink_category_name_per_hour as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_drink_sales`
    group by top_drink_category_name_per_hour

)

select *
from all_values
where value_field not in (
    'Beers & Cider','Lo & No Alc','Port & Sherry','Ultimate Steakhouse Cocktails','Time & A Place','Rarities','The Sacred Six','Red Wines','Champagne & Sparkling','Rose Wines','Dessert Wines','White Wines','Magnums','Bordeaux','Burgundy'
)



      
    ) dbt_internal_test
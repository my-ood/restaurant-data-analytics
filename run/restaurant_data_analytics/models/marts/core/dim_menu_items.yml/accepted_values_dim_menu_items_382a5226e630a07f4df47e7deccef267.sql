select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        category as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`dim_menu_items`
    group by category

)

select *
from all_values
where value_field not in (
    'Bordeaux','Champagne & Sparkling','Dessert Wines','Port & Sherry','Rarities','Red Wines','Rose Wines','White Wines','Cheese','The Sacred Six','Ultimate Steakhouse Cocktails','Time & A Place','Lo & No Alc','Beers & Cider','Starters','Mains','Large Cuts','Steaks','Sauces','Extras','Sides','Burgundy','Magnums','Puddings','Ice-Cream & Sorbet','Chocolates'
)



      
    ) dbt_internal_test
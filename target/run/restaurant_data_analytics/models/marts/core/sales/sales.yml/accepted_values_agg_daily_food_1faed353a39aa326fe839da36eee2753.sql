select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        top_daily_food_category_name as value_field,
        count(*) as n_records

    from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`
    group by top_daily_food_category_name

)

select *
from all_values
where value_field not in (
    'Mains','Large Cuts','Steaks','Cheese','Sides','Sauces','Puddings','Ice-Cream & Sorbet','Extras','Chocolates','Starters'
)



      
    ) dbt_internal_test
select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select avg_price_per_unit
from `annular-mesh-453913-r6`.`dbt_`.`agg_category_performance`
where avg_price_per_unit is null



      
    ) dbt_internal_test
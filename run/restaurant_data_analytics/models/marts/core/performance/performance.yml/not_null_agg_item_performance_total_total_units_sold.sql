select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_units_sold
from `annular-mesh-453913-r6`.`dbt_`.`agg_item_performance_total`
where total_units_sold is null



      
    ) dbt_internal_test
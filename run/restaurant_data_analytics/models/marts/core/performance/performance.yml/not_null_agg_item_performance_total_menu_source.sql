select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select menu_source
from `annular-mesh-453913-r6`.`dbt_`.`agg_item_performance_total`
where menu_source is null



      
    ) dbt_internal_test
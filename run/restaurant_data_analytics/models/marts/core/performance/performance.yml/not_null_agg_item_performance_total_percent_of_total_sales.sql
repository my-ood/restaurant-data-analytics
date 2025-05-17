select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select percent_of_total_sales
from `annular-mesh-453913-r6`.`dbt_`.`agg_item_performance_total`
where percent_of_total_sales is null



      
    ) dbt_internal_test
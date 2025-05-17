select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select is_priced_per_weight
from `annular-mesh-453913-r6`.`dbt_`.`dim_menu_items`
where is_priced_per_weight is null



      
    ) dbt_internal_test
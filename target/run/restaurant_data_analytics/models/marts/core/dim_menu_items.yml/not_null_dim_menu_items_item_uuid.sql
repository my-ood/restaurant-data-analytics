select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select item_uuid
from `annular-mesh-453913-r6`.`dbt_`.`dim_menu_items`
where item_uuid is null



      
    ) dbt_internal_test
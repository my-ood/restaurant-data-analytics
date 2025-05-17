select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select category
from `annular-mesh-453913-r6`.`dbt_`.`stg_a_la_carte_menu`
where category is null



      
    ) dbt_internal_test
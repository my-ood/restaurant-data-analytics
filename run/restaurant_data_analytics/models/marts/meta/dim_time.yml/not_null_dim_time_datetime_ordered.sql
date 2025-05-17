select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select datetime_ordered
from `annular-mesh-453913-r6`.`dbt_`.`dim_time`
where datetime_ordered is null



      
    ) dbt_internal_test
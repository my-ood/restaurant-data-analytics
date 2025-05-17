
  
    

    create or replace table `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_total_sales`
      
    
    

    OPTIONS()
    as (
      

-- Food hourly metrics
with food as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_food_sales`
),

-- Drink hourly metrics
drink as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`agg_hourly_drink_sales`
),

-- Combine food + drink metrics on shared hour
combined as (
    select
        f.order_hour_dt,
        f.order_date,
        f.hour_of_day,
        f.total_food_items_ordered_per_hour,
        d.total_drink_items_ordered_per_hour,
        f.total_food_revenue_per_hour,
        d.total_drink_revenue_per_hour,
        f.top_food_category_name_per_hour,
        f.top_food_category_revenue_per_hour,
        d.top_drink_category_name_per_hour,
        d.top_drink_category_revenue_per_hour,
        f.total_mains_ordered_per_hour,  -- used as a proxy for total customers (1 customer = 1 main)
        f.total_food_orders_per_hour as food_orders,
        d.total_drink_orders_per_hour as drink_orders,
        f.unique_food_items_ordered_per_hour,
        d.unique_drink_items_ordered_per_hour,
        f.food_category_diversity_per_hour,
        d.drink_category_diversity_per_hour,
        f.is_kitchen_peak_hour,
        d.is_bar_peak_hour,
        array_to_string(
            array(
                select distinct t
                from unnest(
                    split(coalesce(f.open_table_ids_per_hour, '') || ',' || coalesce(d.open_table_ids_per_hour, ''), ',')
                ) as t
                where safe_cast(t as int) is not null
                order by cast(t as int)
            ),
            ','
        ) as open_table_ids_per_hour
    from food f
    join drink d on f.order_hour_dt = d.order_hour_dt
)

select
    order_hour_dt,
    order_date,
    hour_of_day,
    
    -- Total items ordered: food plus drink
    (total_food_items_ordered_per_hour + total_drink_items_ordered_per_hour) as total_items_ordered_per_hour,
    
    -- Total revenue: food plus drink
    (total_food_revenue_per_hour + total_drink_revenue_per_hour) as total_revenue_per_hour,
    
    -- Average revenue per item: total revenue divided by total items ordered
    round((total_food_revenue_per_hour + total_drink_revenue_per_hour) /
          nullif((total_food_items_ordered_per_hour + total_drink_items_ordered_per_hour), 0), 2) as avg_revenue_per_item_per_hour,
    
    -- Percentage of total revenue from food
    round(total_food_revenue_per_hour /
          nullif((total_food_revenue_per_hour + total_drink_revenue_per_hour), 0), 2) as pct_food_revenue_per_hour,
    
    -- Percentage of total revenue from drink
    round(total_drink_revenue_per_hour /
          nullif((total_food_revenue_per_hour + total_drink_revenue_per_hour), 0), 2) as pct_drink_revenue_per_hour,
    
    -- Determine the top category based on which revenue is higher (food or drink)
    case 
      when top_food_category_revenue_per_hour >= top_drink_category_revenue_per_hour then top_food_category_name_per_hour
      else top_drink_category_name_per_hour
    end as top_category_name_per_hour,
    
    case 
      when top_food_category_revenue_per_hour >= top_drink_category_revenue_per_hour then top_food_category_revenue_per_hour
      else top_drink_category_revenue_per_hour
    end as top_category_revenue_per_hour,
    
    -- Percentage of total revenue contributed by the top category
    round(
      case 
        when top_food_category_revenue_per_hour >= top_drink_category_revenue_per_hour then top_food_category_revenue_per_hour
        else top_drink_category_revenue_per_hour
      end / nullif((total_food_revenue_per_hour + total_drink_revenue_per_hour), 0), 2
    ) as pct_top_cat_of_total_revenue_per_hour,
    
    -- Total customers per hour (using mains ordered as a proxy)
    total_mains_ordered_per_hour as total_new_customers_per_hour,
    
    -- Average revenue per head: total revenue divided by total customers
    coalesce(
        round((total_food_revenue_per_hour + total_drink_revenue_per_hour) /
              nullif(total_mains_ordered_per_hour, 0), 2)
    ) as avg_revenue_per_head_per_hour,
    
    -- Average revenue per order: total revenue divided by total (food + drink) orders
    round((total_food_revenue_per_hour + total_drink_revenue_per_hour) /
        nullif((food_orders + drink_orders), 0), 2
    ) as avg_revenue_per_order_per_hour,

    -- Average items ordered per head: total items divided by total customers
    coalesce(
        round((total_food_items_ordered_per_hour + total_drink_items_ordered_per_hour) /
              nullif(total_mains_ordered_per_hour, 0), 2)
    ) as avg_items_ordered_per_head_per_hour,

    -- Average items per order: total items divided by total (food + drink) orders
    round((total_food_items_ordered_per_hour + total_drink_items_ordered_per_hour) /
      nullif((food_orders + drink_orders), 0), 2) as avg_items_per_order_per_hour,
    
    -- Total orders per hour (sum of unique food and drink orders)
    (food_orders + drink_orders) as total_orders_per_hour,
    
    -- Unique items ordered (sum from food and drink; note: this is a naive summation)
    (unique_food_items_ordered_per_hour + unique_drink_items_ordered_per_hour) as unique_items_ordered_per_hour,
    
    -- Category diversity: sum of unique categories from food and drink
    (food_category_diversity_per_hour + drink_category_diversity_per_hour) as category_diversity_per_hour,

    -- Recalculated distinct tables from open_table_ids list
    array_length(split(open_table_ids_per_hour, ',')) as distinct_tables_per_hour,

    -- Full list of distinct table numbers as a CSV string
    open_table_ids_per_hour,

    -- is_weekend: true if the order_date falls on Friday, Saturday, or Sunday.
    case 
      when extract(dayofweek from order_date) in (1, 6, 7) then true
      else false
    end as is_weekend,
    
    -- is_peak_hour: true if either model show a peak hour indicator
    (is_kitchen_peak_hour or is_bar_peak_hour) as is_peak_hour

from combined
order by order_hour_dt desc
    );
  
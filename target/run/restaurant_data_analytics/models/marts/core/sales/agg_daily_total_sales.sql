
  
    

    create or replace table `annular-mesh-453913-r6`.`dbt_`.`agg_daily_total_sales`
      
    
    

    OPTIONS()
    as (
      with food as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales`
),

drink as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_drink_sales`
),

metadata as (
    select
        order_date,
        distinct_tables_used_all_day
    from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_metadata`
),

combined as (
    select
        f.order_date,
        extract(dayofweek from f.order_date) as day_of_week,
        f.total_food_items_sold_all_day as total_food_items,
        d.total_drink_items_ordered_all_day as total_drink_items,
        f.total_daily_food_revenue as food_revenue,
        d.total_daily_drink_revenue as drink_revenue,
        f.total_customers_all_day as total_daily_customers,
        f.total_food_orders_all_day as food_orders,
        d.total_drink_orders_all_day as drink_orders,
        f.unique_food_items_ordered_all_day as unique_food_items,
        d.unique_drink_items_ordered_all_day as unique_drink_items,
        f.food_category_diversity_all_day as food_cat_div,
        d.drink_category_diversity_all_day as drink_cat_div,
        case
            when f.top_daily_food_category_revenue >= d.top_daily_drink_category_revenue then f.top_daily_food_category_name
            else d.top_daily_drink_category_name
        end as top_daily_category_name,
        greatest(f.top_daily_food_category_revenue, d.top_daily_drink_category_revenue) as top_daily_category_revenue,
        m.distinct_tables_used_all_day
    from food f
    join drink d on f.order_date = d.order_date
    left join metadata m on f.order_date = m.order_date
),


peak_hours_list as (
    select
        f.order_date,
        array_to_string(
            array(
                select distinct hour
                from unnest(
                    split(coalesce(f.kitchen_peak_hours, '') || ',' || coalesce(d.bar_peak_hours, ''), ',')
                ) as hour
                where safe_cast(hour as int) is not null
                order by cast(hour as int)
            ), ','
        ) as peak_hours
    from `annular-mesh-453913-r6`.`dbt_`.`agg_daily_food_sales` f
    join `annular-mesh-453913-r6`.`dbt_`.`agg_daily_drink_sales` d using (order_date)
),


daily_totals as (
    select
        c.order_date,
        c.day_of_week,
        (c.total_food_items + c.total_drink_items) as total_items_ordered_all_day,
        (c.food_revenue + c.drink_revenue) as total_daily_revenue,
        round((c.food_revenue + c.drink_revenue) / nullif((c.total_food_items + c.total_drink_items), 0), 2) as avg_revenue_per_item_daily,
        (c.food_cat_div + c.drink_cat_div) as category_diversity_all_day,
        c.top_daily_category_name,
        c.top_daily_category_revenue,
        round(c.food_revenue / nullif((c.food_revenue + c.drink_revenue), 0), 2) as pct_food_from_daily_revenue,
        round(c.drink_revenue / nullif((c.food_revenue + c.drink_revenue), 0), 2) as pct_drink_from_daily_revenue,
        round(c.top_daily_category_revenue / nullif((c.food_revenue + c.drink_revenue), 0), 2) as pct_top_cat_of_total_daily_revenue,
        c.total_daily_customers,
        round((c.food_revenue + c.drink_revenue) / nullif(c.total_daily_customers, 0), 2) as avg_daily_revenue_per_head,
        round((c.total_food_items + c.total_drink_items) / nullif(c.total_daily_customers, 0), 2) as avg_items_ordered_per_head_per_day,
        (c.food_orders + c.drink_orders) as total_orders_all_day,
        round((c.total_food_items + c.total_drink_items) / nullif((c.food_orders + c.drink_orders), 0), 2) as avg_items_per_order_all_day,
        round((c.food_revenue + c.drink_revenue) / nullif((c.food_orders + c.drink_orders), 0), 2) as avg_revenue_per_order_all_day,
        (c.unique_food_items + c.unique_drink_items) as unique_items_ordered_all_day,
        c.distinct_tables_used_all_day,
        extract(dayofweek from c.order_date) in (1, 6, 7) as is_weekend,
        p.peak_hours
    from combined c
    left join peak_hours_list p on c.order_date = p.order_date
),

revenue_trends as (
    select
        *,
        round((total_daily_revenue - lag(total_daily_revenue) over (order by order_date)) / nullif(lag(total_daily_revenue) over (order by order_date), 0), 4) as pct_change_in_daily_revenue,
        round(total_daily_revenue - lag(total_daily_revenue) over (order by order_date), 2) as daily_revenue_change_amount,
        round(avg(total_daily_revenue) over (order by order_date rows between 6 preceding and current row), 2) as rolling_avg_revenue_7d,
        round(avg(total_items_ordered_all_day) over (order by order_date rows between 6 preceding and current row), 2) as rolling_avg_items_sold_7d
    from daily_totals
)

select *
from revenue_trends
order by order_date desc
    );
  
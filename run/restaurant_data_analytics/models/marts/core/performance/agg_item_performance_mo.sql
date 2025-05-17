
  
    

    create or replace table `annular-mesh-453913-r6`.`dbt_`.`agg_item_performance_mo`
      
    
    

    OPTIONS()
    as (
      with base as (
    select *, format_date('%Y-%m', order_date) as order_month
    from `annular-mesh-453913-r6`.`dbt_`.`fct_orders`
),

menu as (
    select *
    from `annular-mesh-453913-r6`.`dbt_`.`dim_menu_items`
),

revenue_totals as (
    select
        order_month,
        sum(total_item_revenue) as total_revenue_all
    from base
    group by order_month
),

aggregated_items as (
    select
        o.item_uuid,
        m.item_name,
        m.category as item_category,
        m.menu_source,
        m.price as item_price,
        o.order_month,

        sum(o.quantity) as total_units_sold,
        sum(o.total_item_revenue) as total_revenue,

        round(avg(extract(hour from o.datetime_ordered)), 2) as avg_order_hour,
        round(sum(o.total_item_revenue) / t.total_revenue_all, 4) as percent_of_total_sales,
        round(sum(o.total_item_revenue) / nullif(sum(o.quantity), 0), 2) as avg_price_per_unit,

        case
            when sum(o.quantity) < 10 or (sum(o.total_item_revenue) / t.total_revenue_all) < 0.01
              then true else false
        end as is_underperformer,

        case
            when (sum(o.total_item_revenue) / t.total_revenue_all) > 0.10
              then true else false
        end as is_top_seller,

        case
            when sum(o.quantity) < 10 and (sum(o.total_item_revenue) / t.total_revenue_all) < 0.01
              then 'Low units & low revenue share'
            when sum(o.quantity) < 10 then 'Low units sold'
            when (sum(o.total_item_revenue) / t.total_revenue_all) < 0.01 then 'Low revenue share'
            else null
        end as underperformance_reason,

        case
            when (sum(o.total_item_revenue) / t.total_revenue_all) > 0.10 then 'Top Seller'
            when sum(o.quantity) < 10 or (sum(o.total_item_revenue) / t.total_revenue_all) < 0.01 then 'Underperformer'
            else 'Standard Performer'
        end as performance_tier,

        dense_rank() over (partition by o.order_month order by sum(o.total_item_revenue) desc) as item_revenue_rank

    from base o
    left join menu m on o.item_uuid = m.item_uuid
    left join revenue_totals t on o.order_month = t.order_month
    group by
        o.item_uuid, m.item_name, m.category, m.menu_source, m.price, o.order_month, t.total_revenue_all
)

select *,
       current_timestamp() as report_generated_at
from aggregated_items
order by order_month, total_revenue desc
    );
  
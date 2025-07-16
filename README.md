# Restaurant Data Analytics (dbt)

A dbt project that powers analytics for a simulated multi-location restaurant group by transforming raw menu and order data into clean, tested, and documented models for reporting and insights.

## 📊 Project Overview

The [DAG](https://my-ood.github.io/restaurant-data-analytics/#!/overview?g_v=1) reveals a structured and scalable transformation pipeline across several layers:

### 🔹 Source Data (from BigQuery)
- `restaurant_data.a_la_carte_menu`
- `restaurant_data.cocktails_and_beer_menu`
- `restaurant_data.dessert_menu`
- `restaurant_data.wine_menu`
- `restaurant_data.orders`

### 🔹 Staging Models (`stg_*`)
Standardized and cleaned versions of raw source tables, split by menu type and orders.

### 🔹 Dimension Models
- `dim_menu_items`: Unified representation of all menu items.
- `dim_time`: A time spine for date- and time-based aggregation.

### 🔹 Fact Models
- `fct_orders`: Canonical fact table capturing item-level order data, linked to menu items and time.

### 🔹 Intermediate Models
- `agg_customer_counts`: Estimation of customer volume by time period.
- `agg_item_performance_*`: Item-level performance metrics (weekly, monthly, total).
- `agg_category_performance`: Aggregated performance by food or drink category.

### 🔹 Aggregates (Hourly / Daily / Weekly / Monthly)
Separate aggregations for:
- Food sales
- Drink sales
- Total sales
- Metadata summaries (per frequency)

### 🔹 Final Models
- `agg_monthly_total_sales`
- `agg_weekly_total_sales`
- `agg_daily_total_sales`

These models could power dashboards, reporting tools, and internal decision-making.

---

## 🧰 Project Structure

```bash
models/
├── staging/
│   ├── stg_orders.sql
│   ├── stg_wine_menu.sql
│   └── ...              # Other stg_* models
├── marts/
│   ├── core/
│   │   ├── customers/
│   │   │   └── agg_customer_counts.sql
│   │   ├── performance/
│   │   │   ├── agg_category_performance.sql
│   │   │   ├── agg_item_performance_mo.sql
│   │   │   └── ...              # Other agg_item_performance_* models
│   │   ├── sales/
│   │   │   ├── agg_hourly_food_sales.sql
|   |   |   ├── agg_hourly_drink_sales.sql
|   |   |   ├── ...
│   │   │   ├── agg_daily_sales_*.sql
│   │   │   ├── agg_weekly_sales_*.sql
│   │   │   └── agg_monthly_sales_*.sql
│   │   ├── dim_menu_items.sql
│   │   └── fct_orders.sql
│
│   └── meta/
|       ├── dim_time.sql
│       └── agg_metadata_*.sql
```


## 📚 Navigation

- [📂 Project Structure](#-project-structure)
- [🌐 dbt Documentation](#-dbt-documentation)
- [🧪 Tests and Contracts](#-testing-and-data-integrity)
- [📈 Business Use Cases](#-business-use-cases)
- [📄 License](#-license)

## 🌐 dbt Documentation

This project’s dbt docs are publicly hosted via GitHub Pages:

👉 [View dbt Docs](https://my-ood.github.io/restaurant-data-analytics/)  


---

## 🧪 Testing and Data Integrity

This project includes a comprehensive suite of tests to ensure data integrity, quality, and trust in analytics:

### ✅ Test Types
- **`not_null`**: Ensures required fields are never missing.
- **`unique`**: Validates primary keys and other uniqueness constraints.
- **`accepted_values`**: Restricts columns to known valid values (e.g., `is_weekend`, `menu_source`).
- **`relationships`**: Enforces referential integrity between models (e.g., `fct_orders.item_uuid → dim_menu_items.item_uuid`).
- **`dbt_utils.expression_is_true`**: Applies custom logic tests (e.g., non-negative revenues, percentages < 100%).
- **`dbt_utils.accepted_range`**: Checks numeric values fall within specified limits.

### 🧾 Test Coverage Summary

- **Staging Models**: All `stg_*` models enforce uniqueness and non-null constraints on primary identifiers like `item_uuid` and `item_ordered_id`.
- **Fact Table (`fct_orders`)**: Comprehensive checks on all core columns, including accepted values for categorical fields and range checks on numeric fields.
- **Dimension Tables (`dim_menu_items`, `dim_time`)**: Validated for completeness and key integrity.
- **Aggregate Models (`agg_*`)**: Use expression-based tests to validate revenue calculations, customer estimates, category logic, and other derived fields at hourly, daily, weekly, and monthly levels.
- **Performance Models**: Validated against logical consistency (e.g., `avg_order_hour`, `percent_of_total_sales`).
- **Metadata Models**: Also tested for logical expressions and expected formatting.

All test configurations are defined in modular `.yml` files per domain (`sales.yml`, `performance.yml`, etc.) and integrated with dbt's documentation.


---

## 📈 Business Use Cases

- Track food vs drink performance over time
- Identify top- and bottom-performing items
- Estimate customer counts based on order volume
- Compare performance by time granularity (hourly → monthly)
- Power dashboards with reliable, aggregated data

---

## 📄 License

This project is for educational and internal use. Customize as needed for production.


# Amazon Sales Data Analysis with SQL & Power BI
---

##  Table of Contents

1. [Project Overview](#project-overview)  
2. [Tools Used](#tools-used)  
3. [Dataset Overview](#dataset-overview)  
4. [Data Cleaning Process](#data-cleaning-process)  
5. [Derived Columns](#derived-columns)   
6. [Business Insights](#business-insights)
7. [Findings](#findings)
8. [Power BI Dashboard](#power-bi-dashboard)  
9. [Conclusion](#conclusion)

---

## Project Overview

> **Optimizing Amazon's Sales Performance through Data-Driven Insights**

This project analyzes historical Amazon sales data to uncover trends, solve operational challenges, and drive actionable improvements in product performance, shipping efficiency, and customer satisfaction.

Using **PostgreSQL**, the raw dataset was thoroughly cleaned, normalized, and enriched with derived metrics. Then, with structured SQL queries, key business questions were answered — laying the groundwork for powerful reporting through **Power BI**.

---

### Why This Project Matters

In the world of e-commerce, companies like Amazon constantly face pressure to:

- Improve delivery speed and reduce shipping costs
- Minimize refund and return rates
- Identify top-performing product lines
- Track customer purchasing behavior by region
- Make inventory and marketing decisions in near real-time

This project simulates the type of internal reporting and operational intelligence Amazon could use to **boost efficiency and profitability** and also acts as a complete **analytics pipeline** — transforming raw sales data into valuable insights that could power real business improvements for any online retailer.

---

## Tools Used

- PostgreSQL (via pgAdmin)
- Power BI
- Excel (for initial checks)

---

##  Dataset Overview

The dataset used in this project has been uploaded to this GitHub repository for reference. It includes over 128,000+ rows of historical Amazon order data, with the following columns:
- order_id
- order_date
- status
- sales_channel and so on...

---

## Data Cleaning Process

- Renamed all columns using snake_case
- Removed special characters and trailing spaces
- Handled nulls and blank entries
- Standardized text (e.g., INITCAP for city/state)
- Converted:
  - `order_date` → DATE
  - `quantity`, `amount` → NUMERIC
  - `b2b` → BOOLEAN
- Removed full duplicates and tagged partial ones
- Cleaned and grouped the `status` column into `order_status_grouped`
- Dropped the irrelevant columns

---

## Derived Columns

Created the following additional columns:
- `order_status_grouped` – grouped version of `status`
- `is_duplicate` – flags duplicate order_id + sku combinations
- `order_year`, `order_month` – extracted from `order_date`

---

##  Business Insights

---

### 1. Total Sales Generated Per Month Across All Products

```sql
SELECT EXTRACT(YEAR FROM order_date) AS year,
       EXTRACT(MONTH FROM order_date) AS month,
       SUM(amount) AS total_sales
FROM amazon_sales
GROUP BY year, month
ORDER BY year, month;
```
###  2. Highest Revenue Product Line or Product Name

```sql
SELECT category, SUM(amount) AS total_revenue
FROM amazon_sales
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 1;
```
### 3. Cities With Highest Number of Orders

```sql
SELECT ship_city, COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY ship_city
ORDER BY total_orders DESC
LIMIT 10;
```
### 4.Average Selling Price per Product Category

```sql
SELECT category, ROUND(AVG(amount), 2) AS avg_price
FROM amazon_sales
GROUP BY category;
```
### 5. Units Sold Per Product Type Over Time

```sql
SELECT 
    category,
    order_month AS month,
    order_year AS year,
    SUM(quantity) AS total_units
FROM amazon_sales
GROUP BY category, year, month
ORDER BY year, month;
```
### 6. Refund rate across products or categories
### 7. Top 10 Customers
### 8.  How does the quantity sold relate to the profit margin per item?
### 9. Distribution of Order Statuses
### 10. Which shipping modes are most frequently used?
### 11. Most active days of the week
### 12. Revenue by category and region
### 13. Are there products consistently out of stock or returned?

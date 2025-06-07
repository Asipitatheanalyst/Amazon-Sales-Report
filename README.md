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
9. [Recommedations](#recommedations)
10. [Conclusion](#conclusion)

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
- Cleaned the order city and state in Excel power query (remove unneccesary characters and numbers)
  ```
  Text.Proper(Text.Select([ship_state], {"A".."Z", "a".."z", " "}))
  ```

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
SELECT 
    TO_CHAR(order_date, 'FMMonth') AS month,
    '₹' || TO_CHAR(ROUND(SUM(amount)), 'FM999,999,999') AS total_sales
FROM amazon_sales
GROUP BY month
ORDER BY month;
```
###  2. Highest Revenue Product Line or Product Name

```sql
SELECT 
    category,
   '₹' || TO_CHAR(ROUND(SUM(amount)), 'FM999,999,999') AS total_revenue
FROM amazon_sales
GROUP BY category
ORDER BY sum(amount) DESC
LIMIT 1;
```
### 3. Cities With Highest Number of Orders

```sql
SELECT ship_city, COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY ship_city
ORDER BY total_orders DESC
LIMIT 5;
```
### 4.Average Selling Price per Product Category

```sql
SELECT 
    category,
    '₹' || ROUND(AVG(amount)) AS avg_selling_price
FROM amazon_sales
GROUP BY category
ORDER BY ROUND(AVG(amount)) DESC;
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

---
## Findings
- ✅ **Monthly Sales Trends**: Sales peaked in **April (₹28.8M)**, followed by **May (₹26.2M)** and **June (₹23.4M)**, revealing a clear seasonal trend.
- ✅ **Top Revenue-Generating Category**: The **“Set”** category dominated with over **₹39.2M** in total revenue.
- ✅ **Top Performing Cities**: 
  - **Bengaluru (11,898 orders)**  
  - **Hyderabad (9,125)**  
  - **Mumbai (7,122)**  
  These cities had the highest order volumes and could benefit from focused logistics or marketing.
- ✅ **Shipping Mode Preference**: 
  - **Expedited** shipping was used in **88,615** orders  
  - vs **Standard** with **40,360** orders  
  This shows customers heavily prefer faster delivery.
- ✅ **Average Selling Price by Category**: 
  - **Set**: ₹779.65  
  - **Saree**: ₹755.69  
  - **Western Dress**: ₹723.62  
  These categories command premium pricing.
- ✅ **Order Status Breakdown**:  
  - **Shipped**: 107,581  
  - **Cancelled**: 18,332  
  - **Returned**: 2,109  
  Indicates a strong order fulfillment rate.
- ✅ **Top 10 Customers by Spend**:  
  The highest-spending customer spent **₹6,680**, and many others spent over **₹6,000+**, showing opportunities for loyalty programs.
- ✅ **Units Sold Over Time**:  
  Categories like **Set** and **Kurta** consistently led in monthly unit sales, especially during Q2.
- ✅ **Most Returned Categories**:  
  - **Set**: 845 returns  
  - **Kurta**: 752 returns  
  These may indicate sizing, quality, or listing issues.
- ✅ **Refund Rate by Category**:
  - **Western Dress**: 2.21%  
  - **Set**: 1.66%  
  - **Kurta**: 1.50%  
  Shows which categories are driving post-sale losses.
- ✅ **Quantity vs. Average Sale Amount**:  
  Highest average amounts seen at **quantities of 6 (₹3835)** and **7 (₹5584)** — possibly large set or bulk orders.
- ✅ **Revenue by Region**:  
  - **Maharashtra**, **Karnataka**, and **Telangana** are leading revenue contributors for `Set` and `Kurta` categories.
- ✅ **Most Active Weekdays**:  
  - **Sunday** had the highest order volume, followed by **Tuesday** and **Wednesday** — useful for campaign timing.

> These findings highlight actionable areas for improving fulfillment, marketing strategies, customer segmentation, and overall profitability.

##  Power BI Dashboard
![Amazon Dashboard](https://github.com/user-attachments/assets/15c26f4e-6da2-4e41-a597-e328cef98ef7)

![Amazon Dashboard 2](https://github.com/user-attachments/assets/ef9578a5-41ea-47ae-9c2b-a9daa33a1476)

> The dashboard provides a comprehensive overview of Amazon's sales performance through clean, interactive visuals. It highlights key metrics such as total sales, total orders, top categories, and most active cities. Trends like daily sales patterns, monthly revenue, shipping preferences, and return rates are clearly presented using line charts, bar graphs, and donut charts. With intuitive slicers for month and year filtering, users can quickly explore patterns and draw insights. The design is visually appealing, branded with a custom layout, and effectively communicates both high-level summaries and detailed category-level performance for informed decision-making.

##  Recommedations
> Based on the insights from the data:
1. **Focus on High-Performing Categories:** The "Set" category leads in both revenue and return rates. While it performs well, further analysis into return reasons may help improve margins.
2. **Improve Return Process:** Categories like Kurta and Western Dress also see significant return volumes. Review sizing, description accuracy, or supplier quality.
3. **Optimize Courier Usage:** Over 84% of orders are shipped, with few canceled. Ensuring continued efficiency in shipping will support satisfaction.
4. **Active Days:** Ensure to schedule promotions on Sundays and Tuesdays.

##  Conclusion
This project analyzed Amazon's sales data using PostgreSQL for cleaning and transformation, and Power BI for visualization. From identifying top-selling categories and high-return products to analyzing shipping methods and city-level order trends, the dashboard provides actionable business intelligence. With better return handling, targeted shipping strategies, and city-focused marketing, Amazon could potentially:

- Improve customer satisfaction,
- Reduce logistics costs, and
- Increase sales by 10–20% in high-opportunity segments.

The clean dataset and SQL views are uploaded in this repository.







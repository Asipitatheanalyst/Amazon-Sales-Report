-- 1. Total Sales Generated Per Month
CREATE VIEW INSIGHT_1 AS
SELECT 
    TO_CHAR(order_date, 'FMMonth') AS month,
    TO_CHAR(ROUND(SUM(amount)), 'FM999,999,999') AS total_sales
FROM amazon_sales
GROUP BY month
ORDER BY month;

-- 2. Highest Revenue Product Line or Product Name
CREATE VIEW INSIGHT_2 AS
SELECT 
    category,
    TO_CHAR(ROUND(SUM(amount)), 'FM999,999,999') AS total_revenue
FROM amazon_sales
GROUP BY category
ORDER BY sum(amount) DESC
LIMIT 1;

-- 3. Cities With Highest Number of Orders
CREATE VIEW INSIGHT_3 AS
SELECT 
    ship_city,
    COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY ship_city
ORDER BY total_orders DESC
LIMIT 5;

-- 4. Average Selling Price per Product Category
CREATE VIEW INSIGHT_4 AS
SELECT 
    category,
    ROUND(AVG(amount)) AS avg_selling_price
FROM amazon_sales
GROUP BY category
ORDER BY ROUND(AVG(amount)) DESC;

-- 5. Units Sold Per Product Type Over Time
SELECT 
    category,
    order_month AS month,
    order_year AS year,
    SUM(quantity) AS total_units
FROM amazon_sales
GROUP BY category, year, month
ORDER BY year, month;

-- 6. Refund rate across products or categories
CREATE VIEW INSIGHT_6 AS
SELECT 
    category,
    ROUND(
        COUNT(*) FILTER (WHERE status ILIKE '%return%') * 100.0 / COUNT(*), 
        2
    ) AS refund_rate_percent
FROM amazon_sales
GROUP BY category
ORDER BY refund_rate_percent DESC;


-- 7. Top 10 Customers by Orders or Spend
SELECT 
    order_id,
    ROUND(SUM(amount)) AS total_spent
FROM amazon_sales
GROUP BY order_id
ORDER BY ROUND(SUM(amount)) DESC
LIMIT 10;


-- 8. How does the quantity sold relate to the profit margin per item?
SELECT 
    quantity,
   '₹' || ROUND(AVG(amount), 2) AS avg_amount
FROM amazon_sales
GROUP BY quantity;

-- 9. Distribution of Order Statuses
CREATE VIEW INSIGHT_9 AS
SELECT 
    order_status_grouped,
    COUNT(*) AS count
FROM amazon_sales
GROUP BY order_status_grouped
ORDER BY count DESC;

-- 10. Which shipping modes are most frequently used
CREATE VIEW INSIGHT_10 AS
SELECT 
    ship_service_level,
    COUNT(*) AS usage_count
FROM amazon_sales
GROUP BY ship_service_level
ORDER BY usage_count DESC;

-- 11. Most active days of the week
CREATE VIEW INSIGHT_11 AS
SELECT 
    TO_CHAR(order_date, 'Day') AS weekday,
    COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY weekday
ORDER BY total_orders DESC;

-- 12. Revenue by category and region
SELECT 
    category,
    ship_state,
    ROUND(SUM(amount)) AS total_revenue
FROM amazon_sales
GROUP BY category, ship_state
ORDER BY SUM(amount) DESC;


-- 13. Are there products consistently out of stock or returned
CREATE VIEW INSIGHT_13 AS
SELECT 
    category,
    COUNT(*) AS returned_count
FROM amazon_sales
WHERE order_status_grouped ILIKE '%return%'
GROUP BY category
ORDER BY returned_count DESC;

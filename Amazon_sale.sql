SELECT * FROM public."Raw_amazon_sales"

CREATE TABLE amazon_sales (
    index_id SERIAL PRIMARY KEY,
    order_id TEXT,
    order_date DATE,             
    status TEXT,
    fulfilment TEXT,
    sales_channel TEXT,
    ship_service_level TEXT,
    style TEXT,
    sku TEXT,
    category TEXT,
    size TEXT,
    asin TEXT,
    courier_status TEXT,
    quantity TEXT,                
    currency TEXT,
    amount TEXT,                  
    ship_city TEXT,
    ship_state TEXT,
    ship_postal_code TEXT,
    ship_country TEXT,
    promotion_ids TEXT,
    b2b TEXT,                    
    fulfilled_by TEXT
);

ALTER TABLE public."amazon_sales"
RENAME COLUMN "currency " TO "currency";

---- Column Name Standardization ---

INSERT INTO amazon_sales (
    order_id, order_date, status, fulfilment, sales_channel, ship_service_level,
    style, sku, category, size, asin, courier_status, quantity, currency,
    amount, ship_city, ship_state, ship_postal_code, ship_country,
    promotion_ids, b2b, fulfilled_by
)
SELECT
    "Order ID",
    "Date",
    "Status",
    "Fulfilment",
    "Sales Channel",
    "ship-service-level",
    "Style",
    "SKU",
    "Category",
    "Size",
    "ASIN",
    "Courier Status",
    "Qty",
    "currency",        
    "Amount",
    "ship-city",
    "ship-state",
    "ship-postal-code",
    "ship-country",
    "promotion-ids",
    "B2B",
    "fulfilled-by"
FROM public."Raw_amazon_sales";

SELECT * FROM public."amazon_sales"

--- Data Type Validation and Conversion ---

---  Convert quality to INTEGER --

ALTER TABLE amazon_sales ADD COLUMN quantity_converted INTEGER;

UPDATE amazon_sales
SET quantity_converted = NULLIF(REGEXP_REPLACE(quantity, '[^0-9]', '', 'g'), '')::INTEGER
WHERE quantity IS NOT NULL;

--- Converting Amount to NUMERIC ---
ALTER TABLE amazon_sales ADD COLUMN amount_converted NUMERIC(12, 2);

UPDATE amazon_sales
SET amount_converted = NULLIF(REGEXP_REPLACE(amount, '[^0-9.]', '', 'g'), '')::NUMERIC
WHERE amount IS NOT NULL;

--- Converting B2B to Boolean ---
ALTER TABLE amazon_sales ADD COLUMN b2b_converted BOOLEAN;

UPDATE amazon_sales
SET b2b_converted = CASE
    WHEN LOWER(b2b) IN ('yes', 'y', 'true', '1') THEN TRUE
    WHEN LOWER(b2b) IN ('no', 'n', 'false', '0') THEN FALSE
    ELSE NULL
END
WHERE b2b IS NOT NULL;

--- Drop old column and Rename ---
ALTER TABLE amazon_sales
    DROP COLUMN quantity,
    DROP COLUMN amount,
    DROP COLUMN b2b;


ALTER TABLE amazon_sales RENAME COLUMN quantity_converted TO quantity;

ALTER TABLE amazon_sales RENAME COLUMN amount_converted TO amount;

ALTER TABLE amazon_sales RENAME COLUMN b2b_converted TO b2b;

--- Restoring Order date back ---
ALTER TABLE amazon_sales ADD COLUMN order_date DATE;
UPDATE amazon_sales AS target
SET order_date = raw."Date"
FROM "Raw_amazon_sales" AS raw
WHERE target.order_id = raw."Order ID";


--- Checking for Null ---
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS missing_order_date,
    COUNT(*) FILTER (WHERE status IS NULL) AS missing_status,
    COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE amount IS NULL) AS missing_amount,
    COUNT(*) FILTER (WHERE b2b IS NULL) AS missing_b2b,
    COUNT(*) FILTER (WHERE fulfilled_by IS NULL) AS missing_fulfilled_by
FROM amazon_sales;

--- Update columns ---
UPDATE amazon_sales SET amount = 0 WHERE amount IS NULL;

UPDATE amazon_sales
SET ship_city = 'Unknown'
WHERE TRIM(ship_city) = '';

UPDATE amazon_sales
SET ship_state = 'Unknown'
WHERE TRIM(ship_state) = '';

UPDATE amazon_sales
SET ship_postal_code = 'Unknown'
WHERE TRIM(ship_postal_code) = '';

--- Checking For Duplicates ---
SELECT 
    order_id, order_date, status, fulfilment, sales_channel, ship_service_level,
    style, sku, category, size, asin, courier_status, quantity, currency, amount,
    ship_city, ship_state, ship_postal_code, ship_country, promotion_ids, b2b, fulfilled_by,
    COUNT(*) AS duplicate_count
FROM amazon_sales
GROUP BY 
    order_id, order_date, status, fulfilment, sales_channel, ship_service_level,
    style, sku, category, size, asin, courier_status, quantity, currency, amount,
    ship_city, ship_state, ship_postal_code, ship_country, promotion_ids, b2b, fulfilled_by
HAVING COUNT(*) > 1;

--- Detect Partial Duplicates --
SELECT order_id, sku, COUNT(*) AS duplicate_skus
FROM amazon_sales
GROUP BY order_id, sku
HAVING COUNT(*) > 1;

--- Flag Duplicates --
ALTER TABLE amazon_sales ADD COLUMN is_duplicate BOOLEAN DEFAULT FALSE;

UPDATE amazon_sales
SET is_duplicate = TRUE
WHERE (order_id, sku) IN (
    SELECT order_id, sku
    FROM amazon_sales
    GROUP BY order_id, sku
    HAVING COUNT(*) > 1
);

--- Trim Extra Spaces from Text Columns --
UPDATE amazon_sales SET status = TRIM(status);
UPDATE amazon_sales SET fulfilment = TRIM(fulfilment);
UPDATE amazon_sales SET sales_channel = TRIM(sales_channel);
UPDATE amazon_sales SET ship_service_level = TRIM(ship_service_level);
UPDATE amazon_sales SET style = TRIM(style);
UPDATE amazon_sales SET sku = TRIM(sku);
UPDATE amazon_sales SET category = TRIM(category);
UPDATE amazon_sales SET size = TRIM(size);
UPDATE amazon_sales SET asin = TRIM(asin);
UPDATE amazon_sales SET courier_status = TRIM(courier_status);
UPDATE amazon_sales SET ship_city = TRIM(ship_city);
UPDATE amazon_sales SET ship_state = TRIM(ship_state);
UPDATE amazon_sales SET ship_postal_code = TRIM(ship_postal_code);
UPDATE amazon_sales SET ship_country = TRIM(ship_country);
UPDATE amazon_sales SET promotion_ids = TRIM(promotion_ids);
UPDATE amazon_sales SET fulfilled_by = TRIM(fulfilled_by);


--- Column Standardalization ---
UPDATE amazon_sales SET status = INITCAP(status);
UPDATE amazon_sales SET courier_status = INITCAP(courier_status);
UPDATE amazon_sales SET fulfilment = INITCAP(fulfilment);
UPDATE amazon_sales SET sales_channel = INITCAP(sales_channel);
UPDATE amazon_sales SET fulfilled_by = INITCAP(fulfilled_by);


UPDATE amazon_sales
SET ship_city = INITCAP(TRIM(ship_city));

UPDATE amazon_sales
SET ship_state = INITCAP(TRIM(ship_state));


--- Restore Quality column ---
ALTER TABLE amazon_sales ADD COLUMN Qty INTEGER;

UPDATE amazon_sales AS a
SET Qty = NULLIF(REGEXP_REPLACE(raw."Qty", '[^0-9]', '', 'g'), '')::INTEGER
FROM "Raw_amazon_sales" AS raw
WHERE a.order_id = raw."Order ID";

SELECT quantity FROM amazon_sales LIMIT 10;

SELECT COUNT(*) FROM amazon_sales WHERE ship_country IS NULL;

---Derived Column Generation---
ALTER TABLE amazon_sales ADD COLUMN order_year INT;
ALTER TABLE amazon_sales ADD COLUMN order_month INT;

UPDATE amazon_sales
SET order_year = EXTRACT(YEAR FROM order_date),
    order_month = EXTRACT(MONTH FROM order_date);

--- Drop a column ---
ALTER TABLE amazon_sales DROP COLUMN fulfilled_by;


UPDATE amazon_sales SET currency = 'INR' WHERE currency IS NULL;

--- Grouping status column ---
ALTER TABLE amazon_sales ADD COLUMN order_status_grouped TEXT;

UPDATE amazon_sales
SET order_status_grouped = CASE
    WHEN status ILIKE 'cancel%' THEN 'Cancelled'
    WHEN status ILIKE 'pending%' THEN 'Pending'
    WHEN status ILIKE 'shipped - returned%' THEN 'Returned'
    WHEN status ILIKE 'shipped - returning%' THEN 'Returned'
    WHEN status ILIKE 'shipped - rejected%' THEN 'Returned'
    WHEN status ILIKE 'shipped - damaged%' THEN 'Damaged'
    WHEN status ILIKE 'shipped - lost%' THEN 'Lost'
    WHEN status ILIKE 'shipped%' THEN 'Shipped'
    WHEN status ILIKE 'shipping%' THEN 'Shipping'
    ELSE 'Other'
END;

SELECT order_status_grouped, COUNT(*)
FROM amazon_sales
GROUP BY order_status_grouped
ORDER BY COUNT(*) DESC;







-- Q1: Total spend per vendor (Delivered orders only)
USE vendor_performance;
GO

-- Q2: Task 1: SELECT basics
SELECT TOP 5 * FROM vendors;

SELECT vendor_id, vendor_name, city
FROM vendors;

SELECT vendor_name AS name, payment_terms_days AS credit_days
FROM vendors;

-- Q3: Task 2: WHERE: rows filter karna
-- 1) Active vendors
SELECT vendor_id, vendor_name, city
FROM vendors
WHERE status = 'Active';

-- 2) Vendors of two categories
SELECT vendor_id, vendor_name, category
FROM vendors
WHERE category IN ('Packaging', 'Raw Materials');

-- 3) Orders placed in 2025
SELECT COUNT(*) AS orders_2025
FROM purchase_orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31';

-- 4) Vendor names starting with S
SELECT vendor_name
FROM vendors
WHERE vendor_name LIKE 'S%';

-- 5) Large orders that were delivered
SELECT COUNT(*) AS large_delivered
FROM purchase_orders
WHERE is_large_order = 1 AND po_status = 'Delivered';

-- Q4: Task 3: ORDER BY aur TOP
SELECT TOP 5 po_id, vendor_id, quantity_ordered, total_amount
FROM purchase_orders
ORDER BY total_amount DESC;

-- Q5: Task 4: DISTINCT aur COUNT(DISTINCT ...)
SELECT DISTINCT category FROM vendors ORDER BY category;

SELECT YEAR(order_date) AS yr, COUNT(DISTINCT vendor_id) AS active_vendors
FROM purchase_orders
GROUP BY YEAR(order_date);

-- Q6: Task 5: Aggregate functions
-- All orders (Total Orders KPI)
SELECT COUNT(*) AS total_orders FROM purchase_orders;

-- Delivered orders: count, spend, average, smallest, largest
SELECT COUNT(*)                    AS delivered_orders,
       ROUND(SUM(total_amount), 2) AS total_spend,
       ROUND(AVG(total_amount), 2) AS avg_order_value,
       MIN(total_amount)           AS smallest_order,
       MAX(total_amount)           AS largest_order
FROM purchase_orders
WHERE po_status = 'Delivered';

-- Q7: Task 6: GROUP BY: asli KPIs
-- KPI 1: Total spend per vendor (Delivered orders only)
SELECT vendor_id,
       ROUND(SUM(total_amount), 2) AS total_spend
FROM purchase_orders
WHERE po_status = 'Delivered'
GROUP BY vendor_id
ORDER BY total_spend DESC;

-- KPI 2: Total orders per vendor (all orders placed)
SELECT vendor_id,
       COUNT(*) AS total_orders
FROM purchase_orders
GROUP BY vendor_id
ORDER BY total_orders DESC;

-- Q8: Ab saal ke hisaab se spend aur orders
SELECT YEAR(order_date)                                              AS yr,
       COUNT(*)                                                      AS orders,
       ROUND(SUM(CASE WHEN po_status = 'Delivered' THEN total_amount END), 2) AS spend
FROM purchase_orders
GROUP BY YEAR(order_date)
ORDER BY yr;

-- Q9: Aur ek monthly query:
SELECT YEAR(order_date) AS yr, MONTH(order_date) AS mth,
       ROUND(SUM(total_amount), 2) AS spend
FROM purchase_orders
WHERE po_status = 'Delivered'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY yr, mth;
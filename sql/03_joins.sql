-- Q1 - Task 1: Pehla INNER JOIN
SELECT TOP 5
       po.po_id,
       v.vendor_name,
       po.order_date,
       po.total_amount
FROM purchase_orders AS po
INNER JOIN vendors AS v
        ON po.vendor_id = v.vendor_id
ORDER BY po.po_id;

-- Q2 - Task 2: KPI 1 ka final roop: vendor naam ke saath spend
SELECT v.vendor_id,
       v.vendor_name,
       v.category,
       ROUND(SUM(po.total_amount), 2) AS total_spend
FROM purchase_orders AS po
INNER JOIN vendors AS v
        ON po.vendor_id = v.vendor_id
WHERE po.po_status = 'Delivered'
GROUP BY v.vendor_id, v.vendor_name, v.category
ORDER BY total_spend DESC;

-- Q3 - Task 3: Teen tables ka JOIN
SELECT TOP 5
       p.product_name,
       p.category,
       COUNT(*)                    AS orders,
       ROUND(SUM(po.total_amount), 2) AS spend
FROM purchase_orders AS po
INNER JOIN products AS p
        ON po.product_id = p.product_id
WHERE po.po_status = 'Delivered'
GROUP BY p.product_name, p.category
ORDER BY spend DESC;

-- Q4 - Task 4: Orders + Deliveries + DATEDIFF: kitne din late?
SELECT TOP 5
       po.po_id,
       v.vendor_name,
       po.expected_delivery_date,
       d.actual_delivery_date,
       DATEDIFF(day, po.expected_delivery_date, d.actual_delivery_date) AS days_late
FROM deliveries AS d
INNER JOIN purchase_orders AS po ON d.po_id = po.po_id
INNER JOIN vendors         AS v  ON po.vendor_id = v.vendor_id
ORDER BY days_late DESC, po.po_id;

-- Q5 - Task 5: LEFT JOIN: jo match nahi hota use pakadna
SELECT po.po_status, COUNT(*) AS orders_without_delivery
FROM purchase_orders AS po
LEFT JOIN deliveries AS d
       ON po.po_id = d.po_id
WHERE d.delivery_id IS NULL
GROUP BY po.po_status;

-- Q6 - Task 6: INNER aur LEFT ke row counts compare karo
SELECT COUNT(*) AS inner_rows
FROM purchase_orders AS po
INNER JOIN deliveries AS d ON po.po_id = d.po_id;

SELECT COUNT(*) AS left_rows
FROM purchase_orders AS po
LEFT JOIN deliveries AS d ON po.po_id = d.po_id;

-- Orphan check: deliveries that point to a missing order
SELECT COUNT(*) AS orphan_deliveries
FROM deliveries AS d
LEFT JOIN purchase_orders AS po ON d.po_id = po.po_id
WHERE po.po_id IS NULL;

-- Q7 - Ek aur bonus query: category-wise spend
SELECT v.category,
       COUNT(*)                       AS orders,
       ROUND(SUM(po.total_amount), 2) AS spend
FROM purchase_orders AS po
INNER JOIN vendors AS v ON po.vendor_id = v.vendor_id
WHERE po.po_status = 'Delivered'
GROUP BY v.category
ORDER BY spend DESC;
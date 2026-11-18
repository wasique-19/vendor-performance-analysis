-- Q1 - Task 1: CASE WHEN: SQL ka if-else
SELECT TOP 5
       po.po_id,
       po.expected_delivery_date,
       d.actual_delivery_date,
       CASE
           WHEN d.actual_delivery_date IS NULL                          THEN 'Unknown'
           WHEN d.actual_delivery_date <= po.expected_delivery_date     THEN 'On-Time'
           ELSE 'Late'
       END AS delivery_status
FROM deliveries AS d
INNER JOIN purchase_orders AS po ON d.po_id = po.po_id
ORDER BY po.po_id;

-- Q2 - Ab ginti:
SELECT delivery_status, COUNT(*) AS deliveries
FROM (
    SELECT CASE
               WHEN d.actual_delivery_date IS NULL                      THEN 'Unknown'
               WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 'On-Time'
               ELSE 'Late'
           END AS delivery_status
    FROM deliveries AS d
    INNER JOIN purchase_orders AS po ON d.po_id = po.po_id
) AS t
GROUP BY delivery_status;

-- Q3 - Task 2: Poori company ke KPIs (ek query me)
SELECT
    COUNT(*) AS deliveries,

    CAST(100.0 * AVG(CASE
            WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 1.0
            WHEN d.actual_delivery_date >  po.expected_delivery_date THEN 0.0
        END) AS DECIMAL(5,2)) AS on_time_pct,

    CAST(100.0 * AVG(CASE
            WHEN d.actual_delivery_date >  po.expected_delivery_date THEN 1.0
            WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 0.0
        END) AS DECIMAL(5,2)) AS late_pct,

    CAST(100.0 * SUM(d.quantity_defective)
         / SUM(CASE WHEN d.defect_data_invalid = 0 THEN d.quantity_received END)
         AS DECIMAL(5,2)) AS defect_rate_pct,

    CAST(AVG(1.0 * DATEDIFF(day, po.order_date, d.actual_delivery_date))
         AS DECIMAL(6,2)) AS avg_delivery_days
FROM deliveries AS d
INNER JOIN purchase_orders AS po ON d.po_id = po.po_id;

-- Q4 - Task 3: Har vendor ka scorecard (KPIs 3–6)
SELECT
    v.vendor_id,
    v.vendor_name,
    COUNT(*) AS deliveries,
    CAST(100.0 * AVG(CASE
            WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 1.0
            WHEN d.actual_delivery_date >  po.expected_delivery_date THEN 0.0
        END) AS DECIMAL(5,2)) AS on_time_pct,
    CAST(100.0 * AVG(CASE
            WHEN d.actual_delivery_date >  po.expected_delivery_date THEN 1.0
            WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 0.0
        END) AS DECIMAL(5,2)) AS late_pct,
    CAST(100.0 * SUM(d.quantity_defective)
         / SUM(CASE WHEN d.defect_data_invalid = 0 THEN d.quantity_received END)
         AS DECIMAL(5,2)) AS defect_rate_pct,
    CAST(AVG(1.0 * DATEDIFF(day, po.order_date, d.actual_delivery_date))
         AS DECIMAL(6,2)) AS avg_delivery_days
FROM deliveries AS d
INNER JOIN purchase_orders AS po ON d.po_id = po.po_id
INNER JOIN vendors         AS v  ON po.vendor_id = v.vendor_id
GROUP BY v.vendor_id, v.vendor_name
ORDER BY on_time_pct DESC;

-- Q5 - Task 4: HAVING: groups ko filter karna
SELECT vendor_id, COUNT(*) AS total_orders
FROM purchase_orders
GROUP BY vendor_id
HAVING COUNT(*) > 300
ORDER BY total_orders DESC;

-- Q6 - Task 5: Subqueries (query ke andar query)
SELECT COUNT(*) AS above_average_orders
FROM purchase_orders
WHERE po_status = 'Delivered'
  AND total_amount > (SELECT AVG(total_amount)
                      FROM purchase_orders
                      WHERE po_status = 'Delivered');

-- Q7 - Task 6: Monthly on-time trend (date-based analysis)
SELECT YEAR(po.order_date)  AS yr,
       MONTH(po.order_date) AS mth,
       COUNT(*)             AS deliveries,
       CAST(100.0 * AVG(CASE
               WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 1.0
               WHEN d.actual_delivery_date >  po.expected_delivery_date THEN 0.0
           END) AS DECIMAL(5,2)) AS on_time_pct
FROM deliveries AS d
INNER JOIN purchase_orders AS po ON d.po_id = po.po_id
GROUP BY YEAR(po.order_date), MONTH(po.order_date)
ORDER BY yr, mth;
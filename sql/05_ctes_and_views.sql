-- Q1 - Task 1: Day 12 ki query ko CTE se saaf karo
WITH vendor_late AS (
    SELECT v.vendor_id,
           v.vendor_name,
           100.0 * AVG(CASE
               WHEN d.actual_delivery_date >  po.expected_delivery_date THEN 1.0
               WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 0.0
           END) AS late_pct
    FROM deliveries AS d
    INNER JOIN purchase_orders AS po ON d.po_id = po.po_id
    INNER JOIN vendors         AS v  ON po.vendor_id = v.vendor_id
    GROUP BY v.vendor_id, v.vendor_name
)
SELECT vendor_id,
       vendor_name,
       CAST(late_pct AS DECIMAL(5,2)) AS late_pct
FROM vendor_late
WHERE late_pct > 20
ORDER BY late_pct DESC;

-- Q2 - Task 2: Vendor Scorecard: kai CTEs ek chain me
WITH delivery_kpis AS (
    SELECT po.vendor_id,
           COUNT(*) AS deliveries,
           100.0 * AVG(CASE
               WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 1.0
               WHEN d.actual_delivery_date >  po.expected_delivery_date THEN 0.0
           END) AS on_time_pct,
           100.0 * SUM(d.quantity_defective)
                 / SUM(CASE WHEN d.defect_data_invalid = 0 THEN d.quantity_received END) AS defect_rate_pct,
           AVG(1.0 * DATEDIFF(day, po.order_date, d.actual_delivery_date)) AS avg_delivery_days
    FROM deliveries AS d
    INNER JOIN purchase_orders AS po ON d.po_id = po.po_id
    GROUP BY po.vendor_id
),
order_kpis AS (
    SELECT vendor_id,
           COUNT(*) AS total_orders,
           SUM(CASE WHEN po_status = 'Delivered' THEN total_amount ELSE 0 END) AS total_spend
    FROM purchase_orders
    GROUP BY vendor_id
),
scored AS (
    SELECT v.vendor_id, v.vendor_name, v.category, v.status,
           o.total_orders, o.total_spend,
           k.deliveries, k.on_time_pct, k.defect_rate_pct, k.avg_delivery_days,
           CASE WHEN 100 - 10 * k.defect_rate_pct < 0 THEN 0
                ELSE 100 - 10 * k.defect_rate_pct END AS defect_score
    FROM vendors AS v
    INNER JOIN order_kpis    AS o ON o.vendor_id = v.vendor_id
    INNER JOIN delivery_kpis AS k ON k.vendor_id = v.vendor_id
)
SELECT vendor_id, vendor_name, category, status,
       total_orders,
       CAST(total_spend AS DECIMAL(14,2))          AS total_spend,
       deliveries,
       CAST(on_time_pct AS DECIMAL(5,2))           AS on_time_pct,
       CAST(defect_rate_pct AS DECIMAL(5,2))       AS defect_rate_pct,
       CAST(avg_delivery_days AS DECIMAL(6,2))     AS avg_delivery_days,
       CAST(0.6 * on_time_pct + 0.4 * defect_score AS DECIMAL(5,2)) AS quality_score
FROM scored
ORDER BY quality_score DESC;

-- Q3 - Task 3: Scorecard ko View me save karo
GO
CREATE OR ALTER VIEW dbo.vw_vendor_scorecard AS
WITH delivery_kpis AS (
    SELECT po.vendor_id,
           COUNT(*) AS deliveries,
           100.0 * AVG(CASE
               WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 1.0
               WHEN d.actual_delivery_date >  po.expected_delivery_date THEN 0.0
           END) AS on_time_pct,
           100.0 * SUM(d.quantity_defective)
                 / SUM(CASE WHEN d.defect_data_invalid = 0 THEN d.quantity_received END) AS defect_rate_pct,
           AVG(1.0 * DATEDIFF(day, po.order_date, d.actual_delivery_date)) AS avg_delivery_days
    FROM deliveries AS d
    INNER JOIN purchase_orders AS po ON d.po_id = po.po_id
    GROUP BY po.vendor_id
),
order_kpis AS (
    SELECT vendor_id,
           COUNT(*) AS total_orders,
           SUM(CASE WHEN po_status = 'Delivered' THEN total_amount ELSE 0 END) AS total_spend
    FROM purchase_orders
    GROUP BY vendor_id
),
scored AS (
    SELECT v.vendor_id, v.vendor_name, v.category, v.status,
           o.total_orders, o.total_spend,
           k.deliveries, k.on_time_pct, k.defect_rate_pct, k.avg_delivery_days,
           CASE WHEN 100 - 10 * k.defect_rate_pct < 0 THEN 0
                ELSE 100 - 10 * k.defect_rate_pct END AS defect_score
    FROM vendors AS v
    INNER JOIN order_kpis    AS o ON o.vendor_id = v.vendor_id
    INNER JOIN delivery_kpis AS k ON k.vendor_id = v.vendor_id
)
SELECT vendor_id, vendor_name, category, status,
       total_orders,
       CAST(total_spend AS DECIMAL(14,2))          AS total_spend,
       deliveries,
       CAST(on_time_pct AS DECIMAL(5,2))           AS on_time_pct,
       CAST(defect_rate_pct AS DECIMAL(5,2))       AS defect_rate_pct,
       CAST(avg_delivery_days AS DECIMAL(6,2))     AS avg_delivery_days,
       CAST(0.6 * on_time_pct + 0.4 * defect_score AS DECIMAL(5,2)) AS quality_score
FROM scored;
GO

SELECT * FROM dbo.vw_vendor_scorecard ORDER BY quality_score DESC;
GO

SELECT CAST(SUM(total_spend) AS DECIMAL(14,2)) AS check_total_spend
FROM dbo.vw_vendor_scorecard;

-- Q4 - Task 4: Monthly Vendor Performance (Query 7)
GO
CREATE OR ALTER VIEW dbo.vw_vendor_monthly AS
SELECT po.vendor_id,
       YEAR(po.order_date)  AS yr,
       MONTH(po.order_date) AS mth,
       COUNT(*)                                   AS orders,
       SUM(CASE WHEN po.po_status = 'Delivered' THEN po.total_amount ELSE 0 END) AS spend,
       COUNT(d.delivery_id)                       AS deliveries,
       COUNT(d.actual_delivery_date)              AS dated_deliveries,
       SUM(CASE WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 1 ELSE 0 END) AS on_time_deliveries,
       CAST(100.0 * SUM(CASE WHEN d.actual_delivery_date <= po.expected_delivery_date THEN 1 ELSE 0 END)
            / NULLIF(COUNT(d.actual_delivery_date), 0) AS DECIMAL(5,2)) AS on_time_pct
FROM purchase_orders AS po
LEFT JOIN deliveries AS d ON d.po_id = po.po_id
GROUP BY po.vendor_id, YEAR(po.order_date), MONTH(po.order_date);
GO

SELECT * FROM dbo.vw_vendor_monthly
WHERE vendor_id = 'V001'
ORDER BY yr, mth;
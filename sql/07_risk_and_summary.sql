-- Q1 - Task 2: vw_vendor_risk view banao
GO
CREATE OR ALTER VIEW dbo.vw_vendor_risk AS
WITH base AS (
    SELECT vendor_id, vendor_name, category, status, total_orders, total_spend,
           100.0 * total_spend / SUM(total_spend) OVER () AS spend_share_pct,
           on_time_pct, defect_rate_pct, avg_delivery_days, quality_score
    FROM dbo.vw_vendor_scorecard
)
SELECT vendor_id, vendor_name, category, status, total_spend,
       CAST(spend_share_pct AS DECIMAL(5,2)) AS spend_share_pct,
       on_time_pct, defect_rate_pct, quality_score,
       CASE
           WHEN quality_score < 70 AND spend_share_pct >= 2 THEN 'High'
           WHEN quality_score < 70                           THEN 'Medium'
           WHEN on_time_pct < 75                             THEN 'Medium'
           WHEN spend_share_pct >= 10                        THEN 'Medium'
           ELSE 'Low'
       END AS risk_category,
       CASE
           WHEN quality_score < 70 AND spend_share_pct >= 2 THEN 'Poor quality score and meaningful spend'
           WHEN quality_score < 70                           THEN 'Poor quality score, small spend'
           WHEN on_time_pct < 75                             THEN 'Late deliveries (on-time below 75%)'
           WHEN spend_share_pct >= 10                        THEN 'Spend concentration (10% or more)'
           ELSE 'No major issue'
       END AS risk_reason
FROM base;
GO

SELECT vendor_id, vendor_name, total_spend, spend_share_pct, quality_score, on_time_pct,
       risk_category, risk_reason
FROM dbo.vw_vendor_risk
ORDER BY CASE risk_category WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END,
         total_spend DESC;

-- Q2 - Task 3: Risk summary
SELECT risk_category,
       COUNT(*)                                         AS vendors,
       CAST(SUM(total_spend) AS DECIMAL(14,2))          AS spend,
       CAST(100.0 * SUM(total_spend)
            / SUM(SUM(total_spend)) OVER () AS DECIMAL(5,2)) AS spend_share_pct
FROM dbo.vw_vendor_risk
GROUP BY risk_category
ORDER BY CASE risk_category WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

-- Q3 - Task 4: Category-level concentration
SELECT category,
       COUNT(*)                                         AS vendors,
       CAST(SUM(total_spend) AS DECIMAL(14,2))          AS spend,
       CAST(100.0 * SUM(total_spend)
            / SUM(SUM(total_spend)) OVER () AS DECIMAL(5,2)) AS spend_share_pct
FROM dbo.vw_vendor_scorecard
GROUP BY category
ORDER BY spend DESC;
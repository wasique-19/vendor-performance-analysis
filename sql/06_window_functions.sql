-- Q1 - Task 1: ROW_NUMBER, RANK, DENSE_RANK: teeno ka farak
SELECT TOP 9
       vendor_id,
       payment_terms_days,
       ROW_NUMBER() OVER (ORDER BY payment_terms_days DESC, vendor_id) AS row_num,
       RANK()       OVER (ORDER BY payment_terms_days DESC)            AS rnk,
       DENSE_RANK() OVER (ORDER BY payment_terms_days DESC)            AS dense_rnk
FROM vendors
ORDER BY row_num;

-- Q2 - Task 2: Vendor Ranking (Query 8), overall aur category ke andar
SELECT vendor_id,
       vendor_name,
       category,
       quality_score,
       RANK() OVER (ORDER BY quality_score DESC)                      AS overall_rank,
       RANK() OVER (PARTITION BY category ORDER BY quality_score DESC) AS category_rank
FROM dbo.vw_vendor_scorecard
ORDER BY overall_rank;

-- Q3 - Task 3: AVG() OVER (): High-spend, low-performance vendors (Query 9)
WITH v AS (
    SELECT vendor_id, vendor_name, total_spend, quality_score,
           AVG(total_spend)   OVER () AS avg_spend,
           AVG(quality_score) OVER () AS avg_quality
    FROM dbo.vw_vendor_scorecard
)
SELECT vendor_id,
       vendor_name,
       total_spend,
       quality_score,
       CAST(avg_spend   AS DECIMAL(14,2)) AS avg_spend,
       CAST(avg_quality AS DECIMAL(5,2))  AS avg_quality
FROM v
WHERE total_spend > avg_spend
  AND quality_score < avg_quality
ORDER BY total_spend DESC;

-- Q4 - Task 4: Spend Concentration aur Pareto (running total)
WITH s AS (
    SELECT vendor_id, vendor_name, total_spend,
           100.0 * total_spend / SUM(total_spend) OVER () AS spend_share_pct
    FROM dbo.vw_vendor_scorecard
)
SELECT vendor_id,
       vendor_name,
       total_spend,
       CAST(spend_share_pct AS DECIMAL(5,2)) AS spend_share_pct,
       CAST(SUM(spend_share_pct) OVER (ORDER BY total_spend DESC
                                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            AS DECIMAL(5,2)) AS cumulative_pct
FROM s
ORDER BY total_spend DESC;

-- Q5 - Task 5: LAG: Month-over-Month change aur running total
WITH monthly AS (
    SELECT yr, mth, SUM(spend) AS spend
    FROM dbo.vw_vendor_monthly
    GROUP BY yr, mth
)
SELECT yr,
       mth,
       CAST(spend AS DECIMAL(14,2)) AS spend,
       CAST(LAG(spend) OVER (ORDER BY yr, mth) AS DECIMAL(14,2)) AS prev_month_spend,
       CAST(100.0 * (spend - LAG(spend) OVER (ORDER BY yr, mth))
            / NULLIF(LAG(spend) OVER (ORDER BY yr, mth), 0) AS DECIMAL(6,2)) AS mom_change_pct,
       CAST(SUM(spend) OVER (ORDER BY yr, mth
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            AS DECIMAL(14,2)) AS running_total
FROM monthly
ORDER BY yr, mth;
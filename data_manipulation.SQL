-- Step 1: Tag and filter sales by period
WITH sales_periods AS (
  SELECT
    asin,
    date,
    revenue,
    units_sold,
    CASE 
      WHEN date BETWEEN '2024-07-15' AND '2024-07-16' THEN 'prime'
      WHEN date BETWEEN '2024-06-17' AND '2024-07-14' THEN 'before'
      WHEN date BETWEEN '2024-07-17' AND '2024-08-13' THEN 'after'
      ELSE NULL
    END AS period
  FROM sales
  WHERE date BETWEEN '2024-06-17' AND '2024-08-13'
)

-- Step 2: Aggregate daily averages per ASIN per period
, aggregated_daily_sales AS (
  SELECT
    asin,
    period,
    COUNT(DISTINCT date) AS num_days,
    SUM(revenue) AS total_revenue,
    SUM(units_sold) AS total_units,
    ROUND(SUM(revenue) * 1.0 / COUNT(DISTINCT date), 2) AS avg_daily_revenue,
    ROUND(SUM(units_sold) * 1.0 / COUNT(DISTINCT date), 2) AS avg_daily_units
  FROM sales_periods
  WHERE period IS NOT NULL
  GROUP BY asin, period
)

-- Step 3: Pivot the daily metrics into a single row per ASIN
, reshaped_sales AS (
  SELECT
    asin,
    MAX(CASE WHEN period = 'prime' THEN avg_daily_revenue END) AS avg_daily_revenue_prime,
    MAX(CASE WHEN period = 'prime' THEN avg_daily_units END) AS avg_daily_units_prime,
    
    MAX(CASE WHEN period = 'before' THEN avg_daily_revenue END) AS avg_daily_revenue_before,
    MAX(CASE WHEN period = 'after' THEN avg_daily_revenue END) AS avg_daily_revenue_after,
    
    MAX(CASE WHEN period = 'before' THEN avg_daily_units END) AS avg_daily_units_before,
    MAX(CASE WHEN period = 'after' THEN avg_daily_units END) AS avg_daily_units_after
  FROM aggregated_daily_sales
  GROUP BY asin
)

-- Step 4: Enrich with product info and billback
, enriched_products AS (
  SELECT
    pr.asin,
    pr.product_title,
    pl.upc,
    pl.brand,
    pl.segment,
    pl.cost,
    pr.msrp,
    promo.billback
  FROM products_retail pr
  JOIN products_listing pl ON pr.upc = pl.upc
  LEFT JOIN promotion promo ON pr.asin = promo.asin
)

-- Step 5: Final metrics and ROI calculations
SELECT
  ep.asin,
  ep.upc,
  ep.product_title,
  ep.brand,
  ep.segment,
  ep.cost,
  ep.msrp,
  ep.billback,

  --  Performance during Prime Day
  rs.avg_daily_revenue_prime,
  rs.avg_daily_units_prime,


  --  Lift during promo vs. baseline before promo
  ROUND(((rs.avg_daily_revenue_prime - s.avg_daily_revenue_before)
         / NULLIF(rs.avg_daily_revenue_before)) * 100, 2) AS revenue_lift_pct,
    ROUND(((rs.avg_daily_units_prime - s.avg_daily_units_before)
         / NULLIF(rs.avg_daily_units_before)) * 100, 2) AS units_lift_pct,

  --  Before vs. After comparison (retention effect)
  ROUND(((rs.avg_daily_revenue_after - rs.avg_daily_revenue_before) 
         / NULLIF(rs.avg_daily_revenue_before, 0)) * 100, 2) AS after_vs_before_revenue_pct,
  ROUND(((rs.avg_daily_units_after - rs.avg_daily_units_before) 
         / NULLIF(rs.avg_daily_units_before, 0)) * 100, 2) AS after_vs_before_unit_pct,

  --  ROI Calculations
  ROUND((ep.msrp - ep.cost - COALESCE(ep.billback, 0)), 2) AS net_margin_per_unit,
  ROUND((rs.avg_daily_units_prime * 2 * COALESCE(ep.billback, 0)), 2) AS total_promo_cost,
  ROUND((rs.avg_daily_units_prime * 2 * (ep.msrp - ep.cost - COALESCE(ep.billback, 0))), 2) AS total_net_profit,

  CASE 
    WHEN COALESCE(ep.billback, 0) = 0 THEN NULL
    ELSE ROUND((rs.avg_daily_units_prime * 2 * (ep.msrp - ep.cost - ep.billback)) 
                / NULLIF((rs.avg_daily_units_prime * 2 * ep.billback), 0), 2)
  END AS promo_roi

FROM reshaped_sales rs
JOIN enriched_products ep ON rs.asin = ep.asin



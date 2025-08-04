SELECT ASIN,
       SUM(CASE WHEN Date Between '2024-07-16' AND '2024-07-17' THEN OrderedRevenue END) AS sales_during_prime, 
       SUM(CASE WHEN Date Between '2024-07-16' AND '2024-07-17' THEN OrderedUnits END) AS units_during_prime
FROM Sales

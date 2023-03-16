--Interest Analysis
--Which interests have been present in all month_year dates in our dataset?
WITH cte AS (SELECT interest_id::INT,interest_name,COUNT(DISTINCT month_year) AS Times
FROM fresh_segments.interest_metrics met
LEFT JOIN fresh_segments.interest_map im
ON im.id=met.interest_id::INT 
WHERE interest_id IS NOT NULL 
GROUP BY 1,2)
SELECT * FROM cte
WHERE TIMES=(SELECT COUNT(DISTINCT month_year) FROM fresh_segments.interest_metrics)

--Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
WITH c1 AS (SELECT interest_id, COUNT(DISTINCT month_year) AS total_months
FROM fresh_segments.interest_metrics
GROUP BY 1
ORDER BY 2 DESC),
c2 AS (
SELECT total_months, COUNT(total_months) AS Number
FROM c1
GROUP BY 1 
ORDER BY 1 DESC)

SELECT total_months,CONCAT(ROUND(SUM(Number) OVER (ORDER BY total_months DESC)::NUMERIC/SUM(Number) OVER()::NUMERIC*100,2),'%') AS Cum_Per 
FROM c2
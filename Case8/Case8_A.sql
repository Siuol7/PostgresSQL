--Data Exploration and Cleansing
--Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
ALTER TABLE fresh_segments.interest_metrics
ALTER COLUMN month_year TYPE DATE USING  TO_DATE(month_year,'MM-YYYY')

--What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT month_year, COUNT(ranking) AS NUmber_of_records
FROM fresh_segments.interest_metrics
GROUP BY 1
ORDER BY month_year ASC NULLS FIRST



--How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
SELECT COUNT(distinct interest_id)
FROM fresh_segments.interest_metrics
WHERE interest_id::INT NOT IN (SELECT id FROM fresh_segments.interest_map)

--Summarise the id values in the fresh_segments.interest_map by its total record count in this table
SELECT COUNT(DISTINCT id) AS Number_of_id
FROM fresh_segments.interest_map


--What sort of table join should we perform for our analysis and why? 
	--Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
SELECT _month,_year,month_year, interest_id::INT,composition,index_value,ranking,percentile_ranking,interest_name,interest_summary,created_at,last_modified
FROM fresh_segments.interest_metrics met 
LEFT JOIN fresh_segments.interest_map im
ON im.id=met.interest_id::INT 
WHERE interest_id IS NOT NULL AND interest_id::INT=21246
ORDER BY interest_id ASC,month_year ASC NULLS FIRST


--Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
SELECT _month,_year,month_year, interest_id::INT,composition,index_value,ranking,percentile_ranking,interest_name,interest_summary,created_at,last_modified
FROM fresh_segments.interest_metrics met 
LEFT JOIN fresh_segments.interest_map im
ON im.id=met.interest_id::INT 
WHERE interest_id IS NOT NULL AND month_year<created_at
ORDER BY interest_id ASC,month_year ASC NULLS FIRST
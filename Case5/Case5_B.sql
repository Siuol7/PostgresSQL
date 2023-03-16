--2. Data Exploration
--What day of the week is used for each week_date value?
SELECT CASE 
			WHEN EXTRACT(DOW FROM week_date)=0 THEN 'Sunday'
			WHEN EXTRACT(DOW FROM week_date)=1 THEN 'Monday'
			WHEN EXTRACT(DOW FROM week_date)=2 THEN 'Tuesday'
			WHEN EXTRACT(DOW FROM week_date)=3 THEN 'Wednesday'
			WHEN EXTRACT(DOW FROM week_date)=4 THEN 'Thursday'
			WHEN EXTRACT(DOW FROM week_date)=5 THEN 'Friday'
			ELSE 'Saturday'
		END AS day_of_the_week,* FROM data_mart.clean_weekly_sales 

--What range of week numbers are missing from the dataset?
WITH cte AS (SELECT GENERATE_SERIES(1,52) AS week_number )

SELECT DISTINCT (c.week_number) AS Missing_week_number
DEOM data_mart.clean_weekly_sales d
LEFT JOIN cte c
ON c.week_number != d.week_number
ORDER BY 1


--How many total transactions were there for each year in the dataset?
SELECT EXTRACT( YEAR FROM week_date) AS year, SUM(avg_transactions) AS total_transactions 
FROM data_mart.clean_weekly_sales cws 
GROUP BY 1


--What is the total sales for each region for each month?
SELECT EXTRACT(YEAR FROM week_date) AS year,EXTRACT(MONTH FROM week_date) AS month, region, SUM(sales)
FROM data_mart.clean_weekly_sales cws
GROUP BY 1,2,3
ORDER BY 1,2

--What is the total count of transactions for each platform
SELECT platform, COUNT(avg_transactions) 
FROM data_mart.clean_weekly_sales cws 
GROUP BY 1

--What is the percentage of sales for Retail vs Shopify for each month?
WITH cte AS(SELECT EXTRACT(YEAR FROM week_date) AS year, EXTRACT(MONTH FROM week_date) AS month,SUM(sales) AS total 
FROM data_mart.clean_weekly_sales cws 
GROUP BY 1,2
ORDER BY 1,2),
ct2 AS(
SELECT EXTRACT(YEAR FROM week_date) AS year,EXTRACT(MONTH FROM week_date) AS month, platform, SUM(sales) AS split_sales
FROM data_mart.clean_weekly_sales cws
GROUP BY 1,2,3
ORDER BY 1,2)

SELECT year,month, platform, CONCAT(ROUND(split_sales/total::NUMERIC*100,2),'%') AS Distribution
FROM cte 
INNER JOIN ct2 
USING(year,month)


--What is the percentage of sales by demographic for each year in the dataset?
WITH cte AS(SELECT EXTRACT(YEAR FROM week_date) AS year,SUM(sales) AS total 
FROM data_mart.clean_weekly_sales cws 
GROUP BY 1
ORDER BY 1),
ct2 AS(
SELECT EXTRACT(YEAR FROM week_date) AS year, demographic, SUM(sales) AS split_sales
FROM data_mart.clean_weekly_sales cws
GROUP BY 1,2
ORDER BY 1,2)

SELECT year, demographic, CONCAT(ROUND(split_sales/total::NUMERIC*100,2),'%') AS Distribution
FROM cte 
INNER JOIN ct2 
USING(year)


--Which age_band and demographic values contribute the most to Retail sales?
SELECT cws.age_band,CONCAT(ROUND(SUM(sales)/(SELECT SUM(sales) FROM data_mart.clean_weekly_sales cws WHERE platform='Retail')::NUMERIC*100,2),'%') AS Distribution
FROM data_mart.clean_weekly_sales cws
GROUP BY 1

SELECT cws.demographic,CONCAT(ROUND(SUM(sales)/(SELECT SUM(sales) FROM data_mart.clean_weekly_sales cws WHERE platform='Retail')::NUMERIC*100,2),'%') AS Distribution
FROM data_mart.clean_weekly_sales cws
GROUP BY 1


--Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT EXTRACT(YEAR FROM TO_DATE(week_date,'DD/MM/YY')) AS year, platform, SUM(transactions) AS transaction_size
FROM data_mart.weekly_sales ws 
GROUP BY 1,2
ORDER BY 1


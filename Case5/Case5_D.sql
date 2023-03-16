--4. Bonus Question
--Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

	--region
	--platform
	--age_band
	--demographic
	--customer_type
--Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?
--By Region
	WITH c1 AS(SELECT region,SUM(sales) AS IniRevenue
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15'::DATE-INTERVAL '12 weeks' AND '2020-06-15'
	group by 1),
	c2 AS(
	SELECT region,SUM(sales) AS AftRevenue 
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15' AND '2020-06-15'::DATE+INTERVAL '12 weeks'
	GROUP BY 1)
	SELECT region,IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	INNER JOIN c2
	USING(region)
	GROUP BY 1,2,3
	ORDER BY 4 ASC

--By Platform
	WITH c1 AS(SELECT platform,SUM(sales) AS IniRevenue
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15'::DATE-INTERVAL '12 weeks' AND '2020-06-15'
	group by 1),
	c2 AS(
	SELECT platform,SUM(sales) AS AftRevenue 
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15' AND '2020-06-15'::DATE+INTERVAL '12 weeks'
	GROUP BY 1)
	SELECT platform,IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	INNER JOIN c2
	USING(platform)
	GROUP BY 1,2,3
	ORDER BY 4 ASC

--By AGE_BAND
	WITH c1 AS(SELECT age_band ,SUM(sales) AS IniRevenue
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15'::DATE-INTERVAL '12 weeks' AND '2020-06-15'
	group by 1),
	c2 AS(
	SELECT age_band ,SUM(sales) AS AftRevenue 
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15' AND '2020-06-15'::DATE+INTERVAL '12 weeks'
	GROUP BY 1)
	SELECT age_band ,IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	INNER JOIN c2
	USING(age_band)
	GROUP BY 1,2,3
	ORDER BY 4 ASC

--By Demographic
	WITH c1 AS(SELECT demographic  ,SUM(sales) AS IniRevenue
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15'::DATE-INTERVAL '12 weeks' AND '2020-06-15'
	group by 1),
	c2 AS(
	SELECT demographic  ,SUM(sales) AS AftRevenue 
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15' AND '2020-06-15'::DATE+INTERVAL '12 weeks'
	GROUP BY 1)
	SELECT demographic  ,IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	INNER JOIN c2
	USING(demographic)
	GROUP BY 1,2,3
	ORDER BY 4 ASC

--By Customer Type
	WITH c1 AS(SELECT customer_type ,SUM(sales) AS IniRevenue
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15'::DATE-INTERVAL '12 weeks' AND '2020-06-15'
	group by 1),
	c2 AS(
	SELECT customer_type  ,SUM(sales) AS AftRevenue 
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15' AND '2020-06-15'::DATE+INTERVAL '12 weeks'
	GROUP BY 1)
	SELECT customer_type  ,IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	INNER JOIN c2
	USING(customer_type)
	GROUP BY 1,2,3
	ORDER BY 4 ASC

--By General
	WITH c1 AS(SELECT region,platform,age_band,demographic,customer_type ,SUM(sales) AS IniRevenue
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15'::DATE-INTERVAL '12 weeks' AND '2020-06-15'
	group by region,platform,age_band,demographic,customer_type),
	c2 AS(
	SELECT region,platform,age_band,demographic,customer_type  ,SUM(sales) AS AftRevenue 
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN '2020-06-15' AND '2020-06-15'::DATE+INTERVAL '12 weeks'
	GROUP BY region,platform,age_band,demographic,customer_type)
	SELECT c1.region,c1.platform,c1.age_band,c1.demographic,c1.customer_type,IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	INNER JOIN c2
	USING(customer_type)
	GROUP BY 1,2,3,4,5,6,7
	ORDER BY 8 DESC
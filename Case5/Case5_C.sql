--3. Before & After Analysis
--This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

--Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

--We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

--Using this analysis approach - answer the following questions:

	--What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
	WITH c1 AS(SELECT SUM(sales) AS IniRevenue FROM data_mart.clean_weekly_sales WHERE week_date BETWEEN '2020-06-15'::DATE-INTERVAL '4 weeks' AND '2020-06-15'),
	c2 AS(
	SELECT SUM(sales) AS AftRevenue FROM data_mart.clean_weekly_sales WHERE week_date BETWEEN '2020-06-15' AND '2020-06-15'::DATE+INTERVAL '4 weeks')
	SELECT IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	CROSS JOIN c2


    --What about the entire 12 weeks before and after?
	WITH c1 AS(SELECT SUM(sales) AS IniRevenue FROM data_mart.clean_weekly_sales WHERE week_date BETWEEN '2020-06-15'::DATE-INTERVAL '12 weeks' AND '2020-06-15'),
	c2 AS(
	SELECT SUM(sales) AS AftRevenue FROM data_mart.clean_weekly_sales WHERE week_date BETWEEN '2020-06-15' AND '2020-06-15'::DATE+INTERVAL '12 weeks')
	SELECT IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	CROSS JOIN c2

    --How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
--4 weeks period
	WITH c1 AS(SELECT year, SUM(sales) AS IniRevenue 
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN (CONCAT(year,'-06-15')::DATE-INTERVAL'4 weeks')::DATE AND CONCAT(year,'-06-15')::DATE
	GROUP BY 1),
	c2 AS(
	SELECT year,SUM(sales) AS AftRevenue
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN CONCAT(year,'-06-15')::DATE AND (CONCAT(year,'-06-15')::DATE+INTERVAL'4 weeks')::DATE
	GROUP BY 1)
	SELECT c2.year,IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	INNER JOIN c2
	USING(year)
	ORDER BY 1

--12 weeks period
	WITH c1 AS(SELECT year, SUM(sales) AS IniRevenue 
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN (CONCAT(year,'-06-15')::DATE-INTERVAL'12 weeks')::DATE AND CONCAT(year,'-06-15')::DATE
	GROUP BY 1),
	c2 AS(
	SELECT year,SUM(sales) AS AftRevenue
	FROM data_mart.clean_weekly_sales 
	WHERE week_date BETWEEN CONCAT(year,'-06-15')::DATE AND (CONCAT(year,'-06-15')::DATE+INTERVAL'12 weeks')::DATE
	GROUP BY 1)
	SELECT c2.year,IniRevenue, AftRevenue, CONCAT(ROUND(((AftRevenue-IniRevenue)/IniRevenue::NUMERIC)*100,2),'%') AS Growth_Reduction
	FROM c1
	INNER JOIN c2
	USING(year)
	ORDER BY 1
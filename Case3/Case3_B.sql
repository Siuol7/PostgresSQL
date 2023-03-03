--B. Data Analysis Questions
--How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS Number_of_customers 
FROM foodie_fi.subscriptions

--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT EXTRACT(MONTH FROM start_date) AS Month,COUNT(DISTINCT customer_id) AS Distribution
FROM foodie_fi.subscriptions
WHERE plan_id=0
GROUP BY 1



--What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT p.plan_name,COUNT(p.plan_name) AS Quantity
FROM foodie_fi.subscriptions s
INNER JOIN foodie_fi.plans p
USING(plan_id)
WHERE EXTRACT(YEAR FROM s.start_date)::INT>2020
GROUP BY 1

--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT SUM(CASE WHEN plan_name='churn' THEN 1 END) AS Number_of_customers, 
		CONCAT(ROUND(SUM(CASE WHEN plan_name='churn' THEN 1 END)/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)::NUMERIC*100,2),'%') AS Churn_percentage
FROM foodie_fi.subscriptions s
INNER JOIN foodie_fi.plans p
USING(plan_id)


--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
SELECT COUNT(CASE WHEN plan_name='churn' AND row_number=2 THEN 1 END) AS Number_of_customers
FROM (SELECT ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.plan_id),* 
FROM foodie_fi.subscriptions s
INNER JOIN foodie_fi.plans p
USING(plan_id)) a


--What is the number and percentage of customer plans after their initial free trial?
WITH cte AS (SELECT ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.plan_id) AS rn,* 
FROM foodie_fi.subscriptions s
INNER JOIN foodie_fi.plans p
USING(plan_id))
SELECT plan_name,COUNT(customer_id) AS Number_of_customers, CONCAT(ROUND(COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)::NUMERIC*100,2),'%')
FROM cte
WHERE rn>1
GROUP BY plan_name

--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH cte AS ( SELECT *
FROM foodie_fi.subscriptions s 
INNER JOIN foodie_fi."plans" p 
USING(plan_id)
WHERE START_DATE <='2020-12-31')
SELECT c.plan_name, COUNT(c.plan_name), CONCAT(ROUND(COUNT(c.plan_name)/(SELECT COUNT(*) FROM cte)::NUMERIC*100,2),'%')
FROM cte c
GROUP BY 1

--How many customers have upgraded to an annual plan in 2020?
WITH cte AS (SELECT *
FROM foodie_fi.subscriptions s  
INNER JOIN foodie_fi."plans" p 
USING(plan_id)
WHERE EXTRACT(YEAR FROM(START_DATE))='2020' AND (plan_name='trial' OR plan_name LIKE '%annual')
ORDER BY customer_id)
SELECT COUNT(*) AS Number_of_upgraded_customer 
FROM (SELECT customer_id,COUNT(customer_id) AS np FROM cte GROUP BY 1) a WHERE np>1

--How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
	--Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH trial AS (SELECT customer_id, START_DATE 
FROM foodie_fi.subscriptions s  
INNER JOIN foodie_fi."plans" p 
USING(plan_id)
WHERE plan_name='trial'),
annual AS( SELECT customer_id, START_DATE  
FROM foodie_fi.subscriptions s  
INNER JOIN foodie_fi."plans" p 
USING(plan_id)
WHERE plan_name LIKE '%annual')
SELECT CASE
		WHEN ROUND(AVG(a.start_date - t.start_date)) BETWEEN 90 AND 120 THEN '91-120 days'
		END AS average_days
FROM trial t
INNER JOIN annual a 
USING(customer_id)


--How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH basic AS (SELECT customer_id, start_date as b_day
FROM foodie_fi.subscriptions s  
INNER JOIN foodie_fi."plans" p 
USING(plan_id)
WHERE plan_name='basic monthly'),
pro AS( SELECT customer_id, start_date  as p_day
FROM foodie_fi.subscriptions s  
INNER JOIN foodie_fi."plans" p 
USING(plan_id)
WHERE plan_name LIKE 'pro monthly')

SELECT COUNT(*) AS Number_of_downgraded_customers 
FROM BASIC b
INNER JOIN pro p 
ON b.customer_id=p.customer_id  AND p_day<b_day
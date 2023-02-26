--B. Data Analysis Questions
--How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS Number_of_customers 
FROM foodie_fi.subscriptions

--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT CONCAT(EXTRACT (YEAR FROM start_date),'-',EXTRACT(MONTH FROM start_date)),COUNT(DISTINCT customer_id) AS Distribution
FROM foodie_fi.subscriptions
WHERE plan_id=0
GROUP BY 1
--A. Customer Nodes Exploration
--How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS Number_of_unique_nodes FROM data_bank.customer_nodes

--What is the number of nodes per region?
SELECT region_name, COUNT(node_id) AS Number_of_node 
FROM data_bank.regions r
INNER JOIN data_bank.customer_nodes c 
USING(region_id)
GROUP BY 1

--How many customers are allocated to each region?
SELECT region_name, COUNT(DISTINCT customer_id) AS Number_of_customers
FROM data_bank.regions r
INNER JOIN data_bank.customer_nodes c 
USING(region_id)
GROUP BY 1

--How many days on average are customers reallocated to a different node?
WITH cte AS (SELECT *, LAG(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS last_node, LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS last_date
FROM data_bank.customer_nodes c1)

SELECT  ROUND(AVG(start_date-last_date),1) AS Average_days_of_rellocation
FROM cte 
WHERE node_id!=last_node AND last_node IS  NOT NULL

--What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH cte AS (
SELECT *,LAG(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS last_node, 
    LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS last_date
FROM data_bank.customer_nodes c
INNER JOIN data_bank.regions r
USING(region_id)
ORDER BY customer_id)

SELECT region_name, 
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY start_date-last_date) AS median,
		PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY start_date-last_date) AS the_80th,
		PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY start_date-last_date) AS the_90th
FROM cte
WHERE node_id!=last_node AND last_node IS NOT NULL
GROUP BY 1

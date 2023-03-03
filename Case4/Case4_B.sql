--B. Customer Transactions
--What is the unique count and total amount for each transaction type? 
SELECT txn_type, COUNT(DISTINCT customer_id) AS Number_of_customers, COUNT(txn_type) Number_of_txn, SUM(txn_amount) AS Total
FROM data_bank.customer_transactions
GROUP BY 1

--What is the average total historical deposit counts and amounts for all customers?
SELECT COUNT(txn_type)/COUNT(DISTINCT customer_id) AS deposit_counts,
	  SUM(txn_amount)/COUNT(DISTINCT customer_id) AS avg_amounts
FROM data_bank.customer_transactions
WHERE txn_type='deposit'

--For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH cte AS (SELECT CONCAT(EXTRACT(YEAR FROM txn_date)::VARCHAR,'-',EXTRACT(MONTH FROM txn_date)::VARCHAR) AS TIME,customer_id,
		COUNT(CASE WHEN txn_type='deposit' THEN 1 END) AS deposit,
		COUNT(CASE WHEN txn_type='purchase' THEN 1 END) AS purchase,
		COUNT(CASE WHEN txn_type='withdrawal' THEN 1 END) AS withdrawal
FROM data_bank.customer_transactions
GROUP BY 1,2
ORDER BY 2,1)
SELECT COUNT(DISTINCT customer_id) AS Number_of_customers
FROM cte
WHERE deposit>1 AND purchase>1 AND withdrawal>1


--What is the closing balance for each customer at the end of the month?
WITH cte AS (SELECT CONCAT(EXTRACT (YEAR FROM txn_date):: VARCHAR,'-',EXTRACT(MONTH FROM txn_date)::VARCHAR) AS datetime, customer_id,
		CASE
			WHEN txn_type='purchase' OR txn_type='withdrawal' THEN -1*txn_amount
			ELSE txn_amount
		END AS txn_amount
FROM data_bank.customer_transactions)
SELECT datetime,customer_id,SUM(txn_amount) AS balance
FROM cte
GROUP BY 1,2
ORDER BY 1,2


--What is the percentage of customers who increase their closing balance by more than 5%?
WITH cte AS (SELECT CONCAT(EXTRACT (YEAR FROM txn_date):: VARCHAR,'-',EXTRACT(MONTH FROM txn_date)::VARCHAR) AS datetime, customer_id,
		CASE
			WHEN txn_type='purchase' OR txn_type='withdrawal' THEN -1*txn_amount
			ELSE txn_amount
		END AS txn_amount
FROM data_bank.customer_transactions)
cte2 AS (SELECT datetime,customer_id,SUM(txn_amount) AS balance
FROM cte
GROUP BY 1,2
ORDER BY 1,2),
cte3 AS (
SELECT datetime, customer_id, balance, LAG(balance) OVER(PARTITION BY customer_id ORDER BY datetime) AS lastbalance 
FROM cte2)
SELECT datetime,customer_id, balance, lastbalance
FROM cte3
WHERE lastbalance IS NOT NULL AND (lastbalance-balance)/balance*100>5
--Transaction Analysis
	--How many unique transactions were there?
	SELECT count(distinct txn_id) as Number_of_unq_txn
	from balanced_tree.sales

    --What is the average unique products purchased in each transaction?
	WITH cte AS (SELECT txn_id,COUNT(DISTINCT prod_id) AS num_uniq_purchase
	FROM balanced_tree.sales
	GROUP BY 1)
	
	SELECT ROUND(SUM(num_uniq_purchase)/(SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales)) AS avg_unq_purchase
	FROM cte

    --What are the 25th, 50th and 75th percentile values for the revenue per transaction?
	SELECT txn_id, 
			PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY qty*price) AS the_25th_percentile, 
			PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY qty*price) AS the_50th_percentile,
			PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY qty*price) AS the_75th_percentile
	FROM balanced_tree.sales
	GROUP BY 1

    --What is the average discount value per transaction?
	WITH cte AS (SELECT txn_id, SUM(qty*price*discount/100) AS discount
	FROM balanced_tree.sales
	GROUP BY 1)
	SELECT AVG(discount) AS avg_discount FROM cte

    --What is the percentage split of all transactions for members vs non-members?
	SELECT CONCAT(ROUND(COUNT(CASE WHEN member=true THEN 1 END)::NUMERIC/COUNT(*)::NUMERIC * 100,2),'%') AS member_percentage,
			CONCAT(ROUND(COUNT(CASE WHEN member=false THEN 1 END)::NUMERIC/COUNT(*)::NUMERIC * 100,2),'%') AS non_member_percentage
	FROM balanced_tree.sales s

    --What is the average revenue for member transactions and non-member transactions?
	SELECT member, AVG(qty*price) AS avg_revenue
	FROM balanced_tree.sales 
	GROUP BY 1
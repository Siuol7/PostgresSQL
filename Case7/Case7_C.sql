--Product Analysis
--What are the top 3 products by total revenue before discount?
SELECT product_name, SUM(qty*s.price) AS Revenue
FROM balanced_tree.product_details pd
INNER JOIN balanced_tree.sales s
ON pd.product_id=s.prod_id 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3

--What is the total quantity, revenue and discount for each segment?
SELECT level_text AS Segment, SUM(qty) AS Total_quantity, SUM(qty*s.price*(100-s.discount)/100) AS Total_Revenue, SUM(qty*s.price*s.discount/100) AS Total_Discount 
FROM balanced_tree.product_details pd
INNER JOIN balanced_tree.sales s
ON pd.product_id=s.prod_id
INNER JOIN balanced_tree.product_hierarchy ph 
ON pd.segment_id=ph.id
GROUP BY 1

--What is the top selling product for each segment?
WITH cte AS (SELECT ROW_NUMBER() OVER(PARTITION BY level_text ORDER BY SUM(qty*s.price*(100-s.discount)/100) DESC, SUM(qty) DESC) AS rn,
            level_text AS segment, product_name, SUM(qty*s.price*(100-s.discount)/100) AS Total_Sale, SUM(qty) AS Total_Quantity
FROM balanced_tree.sales s
INNER JOIN balanced_tree.product_details pd
ON pd.product_id=s.prod_id
INNER JOIN balanced_tree.product_hierarchy ph 
ON pd.segment_id=ph.id
GROUP BY 2,3)

SELECT segment, product_name, total_sale, total_quantity 
FROM cte 
WHERE rn=1


--What is the total quantity, revenue and discount for each category?
SELECT level_text AS Category, SUM(qty) AS Total_quantity, SUM(qty*s.price*(100-s.discount)/100) AS Total_Revenue, SUM(qty*s.price*s.discount/100) AS Total_Discount 
FROM balanced_tree.product_details pd
INNER JOIN balanced_tree.sales s
ON pd.product_id=s.prod_id
INNER JOIN balanced_tree.product_hierarchy ph 
ON pd.CATEGORY_id=ph.id
GROUP BY 1



--What is the top selling product for each category?
WITH cte AS (SELECT ROW_NUMBER() OVER(PARTITION BY level_text ORDER BY SUM(qty*s.price*(100-s.discount)/100) DESC, SUM(qty) DESC) AS rn,
            level_text AS Category, product_name, SUM(qty*s.price*(100-s.discount)/100) AS Total_Sale, SUM(qty) AS Total_Quantity
FROM balanced_tree.sales s
INNER JOIN balanced_tree.product_details pd
ON pd.product_id=s.prod_id
INNER JOIN balanced_tree.product_hierarchy ph 
ON pd.category_id=ph.id
GROUP BY 2,3)

SELECT category, product_name, total_sale, total_quantity 
FROM cte 
WHERE rn=1


--What is the percentage split of revenue by product for each segment?
SELECT level_text AS segment, SUM(qty*s.price*(100-s.discount)/100) AS Total_revenue,
		CONCAT(ROUND(SUM(qty*s.price*(100-s.discount)/100)::NUMERIC /(SELECT SUM(qty*price*(100-discount)/100) FROM balanced_tree.sales)*100,2),'%') as Percentage
FROM balanced_tree.product_details pd
INNER JOIN balanced_tree.sales s 
ON pd.product_id=s.prod_id
INNER JOIN balanced_tree.product_hierarchy ph 
ON pd.segment_id=ph.id
GROUP BY 1


--What is the percentage split of revenue by segment for each category?
SELECT ph.level_text AS category, ph2.level_text as segment, SUM(qty*s.price*(100-s.discount)/100) AS Total_revenue,
		CONCAT(ROUND(SUM(qty*s.price*(100-s.discount)/100)::NUMERIC /(SELECT SUM(qty*price*(100-discount)/100) FROM balanced_tree.sales)*100,2),'%') as Percentage
FROM balanced_tree.product_details pd
INNER JOIN balanced_tree.sales s 
ON pd.product_id=s.prod_id
INNER JOIN balanced_tree.product_hierarchy ph 
ON pd.category_id=ph.id
INNER JOIN balanced_tree.product_hierarchy ph2
ON pd.segment_id=ph2.id
GROUP BY 1,2

--What is the percentage split of total revenue by category?
SELECT level_text AS category, SUM(qty*s.price*(100-s.discount)/100) AS Total_revenue,
		CONCAT(ROUND(SUM(qty*s.price*(100-s.discount)/100)::NUMERIC /(SELECT SUM(qty*price*(100-discount)/100) FROM balanced_tree.sales)*100,2),'%') as Percentage
FROM balanced_tree.product_details pd
INNER JOIN balanced_tree.sales s 
ON pd.product_id=s.prod_id
INNER JOIN balanced_tree.product_hierarchy ph 
ON pd.category_id=ph.id
GROUP BY 1

--What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
SELECT pd.product_name, 
		CONCAT(ROUND(COUNT( DISTINCT s.txn_id)/(SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales)::NUMERIC*100,2),'%') AS Penetration_Percent
FROM balanced_tree.sales s
INNER JOIN balanced_tree.product_details pd
ON pd.product_id=s.prod_id
GROUP BY 1

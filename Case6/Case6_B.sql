--3. Product Funnel Analysis
--Using a single SQL query - create a new output table which has the following details:

	--How many times was each product viewed?
    --How many times was each product added to cart?
    --How many times was each product added to a cart but not purchased (abandoned)?
    --How many times was each product purchased?

WITH c1 AS(	SELECT page_name,COUNT(CASE WHEN event_type=2 THEN 1 END) AS Total_times_purchase
			FROM clique_bait.events e 
			INNER JOIN clique_bait.event_identifier ei 
			USING(event_type)
			INNER JOIN clique_bait.page_hierarchy ph 
			USING(page_id)
			WHERE visit_id IN (SELECT visit_id FROM clique_bait.events e2  WHERE event_type=3) and page_name NOT IN ('All Products','Checkout','Home Page','Confirmation')
			group by 1
			order by 1),
	c2 AS (SELECT page_name,COUNT(CASE WHEN event_type=2 THEN 1 END) AS Total_times_no_purchase
			FROM clique_bait.events e 
			INNER JOIN clique_bait.event_identifier ei 
			USING(event_type)
			INNER JOIN clique_bait.page_hierarchy ph 
			USING(page_id)
			WHERE visit_id not IN (SELECT visit_id FROM clique_bait.events e2  WHERE event_type=3) and page_name NOT IN ('All Products','Checkout','Home Page','Confirmation')
			group by 1
			order by 1),
	c3 AS (SELECT  ph.page_name, COUNT(CASE WHEN ei.event_name='Page View' THEN 1 END) AS Total_View,COUNT(CASE WHEN ei.event_name='Add to Cart' THEN 1 END) AS Total_AtC
			FROM clique_bait.events e 
			INNER  JOIN clique_bait.event_identifier ei 
			USING(event_type)
			INNER JOIN clique_bait.page_hierarchy ph 
			USING(page_id)
			WHERE page_name NOT IN ('All Products','Checkout','Home Page','Confirmation')
			GROUP BY 1
			order by 1)
	
	SELECT c1.page_name,c3.Total_View,c3.Total_AtC, c1.Total_times_purchase, c2.Total_times_no_purchase
	FROM c1
    INTO clique_bait.Product_table
	INNER JOIN c2
	USING(page_name)
	INNER JOIN c3
	USING(page_name)

    	--Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
			--How many times was each product category viewed?
			--How many times was each product category added to cart?		
			--How many times was each product category added to a cart but not purchased (abandoned)?
			--How many times was each product category purchased?
				
   
WITH c1 AS(	SELECT product_category,COUNT(CASE WHEN event_type=2 THEN 1 END) AS Total_times_purchase
			FROM clique_bait.events e 
			INNER JOIN clique_bait.event_identifier ei 
			USING(event_type)
			INNER JOIN clique_bait.page_hierarchy ph 
			USING(page_id)
			WHERE visit_id IN (SELECT visit_id FROM clique_bait.events e2  WHERE event_type=3) and product_category IS NOT NULL
			group by 1
			order by 1),
	c2 AS (SELECT product_category,COUNT(CASE WHEN event_type=2 THEN 1 END) AS Total_times_no_purchase
			FROM clique_bait.events e 
			INNER JOIN clique_bait.event_identifier ei 
			USING(event_type)
			INNER JOIN clique_bait.page_hierarchy ph 
			USING(page_id)
			WHERE visit_id not IN (SELECT visit_id FROM clique_bait.events e2  WHERE event_type=3) and product_category IS NOT NULL
			group by 1
			order by 1),
	c3 AS (SELECT  product_category, COUNT(CASE WHEN ei.event_name='Page View' THEN 1 END) AS Total_View,COUNT(CASE WHEN ei.event_name='Add to Cart' THEN 1 END) AS Total_AtC
			FROM clique_bait.events e 
			INNER  JOIN clique_bait.event_identifier ei 
			USING(event_type)
			INNER JOIN clique_bait.page_hierarchy ph 
			USING(page_id)
			WHERE product_category IS NOT NULL
			GROUP BY 1
			order by 1)
	
	SELECT c1.product_category,c3.Total_View,c3.Total_AtC, c1.Total_times_purchase, c2.Total_times_no_purchase
    INTO clique_bait.Category_table 
	FROM c1
	INNER JOIN c2
	USING(product_category)
	INNER JOIN c3
	USING(product_category)


--Use your 2 new output tables - answer the following questions:

	--Which product had the most views, cart adds and purchases? 
		--View
		SELECT page_name AS product, total_view
		FROM clique_bait.Product_table
		ORDER BY total_view DESC
		LIMIT 1
		
		--Card adds
		SELECT page_name AS product, total_atc 
		FROM clique_bait.Product_table
		ORDER BY 2 DESC 
		LIMIT 1
		
		--Purchases
		SELECT page_name AS product, total_times_purchase 
		FROM clique_bait.Product_table
		ORDER BY 2 DESC 
		LIMIT 1


    --Which product was most likely to be abandoned?
	SELECT page_name AS product, total_times_no_purchase
	FROM clique_bait.Product_table
	ORDER BY 2 DESC 
	LIMIT 1		

    --Which product had the highest view to purchase percentage?
	SELECT page_name AS product, CONCAT(ROUND(total_times_purchase::NUMERIC/total_view::NUMERIC*100,2),'%')
	FROM clique_bait.Product_table
	ORDER BY 2 DESC 
	LIMIT 1

    --What is the average conversion rate from view to cart add?
	SELECT  CONCAT(ROUND(SUM(total_atc)::NUMERIC/SUM(total_view)::NUMERIC*100,2),'%') AS Avg_View_to_AtC
	FROM clique_bait.Product_table

    
	--What is the average conversion rate from cart add to purchase?
	SELECT CONCAT(ROUND(SUM(total_times_purchase)::NUMERIC/SUM(total_atc)::NUMERIC*100,2),'%')
	FROM clique_bait.Product_table


--2. Digital Analysis
--Using the available datasets - answer the following questions using a single query for each one:

	--How many users are there?
	SELECT COUNT(DISTINCT user_id) AS Number_of_user
	FROM clique_bait.users

    --How many cookies does each user have on average?
	SELECT COUNT(cookie_id)/(SELECT COUNT(distinct user_id)  FROM clique_bait.users) AS Average_cookies_per_user 
	FROM clique_bait.users 

    --What is the unique number of visits by all users per month?
	SELECT EXTRACT (YEAR FROM event_time) AS year, EXTRACT(MONTH FROM event_time) AS month, COUNT(DISTINCT visit_id) AS Number_of_visit
	FROM clique_bait.users
	INNER JOIN clique_bait.events
	USING(cookie_id)
	GROUP BY 1,2

    --What is the number of events for each event type?
	SELECT event_type, COUNT(event_type) AS Number
	FROM clique_bait.events
	GROUP BY 1
	ORDER BY 1

    --What is the percentage of visits which have a purchase event?
	SELECT CONCAT(ROUND(COUNT(CASE WHEN event_name='Purchase' THEN 1 END)/COUNT(*)::NUMERIC*100,2),'%') AS Purchase_Percent
	FROM clique_bait.events
	INNER JOIN clique_bait.event_identifier
	USING(event_type)


    --What is the percentage of visits which view the checkout page but do not have a purchase event?
	WITH cte AS (SELECT visit_id, COUNT (DISTINCT event_name) AS cnt
	FROM clique_bait.events
	INNER JOIN clique_bait.event_identifier
	USING(event_type)
	WHERE event_name='Page View' OR event_name='Purchase'
	GROUP BY 1)
	
	SELECT CONCAT(ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(visit_id) FROM clique_bait.events)::NUMERIC*100,2),'%') AS View_Percent
	FROM cte

	--What are the top 3 pages by number of views?
	SELECT  ph.page_name, COUNT(CASE WHEN ei.event_name='Page View' THEN 1 END) AS Total_View
	FROM clique_bait.events e 
	INNER  JOIN clique_bait.event_identifier ei 
	USING(event_type)
	INNER JOIN clique_bait.page_hierarchy ph 
	USING(page_id)
	GROUP BY 1
	ORDER BY 2 DESC 
	LIMIT 3

	--What is the number of views and cart adds for each product category?
	SELECT  ph.product_category , COUNT(CASE WHEN ei.event_name='Page View'THEN 1 END) AS Total_View
								, COUNT(CASE WHEN ei.event_name='Add to Cart' THEN 1 END) AS Total_AC
	FROM clique_bait.events e 
	INNER  JOIN clique_bait.event_identifier ei 
	USING(event_type)
	INNER JOIN clique_bait.page_hierarchy ph 
	USING(page_id)
	WHERE ph.product_category IS NOT NULL
	GROUP BY 1

	--What are the top 3 products by purchases?
	WITH cte AS (
		SELECT visit_id,
		       page_id,
		       page_name,
		       event_type,
		       event_name
		  FROM clique_bait.events
		  INNER JOIN clique_bait.page_hierarchy
		 USING (page_id)
		  INNER JOIN clique_bait.event_identifier
		 USING (event_type)
		 WHERE visit_id IN (SELECT visit_id FROM clique_bait.events WHERE event_type = 3)
	      GROUP BY 1,2,3,4,5,event_time
	      ORDER BY visit_id)
	
	  SELECT page_name,
	         COUNT(event_name) AS purchases
	    FROM cte 
	   WHERE event_type = 2
	GROUP BY page_name
	ORDER BY purchases DESC
	   LIMIT 3;
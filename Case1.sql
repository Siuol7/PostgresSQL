CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  
  
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Example Query:

#1
SELECT
  	customer_id,SUM(price) AS total
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
USING (product_id)
GROUP BY 1

#2
SELECT customer_id,COUNT( DISTINCT DATE(order_date)) AS visits
FROM dannys_diner.sales
GROUP BY 1

#3
SELECT m.customer_id,n.product_name 
FROM (SELECT customer_id,order_date,product_id, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS seq
FROM dannys_diner.sales) m
INNER JOIN dannys_diner.menu n
USING(product_id)
WHERE m.seq =1

#4
SELECT m.product_id,COUNT(m.product_id) as numbers, n.product_name
FROM dannys_diner.sales m
INNER JOIN dannys_diner.menu as n
USING(product_id)
GROUP BY 1,3

#5
SELECT m.customer_id,n.product_name
FROM(
SELECT customer_id,product_id,DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS rnk
FROM dannys_diner.sales
GROUP BY 1,2) m
INNER JOIN dannys_diner.menu n
USING(product_id)
WHERE rnk=1
ORDER BY 1

#6
WITH cte AS (SELECT m.customer_id,m.order_date,m.product_id,n.product_name,ROW_NUMBER() OVER(PARTITION BY m.customer_id ORDER BY m.order_date ASC) AS rnk
FROM dannys_diner.sales m
INNER JOIN dannys_diner.members o
ON m.customer_id=o.customer_id AND m.order_date>o.join_date
INNER JOIN dannys_diner.menu n
USING(product_id))
SELECT customer_id,order_date,product_id,product_name FROM cte
WHERE rnk=1

#7
WITH cte AS (SELECT m.customer_id,m.order_date,m.product_id,n.product_name,ROW_NUMBER() OVER(PARTITION BY m.customer_id ORDER BY m.order_date DESC) AS rnk
FROM dannys_diner.sales m
INNER JOIN dannys_diner.members o
ON m.customer_id=o.customer_id AND m.order_date<o.join_date
INNER JOIN dannys_diner.menu n
USING(product_id))
SELECT customer_id,order_date,product_id,product_name FROM cte
WHERE rnk=1

#8
WITH cte AS (SELECT m.customer_id,m.order_date,m.product_id,n.product_name,n.price,ROW_NUMBER() OVER(PARTITION BY m.customer_id ORDER BY m.order_date DESC) AS rnk
FROM dannys_diner.sales m
INNER JOIN dannys_diner.members o
ON m.customer_id=o.customer_id AND m.order_date<o.join_date
INNER JOIN dannys_diner.menu n
USING(product_id))
SELECT customer_id, SUM(price) AS Total 
FROM cte
GROUP BY 1
ORDER BY 1


#9
WITH cte AS(SELECT m.customer_id,
		CASE
        	WHEN n.product_name='sushi' THEN n.price*20
            ELSE n.price*10
        END AS point
FROM dannys_diner.sales m
INNER JOIN dannys_diner.menu n
USING(product_id))
SELECT customer_id,SUM(point) AS Total_Points 
FROM cte 
GROUP BY 1
ORDER BY 1


#10
WITH cte AS (SELECT m.customer_id,
			CASE
            	WHEN n.product_name='sushi' THEN n.price*20
                WHEN m.customer_id=o.customer_id AND m.order_date > o.join_date AND m.order_date < o.join_date+ INTERVAL'8 days' THEN n.price*20
                ELSE n.price*10
           END AS points
FROM dannys_diner.sales m
INNER JOIN dannys_diner.menu n
USING (product_id)
INNER JOIN dannys_diner.members o
USING(customer_id)
WHERE EXTRACT(MONTH FROM m.order_date)<2)

SELECT customer_id, SUM(points) AS Total_points
FROM cte
GROUP BY 1
ORDER BY 1

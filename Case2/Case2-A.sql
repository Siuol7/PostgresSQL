
--A. Pizza Metrics
--1.How many pizzas were ordered?
SELECT COUNT(*) AS Total_ordered_pizzas
FROM pizza_runner.customer_orders

--2.How many unique customer orders were made?
SELECT COUNT( DISTINCT customer_id) AS Number_of_Unique_Customer 
FROM pizza_runner.customer_orders

--3.How many successful orders were delivered by each runner?
SELECT runner_id,COUNT(pickup_time) AS Number_of_successful_order 
FROM pizza_runner.runner_orders
WHERE cancellation IS  NULL
GROUP BY 1
ORDER BY 1

--4.How many of each type of pizza was delivered?
SELECT c.pizza_id,count(c.pizza_id) AS Number_of_pizza 
FROM pizza_runner.customer_orders c
INNER JOIN pizza_runner.runner_orders r
USING (order_id)
WHERE r.cancellation IS NULL
GROUP BY 1

--5.How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, n.pizza_name, COUNT(n.pizza_name) AS Number_of_ordered_pizza
FROM pizza_runner.customer_orders c
INNER JOIN pizza_runner.pizza_names n
USING(pizza_id)
GROUP BY 1, 2
ORDER BY 1


--6.What was the maximum number of pizzas delivered in a single order?
SELECT c.order_id, COUNT(c.order_id) AS Number_of_delivered_pizza
FROM pizza_runner.customer_orders c
INNER JOIN pizza_runner.runner_orders r
USING (order_id)
WHERE r.cancellation IS NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT COUNT(CASE WHEN c.exclusions IS NULL and c.extras IS NULL THEN 1 END) AS At_least_1_change,
		COUNT(CASE WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1 END) AS No_change
FROM pizza_runner.customer_orders c
INNER JOIN pizza_runner.runner_orders r
USING (order_id)
WHERE r.cancellation IS NULL

--8.How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(CASE WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1 END) AS both_changes
FROM pizza_runner.customer_orders c
INNER JOIN pizza_runner.runner_orders r
USING (order_id)
WHERE r.cancellation IS NULL

--9.What was the total volume of pizzas ordered for each hour of the day?
SELECT DATE(order_time) AS DATE_TIME,EXTRACT(HOUR FROM order_time) AS Hours, COUNT(pizza_id) as Total_Number_of_Pizza
FROM pizza_runner.customer_orders
GROUP BY 2
ORDER BY 1


--10.What was the volume of orders for each day of the week?
SELECT EXTRACT(YEAR FROM order_time) AS Year,
		EXTRACT(WEEK FROM order_time) AS week,
        COUNT(pizza_id) AS Total_Volume
FROM  pizza_runner.customer_orders
GROUP BY 1,2
ORDER BY 1,2

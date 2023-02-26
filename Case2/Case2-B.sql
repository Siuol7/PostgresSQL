--B. Runner and Customer Experience
--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT EXTRACT(YEAR FROM  registration_date)::VARCHAR AS year, 
		extract(WEEK FROM registration_date):: VARCHAR AS week,
		COUNT(distinct runner_id) AS Number_of_runner
FROM runners 
GROUP BY 1,2
ORDER BY 1,2

--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT r.runner_id, 
		ROUND(AVG(extract(EPOCH FROM (to_timestamp(r.pickup_time,'YYYY-MM-DD HH24:MI:SS')-c.order_time)/60))) AS Average_time_min
FROM customer_orders c
INNER JOIN runner_orders r 
USING (order_id)
WHERE r.cancellation IS NULL
GROUP BY 1
ORDER BY 1


--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH cte AS (SELECT r.order_id, count(c.pizza_id) AS number_of_pizza,
		ROUND(AVG(EXTRACT(EPOCH FROM (to_timestamp(r.pickup_time,'YYYY_MM_DD HH24:MI:SS')-c.order_time))/60)) AS prepare_time
FROM customer_orders c
INNER JOIN runner_orders r 
USING (order_id)
WHERE r.cancellation IS NULL
GROUP BY 1
ORDER BY 1)
SELECT CORR(number_of_pizza,prepare_time) AS relationship FROM cte
--pvalue is approximately 0.85 which describes a pretty strong relationship. The more pizzas are ordered, the longer preparation time is

--4.What was the average distance travelled for each customer?
SELECT c.customer_id, round(avg(r.distance)::NUMERIC,2) AS Average_distance
FROM customer_orders c
INNER JOIN runner_orders r 
USING (order_id)
WHERE r.cancellation IS NULL
GROUP BY 1
ORDER BY 1
--Note that data is transformed


--5.What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration)-MIN(duration) AS Difference_of_Max_and_Min_Duration
FROM runner_orders
--Note that data is transformed


--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

WITH cte AS (SELECT c.order_id, r.runner_id, COUNT(c.order_id) AS No_pizzas, r.distance, r.duration, round((r.distance/r.duration*60) :: NUMERIC,2) AS velocity_km_h
FROM customer_orders c
INNER JOIN runner_orders r 
USING (order_id)
WHERE r.cancellation IS NULL
GROUP BY 1,2,r.distance, r.duration
ORDER BY 1)

SELECT *, dense_rank () OVER(PARTITION BY runner_id ORDER BY velocity_km_h) FROM cte
--Comparison of different delivery of each runner

SELECT corr(no_pizzas,velocity_km_h) AS rela1, corr(distance,velocity_km_h) AS rela2 FROM cte
-- There is no precise relationship between the calculated value


--7.What is the successful delivery percentage for each runner?

SELECT runner_id,
		COUNT(CASE WHEN cancellation IS NULL THEN 1 END)/COUNT(*)::NUMERIC *100 AS Succesful_delivery_percent
FROM runner_orders 
GROUP BY runner_id
ORDER BY runner_id


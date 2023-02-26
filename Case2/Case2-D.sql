--D. Pricing and Ratings
--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT SUM(CASE WHEN c.pizza_id=1 THEN 12 ELSE 10 END) AS Total
FROM customer_orders c 
INNER JOIN runner_orders r 
USING(order_id) 
WHERE r.cancellation IS NULL


--What if there was an additional $1 charge for any pizza extras?
	--Add cheese is $1 extra
WITH c1 AS( SELECT SUM(CASE WHEN c.pizza_id=1 THEN 12 ELSE 10 END) AS Total
FROM customer_orders c 
INNER JOIN runner_orders r 
USING(order_id) 
WHERE r.cancellation IS NULL),
c2 AS (
SELECT SUM(CASE WHEN t.topping_name='Cheese' THEN 2 ELSE 1 END) AS Total
FROM(SELECT order_id, UNNEST(STRING_TO_ARRAY(extras,','))::INT AS extras FROM customer_orders) a
INNER JOIN pizza_toppings t 
ON a.extras=t.topping_id)

SELECT (SELECT Total FROM c1)+(SELECT Total FROM c2)


--The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset
	-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS runner_rating;

CREATE TABLE runner_rating
("order_id" INTEGER,
	"runner_id" INTEGER,
	"rating" INTEGER);
	
INSERT INTO runner_rating
	("order_id","runner_id","rating")
VALUES
	(1,1,5),
	(2,1,5),
	(3,1,5),
	(4,2,5),
	(5,3,5),
	(6,3,1),
	(7,2,5),
	(8,2,5),
	(9,2,1),
	(10,1,5)


--Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
		--customer_id
		--order_id
		--runner_id
		--rating
		--order_time
		--pickup_time
		--Time between order and pickup
		--Delivery duration
		--Average speed
		--Total number of pizzas
SELECT c.customer_id,rr.order_id,rr.runner_id,rr.rating,c.order_time,ro.pickup_time,
		ROUND(EXTRACT(EPOCH FROM (TO_TIMESTAMP(ro.pickup_time,'YYYY-MM-DD HH24:MI:SS')-c.order_time)/60)::NUMERIC,2) AS Time_between_order_pickup_min,
		ROUND(AVG(ro.distance/ro.duration)::NUMERIC ,2) AS Average_speed,
		COUNT(c.pizza_id) AS Total_Pizza
FROM customer_orders c
INNER JOIN runner_orders ro 
USING(order_id)
INNER JOIN runner_rating rr 
USING(order_id)
WHERE ro.cancellation IS NULL
GROUP BY 1,2,3,4,5,6
ORDER BY 2


--If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

SELECT SUM(CASE WHEN c.pizza_id=1 THEN 12 ELSE 10 END) -SUM(r.distance)*0.30 AS Left_Over
FROM customer_orders c 
INNER JOIN runner_orders r 
USING(order_id) 
WHERE r.cancellation IS NULL
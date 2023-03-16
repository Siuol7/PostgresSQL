--C. Ingredient Optimisation
--What are the standard ingredients for each pizza?
WITH cte AS( SELECT pizza_id,UNNEST(STRING_TO_ARRAY(toppings,','))::INT AS topping_id FROM pizza_recipes )
SELECT c.pizza_id, ARRAY_TO_STRING(ARRAY_AGG(topping_name),', ') AS Toppings
FROM cte c
INNER JOIN pizza_toppings t
USING (topping_id)
GROUP BY 1

--What was the most commonly added extra?
WITH cte AS (SELECT UNNEST(STRING_TO_ARRAY(extras,',')):: INT AS topping_id FROM customer_orders)
SELECT t.topping_name, COUNT(topping_name) AS Total 
FROM cte c
INNER JOIN pizza_toppings t 
USING(topping_id)
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 1

--What was the most common exclusion?
WITH cte AS(SELECT UNNEST(STRING_TO_ARRAY(exclusions,','))::INT AS topping_id FROM customer_orders)
SELECT t.topping_name, COUNT(t.topping_name) AS total 
FROM cte c
INNER JOIN pizza_toppings t 
USING (topping_id)
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 1


--Generate an order item for each record in the customers_orders table in the format of one of the following:
	--Meat Lovers
	--Meat Lovers - Exclude Beef
	--Meat Lovers - Extra Bacon
	--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH c1 AS (
SELECT ROW_NUMBER() OVER(ORDER BY order_id) AS id, *
FROM (SELECT * FROM customer_orders ORDER BY order_id) a
INNER JOIN pizza_names
USING(pizza_id)),

c2 AS(
SELECT *, UNNEST(STRING_TO_ARRAY(exclusions,',')) :: INT AS topping1, UNNEST(STRING_TO_ARRAY(extras,',')) :: INT AS topping2 FROM c1),

c3 AS (
SELECT c2.id, c2.order_id, c2.customer_id, c2.pizza_id,c2.exclusions, c2.extras, c2.order_time, ARRAY_TO_STRING(ARRAY_AGG(t.topping_name),', ') AS excl
FROM c2 
INNER JOIN pizza_toppings t 
ON c2.topping1=t.topping_id
GROUP BY 1,2,3,4,5,6,7),

c4 AS(
SELECT c2.id, c2.order_id, c2.customer_id, c2.pizza_id, c2.exclusions, c2.extras, c2.order_time, ARRAY_TO_STRING(ARRAY_AGG(t.topping_name),', ') AS extr
FROM c2
INNER JOIN pizza_toppings t 
ON c2.topping2=t.topping_id
GROUP BY 1,2,3,4,5,6,7) ,

c5 AS (
SELECT c1.id, c1.order_id, c1.customer_id, c1.pizza_id, c1.exclusions, c1.extras, c1.order_time, c1.pizza_name, c3.excl, c4.extr
FROM c1 
LEFT JOIN c3
USING(id)
LEFT JOIN c4
USING(id))

SELECT c5.id, c5.order_id, c5.customer_id, c5.pizza_id, c5.exclusions, c5.extras, c5.order_time, 
		CASE
			WHEN c5.excl IS NULL AND c5.extr IS NULL THEN c5.pizza_name
			WHEN c5.excl IS NOT NULL AND c5.extr IS NULL THEN CONCAT(c5.pizza_name,'- Exclude ',c5.excl)
			when c5.excl IS NULL AND c5.extr IS NOT NULL THEN CONCAT(c5.pizza_name,'- Extra ',c5.extr)
			ELSE CONCAT(c5.pizza_name,'- Exlude', c5.excl,'- Extra', c5.extr)
		END AS Order_item
FROM c5




--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
		--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH main AS(SELECT ROW_NUMBER() OVER(order by order_id) AS id, * FROM customer_orders ORDER BY order_id),



c1 AS(SELECT  *, UNNEST(STRING_TO_ARRAY(CONCAT(pr.toppings,', ', a.extras),',')) ::INT AS ingre
FROM  main a
INNER JOIN pizza_names pn
USING(pizza_id)
INNER JOIN  pizza_recipes pr
USING(pizza_id)
WHERE a.extras IS NOT NULL),

c2 AS(
SELECT id,pizza_id, order_id, customer_id, exclusions, extras, order_time, pizza_name, t.topping_name,CONCAT(COUNT(t.topping_name)::VARCHAR,'x') AS ingre
FROM c1 
INNER JOIN pizza_toppings t
ON c1.ingre=t.topping_id
GROUP BY  1,2,3,4,5,6,7,8,9
ORDER BY id) ,

c3 AS(
SELECT id, pizza_id, order_id,customer_id,extras,order_time,pizza_name,topping_name,
				CASE 
					WHEN ingre!='1x' THEN CONCAT(ingre,topping_name)
					ELSE topping_name
				END AS ingredients
FROM c2
GROUP BY 1,2,3,4,5,6,7,8,ingre),

c4 AS(
SELECT id, pizza_id, order_id, customer_id, order_time, CONCAT(pizza_name,': ',ARRAY_TO_STRING(ARRAY_AGG(ingredients),', ')) AS Order_Ingredients
FROM c3
GROUP BY 1,2,3,4,5,pizza_name),

n1 AS(
SELECT *, UNNEST(STRING_TO_ARRAY(pr.toppings,',')) ::INT AS ingre
FROM main a
INNER JOIN pizza_names pn
USING(pizza_id)
INNER JOIN  pizza_recipes pr
USING(pizza_id)
WHERE a.extras IS NULL),

n2 AS(
SELECT n1.id, n1.pizza_id, n1.order_id, n1.customer_id, n1.order_time, CONCAT(n1.pizza_name,': ',ARRAY_TO_STRING(ARRAY_AGG(t.topping_name),', ')) AS Order_Ingredients
FROM n1
INNER JOIN pizza_toppings t 
ON n1.ingre=t.topping_id
GROUP BY 1,2,3,4,5,n1.pizza_name)

SELECT * FROM c4
UNION ALL
SELECT * FROM n2
ORDER BY id



--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH main AS(
SELECT c.order_id, c.pizza_id, c.customer_id, c.exclusions, c.extras,c.order_time,pr.toppings
FROM customer_orders c
INNER JOIN runner_orders r 
USING(order_id)
INNER JOIN pizza_recipes pr 
USING(pizza_id)
WHERE r.cancellation IS NULL),

exc1 AS (
SELECT UNNEST(STRING_TO_ARRAY(m.exclusions,',')) :: INT AS topping_id 
FROM main m),

exc2 AS(
SELECT t.topping_name, COUNT(t.topping_name) AS Exc_Quantity
FROM exc1 
INNER JOIN pizza_toppings t 
USING(topping_id)
GROUP BY 1),

ext1 AS(
SELECT UNNEST(STRING_TO_ARRAY(m.extras,',')):: INT AS topping_id
FROM main m),

ext2 AS (
SELECT t.topping_name, COUNT(t.topping_name) AS Ext_Quantity
FROM ext1
INNER JOIN pizza_toppings t 
USING(topping_id)
GROUP BY 1),

main1 AS (
SELECT UNNEST(STRING_TO_ARRAY(toppings,',')):: INT AS topping_id FROM main ),

main2 AS(
SELECT t.topping_name, COUNT(t.topping_name) AS Main_Quantity
FROM main1
INNER JOIN pizza_toppings t 
USING (topping_id)
GROUP BY 1)

SELECT m.topping_name AS Ingredients, m.Main_Quantity+ COALESCE (ext.Ext_Quantity,0)-COALESCE (exc.Exc_Quantity,0) AS Total_Quantity
FROM main2 m
LEFT JOIN ext2 ext
USING(topping_name)
LEFT JOIN exc2 exc
USING (topping_name)


--What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
WITH cte AS (SELECT txn_id,prod_id,product_name 
FROM balanced_tree.sales s
INNER JOIN balanced_tree.product_details pd
ON pd.product_id=s.prod_id
ORDER BY 1,2)

SELECT c1.product_name,c2.product_name,c3.product_name,COUNT(c1.txn_id) AS Number_txn
FROM cte c1
INNER JOIN cte c2
ON c1.txn_id=c2.txn_id AND c1.prod_id<c2.prod_id
INNER JOIN cte c3
ON c2.txn_id=c3.txn_id AND c2.prod_id<c3.prod_id
GROUP BY 1,2,3
ORDER BY 4 DESC 
LIMIT 1





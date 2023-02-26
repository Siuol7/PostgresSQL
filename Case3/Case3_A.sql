--A. Customer Journey
--Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

--Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
WITH cte AS (SELECT s.customer_id, s.plan_id, p.plan_name, p.price, s.start_date
FROM foodie_fi.subscriptions s
INNER JOIN foodie_fi.plans p
USING(plan_id)
ORDER BY customer_id,plan_id)



--Customer 1
SELECT * FROM cte WHERE customer_id=1
--Customer 2
SELECT * FROM cte WHERE customer_id=2
--Customer 11
SELECT * FROM cte WHERE customer_id=11
--Customer 13
SELECT * FROM cte WHERE customer_id=13
--Customer 15
SELECT * FROM cte WHERE customer_id=15
--Customer 16
SELECT * FROM cte WHERE customer_id=16
--Customer 18
SELECT * FROM cte WHERE customer_id=18
--Customer 19
SELECT * FROM cte WHERE customer_id=19
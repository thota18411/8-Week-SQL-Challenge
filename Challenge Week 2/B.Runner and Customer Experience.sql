--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)--
SELECT to_char(registration_date, 'week')  as week   ,                       
      COUNT(to_char(registration_date, 'week'))   as sum_regis
FROM pizza_runner.runners
GROUP BY 1

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?--
WITH t1 AS (SELECT order_id,runner_id, (pickup_time - order_time) as thgian
FROM customer_orders_cleaned
JOIN runner_orders_cleaned
USING(order_id)
WHERE cancellation IS NULL)

SELECT runner_id, AVG(thgian)
FROM t1
GROUP BY 1

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?-- 
--Updatting--

--4.Is there any relationship between the number of pizzas and how long the order takes to prepare?--
SELECT customer_id, ROUND(AVG(distance),2)
FROM runner_orders_cleaned
JOIN customer_orders_cleaned
USING (order_id)
WHERE cancellation is null
GROUP BY customer_id

--5. What was the difference between the longest and shortest delivery times for all orders?--
WITH t1 AS (SELECT MAX(duration) as longest_deli
,MIN(duration) as shortest_deli
FROM runner_orders_cleaned)

SELECT longest_deli-shortest_deli AS distance
FROM t1

--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?--
SELECT order_id,runner_id, AVG (distance/duration)
FROM runner_orders_cleaned
GROUP BY runner_id,order_id
ORDER BY order_id,runner_id

--7. What is the successful delivery percentage for each runner?--
WITH t1 AS
(SELECT runner_id, COUNT(runner_id) as b
FROM pizza_runner.runner_orders
WHERE cancellation is not null
GROUP BY runner_id
)
,t2 AS (SELECT runner_id, COUNT(runner_id) as d
FROM pizza_runner.runner_orders
GROUP BY runner_id
)

SELECT runner_id,b/d as percet
FROM t1 JOIN t2 USING (runner_id)




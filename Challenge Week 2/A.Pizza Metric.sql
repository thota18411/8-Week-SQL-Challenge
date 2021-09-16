--1. How many pizzas were ordered?--
SELECT
COUNT (order_id) as total_pizzas
FROM pizza_runner.customer_orders

--2.How many unique customer orders were made?--
SELECT
COUNT (DISTINCT customer_id)
FROM pizza_runner.customer_orders

--3.How many successful orders were delivered by each runner?--
DROP TABLE IF EXISTS customer_orders_cleaned;
    CREATE TEMP TABLE customer_orders_cleaned AS WITH first_layer AS (
      SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE
          WHEN exclusions = '' THEN NULL
          WHEN exclusions = 'null' THEN NULL
          ELSE exclusions
        END as exclusions,
        CASE
          WHEN extras = '' THEN NULL
          WHEN extras = 'null' THEN NULL
          ELSE extras
        END as extras,
        order_time
      FROM
        pizza_runner.customer_orders
    )
    SELECT
      ROW_NUMBER() OVER (      -- We are adding a row_number rank to deal with orders having multiple times the same pizza in it
        ORDER BY
          order_id,
          pizza_id
      ) AS row_number_order,
      order_id,
      customer_id,
      pizza_id,
      exclusions,
      extras,
      order_time
    FROM
      first_layer;

---


    DROP TABLE IF EXISTS runner_orders_cleaned;
    CREATE TEMP TABLE runner_orders_cleaned AS WITH first_layer AS (
      SELECT
        order_id,
        runner_id,
        CAST(
          CASE
            WHEN pickup_time = 'null' THEN NULL
            ELSE pickup_time
          END AS timestamp
        ) AS pickup_time,
        CASE
          WHEN distance = '' THEN NULL
          WHEN distance = 'null' THEN NULL
          ELSE distance
        END as distance,
        CASE
          WHEN duration = '' THEN NULL
          WHEN duration = 'null' THEN NULL
          ELSE duration
        END as duration,
        CASE
          WHEN cancellation = '' THEN NULL
          WHEN cancellation = 'null' THEN NULL
          ELSE cancellation
        END as cancellation
      FROM
        pizza_runner.runner_orders
    )
    SELECT
      order_id,
      runner_id,
      CASE WHEN order_id = '3' THEN (pickup_time + INTERVAL '13 hour') ELSE pickup_time END AS pickup_time,
      CAST( regexp_replace(distance, '[a-z]+', '' ) AS DECIMAL(5,2) ) AS distance,
    	CAST( regexp_replace(duration, '[a-z]+', '' ) AS INT ) AS duration,
    	cancellation
    FROM
      first_layer;
----------------------------------------------
SELECT runner_id, COUNT(order_id)
FROM runner_orders_cleaned
WHERE cancellation is null
GROUP BY runner_id

-- 4. How many of each type of pizza was delivered?--
SELECT pizza_id, COUNT(pizza_id)
FROM runner_orders_cleaned
JOIN customer_orders_cleaned
USING (order_id)
WHERE cancellation is null
GROUP BY pizza_id

--5. How many Vegetarian and Meatlovers were ordered by each customer?--
SELECT customer_id,
SUM (CASE WHEN pizza_id=1 THEN 1 ELSE 0 END) as meatlovers,
SUM(CASE WHEN pizza_id=2 THEN 1 ELSE 0 END) as vegetarians
FROM customer_orders_cleaned
GROUP BY customer_id

--6. What was the maximum number of pizzas delivered in a single order?--
SELECT order_id, 
COUNT(pizza_id) 
FROM customer_orders_cleaned
GROUP BY order_id
ORDER BY 2 DESC

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?--
SELECT customer_id, 
SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 0 
      WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 2
      ELSE 1 END) as change
FROM customer_orders_cleaned
GROUP BY  customer_id
ORDER BY 2 DES

--8. How many pizzas were delivered that had both exclusions and extras--
SELECT 
SUM (CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END) as both_change
FROM customer_orders_cleaned

--9.What was the total volume of pizzas ordered for each hour of the day?--
SELECT DATE_PART('hour',order_time), COUNT(pizza_id),
ROUND( 100 * COUNT(pizza_id)/SUM(COUNT(*)) OVER (),2) AS volume_pizza_ordered
FROM customer_orders_cleaned
GROUP BY DATE_PART('hour',order_time)
ORDER BY 1 DESC

--10. What was the volume of orders for each day of the week?--
SELECT
      to_char(order_time, 'Day')                                              AS day_ordered,
      COUNT(to_char(order_time, 'Day'))                                       AS count_pizza_ordered,
      ROUND( 100 * COUNT(to_char(order_time, 'Day'))/SUM(COUNT(*)) OVER (),2) AS volume_pizza_ordered
    FROM 
      customer_orders_cleaned
    GROUP BY
      day_ordered
    ORDER BY
      day_ordered;

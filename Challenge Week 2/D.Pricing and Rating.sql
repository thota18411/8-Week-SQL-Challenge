--1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?--
DROP VIEW IF EXISTS new_customer_orders;
CREATE VIEW new_customer_orders AS
		SELECT  
			order_id,
			customer_id,
            pizza_id,
            CASE
                WHEN exclusions = '' THEN NULL
                WHEN exclusions = 'null' THEN NULL
                ELSE exclusions
            END AS exclusions,
            CASE
                WHEN extras = '' THEN NULL
                WHEN extras = 'null' THEN NULL
                WHEN extras = 'NaN' THEN NULL
                ELSE extras
            END AS extras,
            order_time
    FROM pizza_runner.customer_orders;

DROP VIEW IF EXISTS new_runner_orders;
CREATE VIEW new_runner_orders AS 
SELECT order_id,runner_id,CASE 
WHEN cancellation ='' THEN NULL
WHEN cancellation ='null' THEN NULL
ELSE cancellation
END
FROM pizza_runner.runner_orders;
    ----
WITH t1 AS (SELECT order_id,customer_id,CASE WHEN pizza_id=1 THEN 12
WHEN pizza_id=2 THEN 10 END AS price
FROM new_customer_orders
JOIN new_runner_orders
USING (order_id)
WHERE cancellation IS NULL)
SELECT SUM(price)
FROM t1

--2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra--
 ----
WITH t1 AS( SELECT order_id, pizza_id,
SUBSTR(extras,1,1) AS extra1,
SUBSTR(extras,4,1) AS extra2
FROM new_customer_orders)
,

t2 AS ( SELECT order_id, CASE WHEN pizza_id =1 THEN 12
  WHEN pizza_id=2 THEN 10 END AS price_piz,
 CASE WHEN extra1 ='' THEN 0
              WHEN extra1 = 'null' THEN 0
              WHEN extra1 IS NULL THEN 0
              ELSE 1
              END AS price_ex1 ,
 CASE WHEN extra2 ='' THEN 0
              WHEN extra2 = 'null' THEN 0
              WHEN extra2 IS NULL THEN 0
              ELSE 1
              END AS price_ex2
  
  FROM t1
  JOIN new_runner_orders
  USING(order_id) WHERE cancellation IS NULL)
  SELECT SUM(price_piz+price_ex1+price_ex2)
  FROM t2

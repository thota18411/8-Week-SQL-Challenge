--1. What are the standard ingredients for each pizza?--
WITH recipe_cleaned AS (SELECT pizza_id
,CAST(UNNEST(STRING_TO_ARRAY(toppings,', ')) as INT) as topping_id
FROM pizza_runner.pizza_recipes)
      
SELECT topping_name,COUNT(*)
      FROM pizza_runner.pizza_toppings 
      JOIN recipe_cleaned
      USING (topping_id)
      GROUP BY topping_name
HAVING COUNT(topping_id)>1

--2. What was the most commonly added extra?--
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
    --
WITH  t1 AS(SELECT 
CAST(UNNEST(STRING_TO_ARRAY(extras, ', ')) AS INT) AS topping_id
FROM new_customer_orders
            WHERE extras is not null)
     
     SELECT topping_name,COUNT(*) 
     FROM t1
     JOIN pizza_runner.pizza_toppings
     USING (topping_id)
     GROUP BY topping_name
     ORDER BY COUNT(*) DESC
     LIMIT 1
     
--3. What was the most common exclusion?--
WITH  t1 AS(SELECT 
CAST(UNNEST(STRING_TO_ARRAY(exclusions, ', ')) AS INT) AS topping_id
FROM new_customer_orders
            WHERE exclusions is not null)
     
     SELECT topping_name,COUNT(*) 
     FROM t1
     JOIN pizza_runner.pizza_toppings
     USING (topping_id)
     GROUP BY topping_name
     ORDER BY COUNT(*) DESC
     LIMIT 1
     
--Generate an order item for each record in the customers_orders table in the format of one of the following:
- `Meat Lovers`
- `Meat Lovers - Exclude Beef`
- `Meat Lovers - Extra Bacon`
- `Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers`--
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
    --
WITH t1 AS( SELECT order_id, pizza_id,
SUBSTR(exclusions,1,1) AS exclu1,
SUBSTR(exclusions,4,1) AS exclu2,
SUBSTR(extras,1,1) AS extra1,
SUBSTR(extras,4,1) AS extra2
FROM new_customer_orders),

t2 AS (
  SELECT order_id, pizza_id,
  CAST(CASE WHEN exclu1 ='' THEN NULL
              WHEN exclu1 = NULL THEN NULL
              ELSE exclu1
              END AS INT),
  CAST(CASE WHEN exclu2 ='' THEN NULL
              WHEN exclu2 = NULL THEN NULL
              ELSE exclu2
              END AS INT),
  CAST(CASE WHEN extra1 ='' THEN NULL
              WHEN extra1 = NULL THEN NULL
              ELSE extra1
              END AS INT),
  CAST(CASE WHEN extra2 ='' THEN NULL
              WHEN extra2 = NULL THEN NULL
              ELSE extra2
              END AS INT)
  
  FROM t1
),
t3 AS (
SELECT order_id,pizza_name,x1.topping_name as exclu_name1,x2.topping_name as exclu_name2,x3.topping_name as extra_name1,x4.topping_name as extra_name2
FROM t2
JOIN pizza_runner.pizza_names
USING (pizza_id)
LEFT JOIN pizza_runner.pizza_toppings x1
ON t2.exclu1=x1.topping_id
LEFT JOIN pizza_runner.pizza_toppings x2
ON t2.exclu2=x2.topping_id
LEFT JOIN pizza_runner.pizza_toppings x3
ON t2.extra1=x3.topping_id
LEFT JOIN pizza_runner.pizza_toppings x4
ON t2.extra2=x4.topping_id)

SELECT order_id,pizza_name,
CASE WHEN exclu_name1 is not null and exclu_name2 is not null and extra_name1 is not null and extra_name2 is not null THEN CONCAT(pizza_name,' -Exclude',exclu_name1,',',exclu_name2,' -Extra',extra_name1,',',extra_name2)
WHEN exclu_name1 is not null and extra_name1 is not null THEN
	CONCAT(pizza_name,' -Exclude',exclu_name1,exclu_name2,' -Extra',extra_name1,extra_name2)
WHEN exclu_name1 is not null THEN 
       CONCAT(pizza_name,' -Exclude',exclu_name1,exclu_name2)
WHEN extra_name1 is not null THEN
           CONCAT(pizza_name,' -Extra',extra_name1,extra_name2) 
           ELSE pizza_name END
FROM t3

--5. Generate an alphabetically ordered comma-separated ingredient list for each pizza order from the `customer_orders` table and add a `2x` in front of any relevant ingredients

- For example: `"Meat Lovers: 2xBacon, Beef, ... , Salami"`--
--haven't been solved
WITH t1 AS(
  SELECT pizza_id, CAST(UNNEST(STRING_TO_ARRAY(toppings,', ')) AS INT) AS topping_id
  FROM pizza_runner.pizza_recipes)
                        
SELECT x3.pizza_id,x3.order_id,x3.customer_id,x1.pizza_id,x1.pizza_name,t1.topping_id,x2.topping_name
FROM pizza_runner.pizza_names x1
JOIN t1
ON x1.pizza_id=t1.pizza_id
JOIN pizza_runner.pizza_toppings x2
ON t1.topping_id=x2.topping_id
RIGHT JOIN new_customer_orders x3
ON x3.pizza_id=x1.pizza_id
-- table with exclusions
SELECT order_id,customer_id,pizza_id, CAST(UNNEST(STRING_TO_ARRAY(exclusions,', ')) AS INT) AS inclu_topping_id
  FROM new_customer_orders
  
--6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?--
WITH t1 AS (SELECT x1.order_id,x1.customer_id,x1.pizza_id,CAST(UNNEST(STRING_TO_ARRAY(toppings,', ')) AS INT) AS topping_id
FROM new_customer_orders x1
JOIN pizza_runner.runner_orders x2
ON x1.order_id=x2.order_id
JOIN pizza_runner.pizza_recipes x3
ON x1.pizza_id=x3.pizza_id
WHERE x2.cancellation is not null)

SELECT t1.topping_id,x4.topping_name,COUNT(*)
FROM t1
JOIN pizza_runner.pizza_toppings x4                                     ON t1.topping_id=x4.topping_id  
GROUP BY t1.topping_id,x4.topping_name



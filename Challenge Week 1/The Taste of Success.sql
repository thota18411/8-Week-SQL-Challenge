--1: What is the total amount each customer spent at the restaurant?--
SELECT customer_id, SUM(price)
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
GROUP BY customer_id

--2.How many days has each customer visited the restaurant?--
SELECT customer_id, COUNT(*)
FROM 
(SELECT customer_id, DATE_TRUNC('day',order_date),COUNT(*)
FROM dannys_diner.sales 
GROUP BY customer_id, DATE_TRUNC('day',order_date)) as t1
GROUP BY customer_id

--3.What was the first item from the menu purchased by each customer?--
SELECT customer_id,
product_name
FROM
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY order_date) AS dem
FROM dannys_diner.sales) as t1
JOIN dannys_diner.menu m
ON t1.product_id=m.product_id
WHERE dem=1

--4.What is the most purchased item on the menu and how many times was it purchased by all customers? --
SELECT customer_id,COUNT(*)
FROM dannys_diner.sales s
JOIN (SELECT product_id, COUNT(*)
FROM dannys_diner.sales
GROUP BY product_id
LIMIT 1) as t1
ON s.product_id=t1.product_id
GROUP BY customer_id

--5.Which item was the most popular for each customer?--
WITH question_5 as (
select customer_id, product_name, count(product_name) as pcount 
  from dannys_diner.sales s JOIN dannys_diner.menu m USING (product_id) group by product_name, customer_id
),
Dense_rank_number AS (
    SELECT customer_id,product_name,pcount,
    DENSE_RANK() OVER (PARTITION BY customer_id order by pcount DESC) as dense_rank
    FROM question_5
    )
SELECT customer_id,product_name,pcount FROM Dense_rank_number
WHERE dense_rank = 1

--6.Which item was purchased first by the customer after they became a member?--
SELECT DISTINCT customer_id,
FIRST_VALUE (product_name) OVER (PARTITION by customer_id ORDER BY order_date) as first_buy
FROM dannys_diner.sales
JOIN dannys_diner.menu
USING (product_id)
JOIN dannys_diner.members
USING (customer_id)
WHERE order_date>=join_date

--7.Which item was purchased just before the customer became a member?--
WITH pre_membership AS (SELECT *
FROM dannys_diner.sales
JOIN dannys_diner.menu USING (product_id)
JOIN dannys_diner.members USING (customer_id)
WHERE order_date<join_date
)
SELECT DISTINCT customer_id,
	FIRST_VALUE(product_name) OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS last_buy
FROM pre_membership;

--8.What is the total items and amount spent for each member before they became a member?--
SELECT customer_id,COUNT(product_id) as pcount, SUM(price)
FROM dannys_diner.sales
JOIN dannys_diner.members
USING (customer_id)
JOIN dannys_diner.menu
USING (product_id)
WHERE order_date<join_date
GROUP BY customer_id

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?--
WITH membered AS (
  SELECT *
  FROM dannys_diner.sales
JOIN dannys_diner.members
USING (customer_id)
JOIN dannys_diner.menu
USING (product_id)
WHERE order_date>=join_date),

pointable AS (
  SELECT customer_id, SUM(price)*10,
  CASE WHEN product_name ='sushi' 
  THEN 10
  ELSE 0 END as sushi
FROM membered
GROUP BY customer_id,product_name)
  
  SELECT customer_id, SUM(price) + SUM(sushi)
  FROM membered
  JOIN pointable
  USING (customer_id)
  GROUP BY customer_id
  
  --10.  In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customers A and B have at the end of January?--
  WITH pointable AS (
  SELECT *,
  CASE WHEN order_date>=join_date AND order_date<=join_date+7 THEN price*20 
  WHEN order_date>join_date THEN price*20 END as point1,
  CASE WHEN product_name ='sushi' THEN 10 ELSE 0 END as point2
  FROM dannys_diner.sales
JOIN dannys_diner.members
USING (customer_id)
JOIN dannys_diner.menu
USING (product_id))
       
SELECT customer_id, SUM (point1+point2)
       FROM pointable
       GROUP BY customer_id

--1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) 
FROM data_bank.customer_nodes;

--2. What is the number of nodes per region?
SELECT region_name,COUNT(node_id) 
FROM data_bank.customer_nodes
JOIN data_bank.regions
USING (region_id)
GROUP BY region_name

--3. How many customers are allocated to each region?
SELECT region_name,COUNT(DISTINCT customer_id) 
FROM data_bank.customer_nodes
JOIN data_bank.regions
USING (region_id)
GROUP BY region_name

--4. How many days on average are customers reallocated to a different node?
WITH day_limited AS (SELECT end_date-start_date AS count_day
FROM data_bank.customer_nodes
EXCEPT
SELECT end_date-start_date
FROM data_bank.customer_nodes
WHERE end_date='9999-12-31')

SELECT ROUND(AVG(count_day),1)
FROM day_limited

--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region? (updating ...)
WITH day_limited AS (SELECT *,end_date-start_date AS count_day
FROM data_bank.customer_nodes
EXCEPT
SELECT *,end_date-start_date
FROM data_bank.customer_nodes
WHERE end_date='9999-12-31')

SELECT node_id,
  percentile_cont(0.80) within group (order by node_id)  as percentile_cont_80,
  percentile_cont(0.95) within group (order by node_id) as percentile_cont_95
FROM day_limited
GROUP BY node_id


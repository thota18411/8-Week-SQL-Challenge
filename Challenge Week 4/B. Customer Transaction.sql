--1. What is the unique count and total amount for each transaction type?
SELECT txn_type,SUM(txn_amount),COUNT(DISTINCT customer_id)
FROM data_bank.customer_transactions
GROUP BY txn_type

--2. What is the average total historical deposit counts and amounts for all customers?
SELECT customer_id, SUM(txn_amount),COUNT(txn_amount)
FROM data_bank.customer_transactions
WHERE txn_type='deposit'
GROUP BY customer_id

--3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH count_table AS(SELECT customer_id,DATE_PART('month',txn_date) AS monthly,
SUM(CASE WHEN txn_type='deposit' THEN 1 ELSE 0 END) AS deposit_count,
SUM(CASE WHEN txn_type='purchase' THEN 1 ELSE 0 END) AS purchase_count,
SUM(CASE WHEN txn_type='withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
FROM data_bank.customer_transactions
GROUP BY customer_id,DATE_PART('month',txn_date))
                               
SELECT monthly, COUNT(customer_id) AS customer_count
FROM count_table
WHERE deposit_count>=1 AND purchase_count>=1 OR withdrawal_Count>=1       
GROUP BY monthly

--4. What is the closing balance for each customer at the end of the month?
WITH t1 AS (SELECT customer_id,DATE_PART('month',txn_date) AS monthly,
SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE 0 END) AS total_deposit,
SUM(CASE WHEN txn_type='purchase' THEN txn_amount ELSE 0 END) AS total_purchase,
SUM(CASE WHEN txn_type='withdrawal' THEN txn_amount ELSE 0 END) AS total_withdrawal   
FROM data_bank.customer_transactions
GROUP BY customer_id, monthly)
,
t2 AS (SELECT *,total_deposit-total_purchase-total_withdrawal AS amount_end_month
FROM t1)
,
t3 AS (SELECT *,LAG(amount_end_month,1) OVER (PARTITION BY customer_id ORDER BY monthly) AS amount_previous_month
FROM t2)

SELECT customer_id,total_deposit,total_purchase,total_withdrawal,monthly,
amount_end_month +(CASE WHEN amount_previous_month IS NULL THEN 0 ELSE amount_previous_month END) AS total_amount
FROM t3

--5. 5. What is the percentage of customers who increase their closing balance by more than 5%? (Updating ...)

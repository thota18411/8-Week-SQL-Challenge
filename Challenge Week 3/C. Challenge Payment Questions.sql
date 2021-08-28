--The Foodie-Fi team wants you to create a new `payments` table for the year 2020 that includes amounts paid by each customer in the `subscriptions` table with the following requirements:

-- monthly payments always occur on the same day of the month as the original `start_date` of any monthly paid plan
-- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
-- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
-- once a customer churns they will no longer make payments

SELECT customer_id,DENSE_RANK () OVER (PARTITION BY customer_id ORDER BY start_date) AS order_id,start_date,plan_name,
LEAD (plan_name,1) OVER (PARTITION BY customer_id ORDER BY start_date)  AS next_plan,
CASE WHEN plan_name='pro annual' THEN 199
WHEN  plan_name='basic monthly' THEN 9.90
WHEN plan_name='pro monthly' THEN 19.90 END AS price
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id)
WHERE DATE_PART('year',start_date)=2020 AND plan_name='pro monthly' OR plan_name='basic monthly' OR plan_name='pro annual'

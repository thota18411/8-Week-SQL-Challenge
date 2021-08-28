--How many customers has Foodie-Fi ever had?
--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
--What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
--What is the number and percentage of customer plans after their initial free trial?
--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
--How many customers have upgraded to an annual plan in 2020?
--How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
--Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
--How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

--1 How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions

--2 What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT COUNT(DISTINCT customer_id) as number_of_cus,DATE_PART('month',start_date) As by_month
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id)
WHERE plan_name='trial'
GROUP BY DATE_PART('month',start_date)

--3 What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT plan_name,COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id)
WHERE DATE_PART('year',start_date) >2020
GROUP BY plan_name

--4 What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(DISTINCT customer_id), ROUND(COUNT(DISTINCT customer_id)::numeric*100/1000,1)
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id)
WHERE plan_name='churn'

--5 How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH next_plan_table AS (SELECT customer_id, start_date,plan_name,
LEAD (plan_name,1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id))
       
       SELECT COUNT(distinct customer_id) as trial_churn,
       ROUND((COUNT(distinct customer_id)::numeric/1000)*100,2) AS percent
       FROM next_plan_table
       WHERE plan_name = 'trial' AND next_plan='churn'
       
 --6 What is the number and percentage of customer plans after their initial free trial?
 WITH next_plan_table AS (SELECT customer_id, start_date,plan_name,
LEAD (plan_name,1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id))
       
      SELECT next_plan AS next_plan_after_trial,COUNT(distinct customer_id) AS customer,
       ROUND((COUNT(distinct customer_id)::numeric/1000)*100,2)
      FROM next_plan_table
      WHERE plan_name='trial'
      GROUP BY next_plan
      
--7 What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH t1 AS (SELECT customer_id,start_date,plan_id,
LEAD(plan_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS stt
FROM foodie_fi.subscriptions
WHERE EXTRACT(YEAR FROM start_date)=2020)
--table tính đến năm 2020 và dùng lead để biết plan tiếp theo có null ko, nếu null là plan cũ đang là plan hiện tại
,
 t2 AS(SELECT COUNT(customer_id) AS sum_of_each_plan,plan_id
FROM t1
WHERE stt IS NULL
GROUP BY plan_id)
--cột next_plan null là hiện tại vẫn ở cột plan_id đó
SELECT ROUND((sum_of_each_plan/1000::numeric*100),2),plan_name
FROM t2
JOIN foodie_fi.plans
USING (plan_id)

--8 How many customers have upgraded to an annual plan in 2020?
WITH t1 AS (SELECT customer_id,start_date,plan_name,
LEAD(plan_name,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
            USING(plan_id)
WHERE EXTRACT(YEAR FROM start_date)=2020)

SELECT COUNT(customer_id)
FROM t1
WHERE plan_name='pro annual'

--9 How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH t1 AS(SELECT customer_id, plan_name,start_date,
LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS annual_next_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id)
WHERE plan_name='trial' OR plan_name='pro annual')

SELECT AVG(annual_next_date-start_date)
FROM t1
WHERE annual_next_date is not null

--10 Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH t1 AS(SELECT customer_id, plan_name,start_date,
LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS annual_next_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id)
WHERE plan_name='trial' OR plan_name='pro annual')

SELECT ROUND(AVG (annual_next_date-start_date),2) AS avg_trial_To_annual ,
CASE WHEN (annual_next_date-start_date) <=30 THEN '0-30 days'
	WHEN (annual_next_date-start_date) <=60 THEN '30-60 days'
    WHEN (annual_next_date-start_date) <=90 THEN '60-90 days'
    WHEN (annual_next_date-start_date) <=120 THEN '90-120 days'
    WHEN (annual_next_date-start_date) <=150 THEN '120-150 days'
    WHEN (annual_next_date-start_date) <=180 THEN '150-180 days'
    WHEN (annual_next_date-start_date) <=210 THEN '180-210 days'
    WHEN (annual_next_date-start_date) <=240 THEN '210-240 days'
    WHEN (annual_next_date-start_date) <=270 THEN '240-270 days'
    WHEN (annual_next_date-start_date) <=300 THEN '270-300 days'
    WHEN (annual_next_date-start_date) <=330 THEN '300-330 days'
    WHEN (annual_next_date-start_date) <=366 THEN '330-366 days'
    END as day_period
FROM t1
WHERE annual_next_date is not null
GROUP BY day_period
ORDER BY day_period

--11 How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH t1 AS (SELECT customer_id,start_date, plan_name,
LEAD(plan_name,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_basic_monthly
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id)
WHERE DATE_PART('year',start_date)=2020)

SELECT COUNT(customer_id) AS customer_from_pro_to_basic_monthly
FROm t1
WHERE plan_name='pro monthly' AND next_basic_monthly='basic monthly'

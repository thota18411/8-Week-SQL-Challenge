--This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?--
--Find the week number of 2020-06-15--
SELECT DISTINCT week_number
          FROM t1
          WHERE week_date='2020-06-15'
--Tính tổng sales của từng tuần từ 21 → 28, sau đó dùng sum(case when để chia 21-24 và 24-28)--
t2 AS(SELECT week_number,SUM(sales) as sales_week
          FROM t1
          WHERE week_number BETWEEN 21 AND 28
          GROUP BY week_number)
          
          SELECT SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN sales_week END) as before_change  ,
          SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN sales_week END) as after_change,
          SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN sales_week END)-SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN sales_week END) as variance
          FROM t2
          
--2. What about the entire 12 weeks before and after?--
t2 AS(SELECT month_number,SUM(sales) as month_sale
          FROM t1
          WHERE year_number='2020' AND month_number BETWEEN 3 AND 8
		  GROUP BY month_number)
          
          SELECT SUM(CASE WHEN month_number BETWEEN 3 AND 5 THEN month_sale END) as before_3m_change,
          SUM(CASE WHEN month_number BETWEEN 6 AND 8 THEN month_sale END) as after_3m_change,
          SUM(CASE WHEN month_number BETWEEN 3 AND 5 THEN month_sale END)-SUM(CASE WHEN month_number BETWEEN 6 AND 8 THEN month_sale END) AS variance
          FROM t2

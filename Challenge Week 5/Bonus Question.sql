--## 4. Bonus Question:

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

- `region`
- `platform`
- `age_band`
- `demographic`
- `customer_type`

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?--

t2 AS(SELECT week_number,region,platform,age_band,demographic,customer_type,SUM(sales) as sales_week
          FROM t1
          WHERE week_number BETWEEN 13 AND 36 AND year_number='2020'
          GROUP BY week_number,region,platform,age_band,demographic,customer_type)
          
          SELECT region,platform,age_band,demographic,customer_type,SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN sales_week END) as before_change  ,
          SUM(CASE WHEN week_number BETWEEN 25 AND 36 THEN sales_week END) as after_change,
          SUM(CASE WHEN week_number BETWEEN 25 AND 36 THEN sales_week END)-SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN sales_week END) as variance
          FROM t2
          GROUP BY region,platform,age_band,demographic,customer_type
          ORDER BY variance

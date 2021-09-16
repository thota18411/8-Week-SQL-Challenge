--1. What day of the week is used for each week_date value?--

--3. How many total transactions were there for each year in the dataset?--
SELECT DATE_PART('year',week_date) ,COUNT(transactions)
FROM t1
GROUP BY DATE_PART('year',week_date)

--4. What is the total sales for each region for each month?--
SELECT region,month_number,COUNT(sales)
FROM t1
GROUP BY region,month_number  
ORDER BY region,month_number

--5. What is the total count of transactions for each platform--
SELECT platform,COUNT(transactions)
FROM t1
GROUP BY platform

--6. What is the percentage of sales for Retail vs Shopify for each month?--
t2 AS(SELECT month_number,year_number,platform,SUM(sales) as sale_month
FROM t1
GROUP BY month_number,year_number,platform)
          
          SELECT year_number,month_number,ROUND(100*MAX
    (CASE WHEN platform = 'Retail' THEN sale_month END) / 
      SUM(sale_month),2) AS retail_percentage,
          ROUND(100*MAX
    (CASE WHEN platform = 'Shopify' THEN sale_month END) / 
      SUM(sale_month),2) AS shopify_percentage
          FROM t2
          GROUP BY year_number,month_number

--1. How many users are there?--
SELECT COUNT(DISTINCT user_id)
FROM clique_bait.users

--2. How many cookies does each user have on average?--
SELECT COUNT(cookie_id)/COUNT(DISTINCT user_id)
FROM clique_bait.users

--3. What is the unique number of visits by all users per month?--
SELECT COUNT(cookie_id) as count_visit,DATE_PART('month',start_date)
FROM clique_bait.users
GROUP BY DATE_PART('month',start_date)
ORDER BY 2

--4. What is the number of events for each event type?--
SELECT event_name,COUNT(event_time)
FROM clique_bait.events
JOIN clique_bait.event_identifier
USING (event_type)
GROUP BY 1

--5. What is the percentage of visits which have a purchase event?--
SELECT 100*COUNT(DISTINCT visit_id)/(SELECT COUNT(DISTINCT(visit_id)) FROM clique_bait.events) AS percent_of_purchase_event
FROM clique_bait.events
JOIN clique_bait.event_identifier
USING (event_type)
WHERE event_name='Purchase'

--6.What is the percentage of visits which view the checkout page but do not have a purchase event?--
WITH t1 AS(SELECT 
CASE WHEN event_name='Page View' AND page_name='Checkout' THEN 1 ELSE 0 END AS ViewPage,
CASE WHEN event_name= 'Purchase' THEN 1 ELSE 0 END AS purchase
FROM clique_bait.events
JOIN clique_bait.event_identifier
USING (event_type)
JOIN clique_bait.page_hierarchy
USING (page_id))

SELECT ROUND(100*(1-(sum(purchase)::numeric/sum(ViewPage))),2)
FROM t1

--7. What are the top 3 pages by number of views?--
SELECT 
page_name, COUNT(page_id)
FROM clique_bait.events
JOIN clique_bait.event_identifier
USING (event_type)
JOIN clique_bait.page_hierarchy
USING (page_id)
WHERE event_name='Page View'
GROUP BY page_name
ORDER BY 2 DESC
LIMIT 3

--8.What is the number of views and cart adds for each product category?--
SELECT 
product_category,SUM(CASE WHEN event_name='Page View' THEN 1 ELSE 0 END) AS pageview,
SUM(CASE WHEN event_name='Add to Cart' THEN 1 ELSE 0 END) AS addtocart
FROM clique_bait.events
JOIN clique_bait.event_identifier
USING (event_type)
JOIN clique_bait.page_hierarchy
USING (page_id)
GROUP BY product_category

--9. What are the top 3 products by purchases?--
SELECT 
product_category,COUNT(*)
FROM clique_bait.events
JOIN clique_bait.event_identifier
USING (event_type)
JOIN clique_bait.page_hierarchy
USING (page_id)
WHERE event_name='Purchase'
GROUP BY product_category


       
       

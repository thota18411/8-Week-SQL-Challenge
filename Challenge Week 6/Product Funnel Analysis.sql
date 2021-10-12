--Using a single SQL query - create a new output table which has the following details:

- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?--

--tìm những visit_id nào đã view với add trước (vì purchase nó chỉ purchase ở các trang home, checkout nên nếu group by chung thì sẽ ra kết quả category null) sau đó làm tip 1 bảng tìm những visit_id đã mua hàng. Sau đó combine 2 bảng này lại với nhau, nối purchase cho bảng đầu.--
WITH t1 AS(SELECT visit_id,
page_name,product_category,SUM(CASE WHEN event_name='Page View' THEN 1 ELSE 0 END) AS Viewed,
SUM(CASE WHEN event_name='Add to Cart' THEN 1 ELSE 0 END) AS Added
FROM clique_bait.events
JOIN clique_bait.event_identifier
USING (event_type)
JOIN clique_bait.page_hierarchy
USING (page_id)
GROUP BY visit_id,page_name,product_category),

t2 AS (SELECT visit_id
     FROM clique_bait.events
     JOIN clique_bait.event_identifier
     USING (event_type)
     WHERE event_name='Purchase'),
     
t3 AS (SELECT visit_id,page_name,product_category,Viewed,Added, CASE WHEN t2.visit_id IS NOT NULL THEN 1 ELSE 0 END AS Purchased
FROM t1
LEFT JOIN t2
USING (visit_id))
       
SELECT page_name,product_category,SUM(Viewed) AS SUM_view, SUM(Added) AS SUM_add, SUM(CASE WHEN Added=1 AND Purchased=0 THEN 1 ELSE 0 END) AS SUM_NotPurchase, SUM(CASE WHEN Added=1 AND Purchased=1 THEN 1 ELSE 0 END) AS SUM_Purchase
FROM t3
GROUP BY page_name,product_category

--Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Use your 2 new output tables - answer the following questions:

Which product had the most views, cart adds and purchases?
Which product was most likely to be abandoned?
Which product had the highest view to purchase percentage?
What is the average conversion rate from view to cart add?
What is the average conversion rate from cart add to purchase?--

WITH t1 AS(SELECT visit_id,
product_category,SUM(CASE WHEN event_name='Page View' THEN 1 ELSE 0 END) AS Viewed,
SUM(CASE WHEN event_name='Add to Cart' THEN 1 ELSE 0 END) AS Added
FROM clique_bait.events
JOIN clique_bait.event_identifier
USING (event_type)
JOIN clique_bait.page_hierarchy
USING (page_id)
WHERE product_category IS NOT NULL
GROUP BY visit_id,product_category),

t2 AS (SELECT visit_id
     FROM clique_bait.events
     JOIN clique_bait.event_identifier
     USING (event_type)
     WHERE event_name='Purchase'),
     
t3 AS (SELECT visit_id,product_category,Viewed,Added, CASE WHEN t2.visit_id IS NOT NULL THEN 1 ELSE 0 END AS Purchased
FROM t1
LEFT JOIN t2
USING (visit_id))
       
SELECT product_category,SUM(Viewed) AS SUM_view, SUM(Added) AS SUM_add, SUM(CASE WHEN Added=1 AND Purchased=0 THEN 1 ELSE 0 END) AS SUM_NotPurchase, SUM(CASE WHEN Added=1 AND Purchased=1 THEN 1 ELSE 0 END) AS SUM_Purchase
FROM t3
GROUP BY product_category

--Product has the most view: Shellfish
Product has the most add to cart: Shellfish
Product has the most purchase: Luxury
Product has the most abandon: Fish --

--Which product had the highest view to purchase percentage?--
t4 AS(SELECT product_category,SUM(Viewed) AS SUM_view, SUM(Added) AS SUM_add, SUM(CASE WHEN Added=1 AND Purchased=0 THEN 1 ELSE 0 END) AS SUM_NotPurchase, SUM(CASE WHEN Added=1 AND Purchased=1 THEN 1 ELSE 0 END) AS SUM_Purchase
FROM t3
GROUP BY product_category)
       
       SELECT product_category, ROUND(100*sum_purchase::numeric/sum_view,2)
       FROM t4
       
--What is the average conversion rate from view to cart add?
What is the average conversion rate from cart add to purchase?--
t4 AS(SELECT product_category,SUM(Viewed) AS SUM_view, SUM(Added) AS SUM_add, SUM(CASE WHEN Added=1 AND Purchased=0 THEN 1 ELSE 0 END) AS SUM_NotPurchase, SUM(CASE WHEN Added=1 AND Purchased=1 THEN 1 ELSE 0 END) AS SUM_Purchase
FROM t3
GROUP BY product_category)
       
       SELECT product_category, ROUND(100*AVG(sum_add::numeric/sum_view),2),
ROUND(100*AVG(sum_purchase::numeric/sum_add),2) 
       FROM t4
       GROUP BY product_category

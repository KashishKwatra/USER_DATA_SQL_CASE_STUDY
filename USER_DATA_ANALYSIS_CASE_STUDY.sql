
/* 1. Get the number of orders placed by C_001, C_002, C_003. All the three customer_ids 
 and the numbers of orders should be present in the result separately.*/

SELECT customer_id, COUNT(order_id) AS Total_Orders
FROM orders_data
WHERE customer_id IN ('C_001','C_002','C_003')
GROUP BY customer_id

-- 2. Which customer_id has the highest spends? Also, show the customer name.--

SELECT TOP 1 cusomter_id,CONCAT(first_name, ' ' ,last_name) AS Cust_Name ,SUM(amount_paid) AS Spend
FROM orders_data AS O
INNER JOIN user_data AS U
ON O.customer_id = U.cusomter_id
GROUP BY cusomter_id, CONCAT(first_name, ' ' ,last_name)
ORDER BY Spend DESC

-- 3. Which product_id has been bought the most?--

SELECT TOP 5 product_id, COUNT(order_id) AS Count
FROM orders_data 
GROUP BY product_id

-- 4. Which product_id has generated the highest revenue?--

SELECT TOP 1 product_id, SUM(amount_paid) AS Revenue
FROM orders_data
GROUP BY product_id
ORDER BY Revenue DESC

/* 5. In our inventory, which product category has the lowest no of items?
Which should we add more of? */

SELECT category, SUM(amount_paid) AS Revenue
FROM products_data AS P
INNER JOIN orders_data AS O
ON P.product_id = O.product_id
GROUP BY category

-- 6. What is the cheapest price in each of the product category?--

SELECT *
FROM (
		SELECT category, product_name, price,
		DENSE_RANK() OVER (PARTITION BY CATEGORY ORDER BY PRICE ASC) AS RANKS
		FROM products_data
)AS X
WHERE RANKS = 1

-- 7. Month on Month count of orders & revenue.--

SELECT DATEPART(MONTH, order_datetimestamp) AS Months, COUNT(order_id) AS Order_count,
       SUM(amount_paid) AS Revenue
FROM orders_data
GROUP BY DATEPART(MONTH, order_datetimestamp)

-- 8. Month on Month count of sign ups.--

SELECT DATEPART(MONTH, created_at) AS Months, FORMAT(created_at,'MMMM') AS Month_names,
COUNT(cusomter_id) AS Sign_ups
FROM user_data
GROUP BY DATEPART(MONTH, created_at),FORMAT(created_at,'MMMM')
ORDER BY Months

-- 9. Figure out who purchased the highest in each month.--

SELECT MONTHS, customer_id, CUST_NAME
FROM (
	  SELECT MONTH(order_datetimestamp) AS MONTHS, customer_id,
	  first_name + ' ' + last_name AS CUST_NAME, SUM(amount_paid) AS SPEND,
	  DENSE_RANK() OVER(PARTITION BY MONTH(order_datetimestamp) 
	  					ORDER BY SUM(AMOUNT_PAID) DESC) AS RANKS
	  FROM user_data AS U
	  INNER JOIN orders_data AS O
	  ON U.cusomter_id = O.customer_id
	  GROUP BY MONTH(order_datetimestamp), customer_id, first_name + ' ' + last_name 
) AS X
WHERE RANKS = 1

-- 10. Get the list of customer_ids which has spends more than 100.--

SELECT customer_id, SUM(amount_paid) AS Spend
FROM orders_data
GROUP BY customer_id
HAVING SUM(amount_paid)>100

-- 11. Get the month with revenue more than 2100 and orders volume more than 30.--

SELECT MONTH(order_datetimestamp) AS Months, SUM(amount_paid) AS Revenue, 
COUNT(order_id) AS Orders
FROM orders_data
GROUP BY MONTH(order_datetimestamp)
HAVING SUM(amount_paid) > 2100
             AND
	   COUNT(order_id) > 30

-- 12. Get the numbers of orders placed by each customer in month of Jan.--

SELECT customer_id, FORMAT(order_datetimestamp,'MMMM') AS Month_name,
CONCAT(first_name, ' ', last_name) AS Cust_names, COUNT(order_id) AS Orders
FROM user_data AS U
INNER JOIN orders_data AS O
ON U.cusomter_id = O.customer_id
WHERE MONTH(order_datetimestamp) = 1
GROUP BY customer_id, MONTH(order_datetimestamp), FORMAT(order_datetimestamp,'MMMM'),
CONCAT(first_name, ' ', last_name)

-- 13. Get the name of the customer who has spent the most with us.--

SELECT TOP 1 first_name+ ' '+ last_name AS Cust_name, SUM(amount_paid) AS Spend
FROM orders_data AS O
INNER JOIN user_data AS U
ON O.customer_id = U.cusomter_id
GROUP BY first_name+ ' '+ last_name
ORDER BY Spend DESC

-- 14. Get all the users who has not purchased any orders.--

SELECT U.cusomter_id, first_name + ' '+ last_name AS Cust_name, email, phone
FROM user_data AS U
LEFT JOIN orders_data AS O
ON U.cusomter_id = O.customer_id
WHERE amount_paid IS NULL

/*15. For the customer has spent the most, figure out which product category have they 
 spent the most.*/

 SELECT category,product_name, SUM(amount_paid) AS Spend
 FROM products_data AS P
 INNER JOIN orders_data AS O
 ON P.product_id = O.product_id
 WHERE customer_id =  (SELECT TOP 1 customer_id-- SUM(amount_paid) AS Spend
                     FROM orders_data
                     GROUP BY customer_id
                     ORDER BY SUM(amount_paid) DESC)
 GROUP BY category, product_name
 ORDER BY Spend DESC



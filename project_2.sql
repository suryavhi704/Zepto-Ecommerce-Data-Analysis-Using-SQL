USE ZEPTO;
--  ## Mini Project on E-commerce ZEPTO Analysis............

-- 𝗘𝗔𝗦𝗬 (Basic SELECTs, WHERE, ORDER BY):-

-- 1.List the names and emails of the top 10 customers based on total orders placed.
-- 2.Find the top 5 most expensive products (by MRP).
-- 3.Show all orders where the delivery status is 'Delayed'.
-- 4.Display all feedback entries with a rating less than 3.

-- 1.
SELECT customer_id,customer_name,EMAIL
FROM customers
ORDER BY TOTAL_ORDERS DESC
LIMIT 10;

-- 2.
SELECT product_id,product_name 
FROM products
ORDER BY MRP DESC
LIMIT 5;

-- 3.
SELECT *
FROM ORDERS
WHERE DELIVERY_STATUS='SLIGHTLY Delayed';

-- 4.
SELECT * 
FROM FEEDBACK
WHERE RATING<3;

-- 𝗠𝗘𝗗𝗜𝗨𝗠 (JOINs, GROUP BY, Aggregates):-

-- Find the total revenue generated per product.
-- List customers who have given feedback with the sentiment 'Negative'.
-- Get the number of delayed deliveries per delivery partner.
-- Find the average order value for each customer segment.

-- 1.
SELECT * FROM products;
SELECT * FROM order_items;

 
SELECT PRODUCT_NAME,O.PRODUCT_ID,SUM(QUANTITY*UNIT_PRICE) AS TOTAL_REVENUE
FROM ORDER_ITEMS AS O
JOIN 
products AS P
ON O.PRODUCT_ID=P.product_id
GROUP BY product_name,O.PRODUCT_ID
order by TOTAL_REVENUE DESC;

-- 2.

SELECT * FROM CUSTOMERS;
SELECT * FROM FEEDBACK;

SELECT CUSTOMER_NAME,EMAIL,RATING,SENTIMENT
FROM customers AS C
JOIN
FEEDBACK AS F
ON C.customer_id=F.CUSTOMER_ID
WHERE SENTIMENT='NEGATIVE';

-- 3.
SELECT * FROM DELIVERY;

SELECT
    delivery_partner_id,
    COUNT(*) AS delayed_deliveries_count
FROM
    delivery
WHERE
    delivery_status = 'SLIGHTLY_Delayed'
GROUP BY
    delivery_partner_id;
    
-------------------------------------
WITH CTE AS (
SELECT DELIVERY_PARTNER_ID
FROM DELIVERY
WHERE delivery_status='Slightly Delayed'
)
SELECT delivery_partner_id,count(delivery_partner_id) OVER(PARTITION BY delivery_partner_id) AS COUNT
FROM CTE;

-- 4.
SELECT * FROM CUSTOMERS;

SELECT CUSTOMER_SEGMENT,sum(AVG_ORDER_VALUE)
FROM customers
GROUP BY CUSTOMER_SEGMENT;

-- 𝗛𝗔𝗥𝗗 (Subqueries, CTEs, Nested Aggregates, Date logic):-

-- Which products had the highest percentage of damaged stock over total stock received?
-- Find the top 3 products (by revenue) for each month.
-- Identify customers who ordered more than 5 times but have never given feedback.
-- Calculate the delivery delay (in minutes) for each order and list the top 5 most delayed ones.

-- 1.-- Which products had the highest percentage of damaged stock over total stock received?
SELECT * FROM INVENTORY;
SELECT * FROM PRODUCTS;
WITH CTE AS
(
SELECT PRODUCT_ID,(SUM(DAMAGED_STOCK)/SUM(STOCK_RECEIVED))*100 AS AMOUNT_DAMAGED_STOCK
FROM INVENTORY
GROUP BY PRODUCT_ID )

SELECT PRODUCT_NAME,AMOUNT_DAMAGED_STOCK
FROM CTE AS C
JOIN
products AS P
ON P.product_id=C.PRODUCT_ID
ORDER BY AMOUNT_DAMAGED_STOCK DESC;

-- 2-- Find the top 3 products (by revenue) for each month
SELECT * FROM orders;
SELECT * FROM ORDER_ITEMS;
SELECT * FROM PRODUCTS;

WITH MonthlyRevenue AS (
    -- Calculate the total revenue for each product per month.
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM
        orders AS o
    JOIN
        order_items AS oi ON o.order_id = oi.order_id
    JOIN
        products AS p ON oi.product_id = p.product_id
    GROUP BY
        order_month,
        p.product_name
),
RankedProducts AS (
    -- Rank products by revenue within each month.
    SELECT
        order_month,
        product_name,
        total_revenue,
        -- DENSE_RANK is a good alternative to ROW_NUMBER. It assigns the same rank to products with the same revenue.
        DENSE_RANK() OVER (PARTITION BY order_month ORDER BY total_revenue DESC) AS rank_num
    FROM
        MonthlyRevenue
)
-- Select the top 3 ranked products for each month.
SELECT
    order_month,
    product_name,
    total_revenue
FROM
    RankedProducts
WHERE
    rank_num <= 3
ORDER BY
    order_month,
    rank_num;
    
    
    
-- 3.-- Identify customers who ordered more than 5 times but have never given feedback.
SELECT * FROM CUSTOMERS;
SELECT * FROM FEEDBACK;

SELECT * FROM CUSTOMERS AS C
WHERE TOTAL_ORDERS >5 AND
C.CUSTOMER_ID
NOT IN (SELECT CUSTOMER_ID
FROM FEEDBACK);

-- 4. -- Calculate the delivery delay (in minutes) for each order and list the top 5 most delayed ones.
SELECT * FROM DELIVERY;

SELECT ORDER_ID,SUM(delivery_time_minutes) AS TOTAL_DELAY_MINUTES
FROM DELIVERY
GROUP BY ORDER_ID
ORDER BY TOTAL_DELAY_MINUTES DESC
LIMIT 5;


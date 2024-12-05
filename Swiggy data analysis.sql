-- 1. Find customers who have never ordered.
SELECT name FROM users
WHERE user_id NOT IN (SELECT user_id FROM orders);

-- 2. Average Price/dish
SELECT f.f_name AS food_name, AVG(price) AS average_price
FROM menu m
JOIN food f
ON m.f_id=f.f_id
GROUP BY f.f_name;

-- 3. Find top restaurant in terms of number of orders for a given month.
SELECT r.r_name AS restaurant_name, COUNT(order_id) AS orders_quantity 
FROM orders o
JOIN restaurants r
ON o.r_id = r.r_id
WHERE MONTHNAME(date) LIKE 'July'
GROUP BY o.r_id
ORDER BY orders_quantity DESC
LIMIT 1;

-- 4. Restaurants with monthly sales greater than x.
SELECT r.r_name, SUM(amount) AS revenue 
FROM orders o
JOIN restaurants r
ON o.r_id = r.r_id
WHERE MONTHNAME(date) LIKE 'May'
GROUP BY o.r_id
HAVING revenue > 700;

-- 5. Show all orders with order details for a particular customer in a particular data range.
SELECT o.order_id, r.r_name restaurant_name,f_name
FROM orders o
JOIN restaurants r
ON r.r_id = o.r_id
JOIN order_details od
ON o.order_id = od.order_id
JOIN food f
ON f.f_id = od.f_id
WHERE user_id = (SELECT user_id FROM users WHERE name LIKE 'Ankit')
AND (date > '2022-06-10' AND date < '2022-07-10');

 -- 6. Find restaurants with max repeated customers.
SELECT r.r_name, COUNT(*) AS 'loyal_customers'
FROM (
	SELECT r_id, user_id, COUNT(*) AS visits
	FROM orders
	GROUP BY r_id, user_id
	HAVING visits>1
) t
JOIN restaurants r
ON r.r_id = t.r_id
GROUP BY t.r_id
ORDER BY loyal_customers DESC
LIMIT 1;

 -- 7. Month over month revenue growth of swiggy.
SELECT month, ((revenue - prev)/prev*100) AS revenue_growth FROM (
	WITH sales AS
	(
		SELECT MONTHNAME(date) AS month, SUM(amount) AS revenue 
		FROM orders
		GROUP BY month
		ORDER BY month
	) 
SELECT month, revenue, LAG(revenue,1) OVER(ORDER BY revenue) AS prev FROM sales
) t;


 -- 8. Customers favorite food. 
WITH temp AS 
(
	SELECT o.user_id, od.f_id, COUNT(*) AS frequency
	FROM orders o
	JOIN order_details od
	ON o.order_id = od.order_id
	GROUP BY o.user_id, od.f_id
)
SELECT u.name, f.f_name,t1.frequency
FROM temp t1
JOIN users u
ON u.user_id  = t1.user_id
JOIN food f
ON f.f_id = t1.f_id
WHERE t1.frequency = (
	SELECT MAX(frequency)
    FROM temp t2
    WHERE t2.user_id = t1.user_id
);

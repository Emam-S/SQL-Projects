Create database zomato;
Use zomato;
Create table customers
(
customer_id int primary key,
customer_name varchar(25),
reg_date date
);
Create table restaurants
(
restaurant_id int primary key,
restaurant_name varchar(55),
city varchar(55),
opening_hours varchar(1000)
);
Create table orders
(
order_id int primary key,
customer_id int,
restaurant_id int,
order_item varchar(55),
order_date date,
order_time time,
order_status varchar(55),
total_amount float
);
Alter table orders
add constraint fk_customers 
foreign key (customer_id) 
references customers(customer_id);
Alter table orders
add constraint fk_restaurant 
foreign key (restaurant_id) 
references restaurants(restaurant_id);
Create table riders
(
rider_id int primary key,
rider_name varchar(55),
sign_up date
);
Create table deliveries
(
delivery_id int primary key,
order_id int,
delivery_status varchar(35),
delivery_time time,
rider_id int,
constraint fk_orders foreign key(order_id) references orders (order_id),
constraint fk_riders foreign key(rider_id) references riders (rider_id)
);

Select * from customers;
Select * from restaurants;
Select * from orders;
Select * from riders;
Select * from deliveries;

## Checking for NULL VALUES

SELECT COUNT(*) FROM customers
WHERE 
	customer_name IS NULL
	OR
	reg_date IS NULL;
SELECT COUNT(*) FROM restaurants
WHERE 
	restaurant_name IS NULL
	OR
	city IS NULL
	OR
	opening_hours IS NULL;
SELECT * FROM orders
WHERE 
	order_item IS NULL
	OR
	order_date IS NULL
	OR
	order_time IS NULL
	OR
	order_status IS NULL
	OR 
	total_amount IS NULL;
DELETE FROM orders
WHERE 
	order_item IS NULL
	OR
	order_date IS NULL
	OR
	order_time IS NULL
	OR
	order_status IS NULL
	OR 
	total_amount IS NULL;
INSERT INTO orders(order_id, customer_id, restaurant_id)
VALUES
(10002,9, 54),
(10003, 10, 51),
(10005, 10, 50)
;

## To find top 5 most frequently ordered dishes by customer called 'Arjun Mehta'in the last 1 year

SELECT 
	customer_name,
	dishes,
	total_orders
FROM -- table name
	(SELECT 
		c.customer_id,
		c.customer_name,
		o.order_item as dishes,
		COUNT(*) as total_orders,
		DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) as rank_1
	FROM orders as o
	JOIN
	customers as c
	ON c.customer_id = o.customer_id
	WHERE 
		o.order_date >= CURRENT_DATE - INTERVAL '1 Year'
		AND 
		c.customer_name = 'Arjun Mehta'
	GROUP BY 1, 2, 3
	ORDER BY 1, 4 DESC) as t1
WHERE rank <= 5;

## Identifying  the time slots during which the most orders are placed. based on 2-hour intervals.

SELECT
    CASE
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM Orders
GROUP BY time_slot
ORDER BY order_count DESC;

## Finding the average order value per customer who has placed more than 750 orders.

SELECT 
	-- o.customer_id,
	c.customer_name,
	AVG(o.total_amount) as aov
FROM orders as o
	JOIN customers as c
	ON c.customer_id = o.customer_id
GROUP BY 1
HAVING  COUNT(order_id) > 750;

## Listing the customers who have spent more than 100K in total on food orders.

SELECT 
	-- o.customer_id,
	c.customer_name,
	SUM(o.total_amount) as total_spent
FROM orders as o
	JOIN customers as c
	ON c.customer_id = o.customer_id
GROUP BY 1
HAVING SUM(o.total_amount) > 100000;

## Write a query to find orders that were placed but not delivered. 
-- Return each restuarant name, city and number of not delivered orders 

SELECT 
	r.restaurant_name,
	COUNT(o.order_id) as cnt_not_delivered_orders
FROM orders as o
LEFT JOIN 
restaurants as r
ON r.restaurant_id = o.restaurant_id
LEFT JOIN
deliveries as d
ON d.order_id = o.order_id
WHERE d.delivery_id IS NULL
GROUP BY 1
ORDER BY 2 DESC;

## Ranking restaurants by their total revenue from the last year, including their name, 
-- total revenue, and rank within their city.

WITH ranking_table
AS
(
	SELECT 
		r.city,
		r.restaurant_name,
		SUM(o.total_amount) as revenue,
		RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) as rank_1
	FROM orders as o
	JOIN 
	restaurants as r
	ON r.restaurant_id = o.restaurant_id
	WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
	GROUP BY 1, 2
)
SELECT 
	*
FROM ranking_table
WHERE rank_1 = 1;


## Identifying the most popular dish in each city based on the number of orders.

SELECT * 
FROM
(SELECT 
	r.city,
	o.order_item as dish,
	COUNT(order_id) as total_orders,
	RANK() OVER(PARTITION BY r.city ORDER BY COUNT(order_id) DESC) as rank_1
FROM orders as o
JOIN 
restaurants as r
ON r.restaurant_id = o.restaurant_id
GROUP BY 1, 2
) as t1
WHERE rank_1 = 1;

## Finding customers who haven’t placed an order in 2024 but did in 2023.

SELECT DISTINCT customer_id FROM orders
WHERE 
	EXTRACT(YEAR FROM order_date) = 2023
	AND
	customer_id NOT IN 
					(SELECT DISTINCT customer_id FROM orders
					WHERE EXTRACT(YEAR FROM order_date) = 2024);

## Rider Average Delivery Time: 
-- Determine each rider's average delivery time.

SELECT 
    o.order_id,
    o.order_time,
    d.delivery_time,
    d.rider_id,
    d.delivery_time - o.order_time AS time_difference,
	EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + 
	CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' ELSE
	INTERVAL '0 day' END))/60 as time_difference_insec
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered';


## Segment customers into 'Gold' or 'Silver' groups based on their total spending 
-- compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
-- label them as 'Gold'; otherwise, label them as 'Silver'. Write an SQL query to determine each segment's 
-- total number of orders and total revenue

-- cx total spend
-- aov
-- gold
-- silver
-- each category and total orders and total rev

SELECT 
	cx_category,
	SUM(total_orders) as total_orders,
	SUM(total_spent) as total_revenue
FROM

	(SELECT 
		customer_id,
		SUM(total_amount) as total_spent,
		COUNT(order_id) as total_orders,
		CASE 
			WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM orders) THEN 'Gold'
			ELSE 'silver'
		END as cx_category
	FROM orders
	group by 1
	) as t1
GROUP BY 1;

## Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

SELECT 
	d.rider_id,
	TO_CHAR(o.order_date, 'mm-yy') as month,
	SUM(total_amount) as revenue,
	SUM(total_amount)* 0.08 as riders_earning
FROM orders as o
JOIN deliveries as d
ON o.order_id = d.order_id
GROUP BY 1, 2
ORDER BY 1, 2;

## Customer Lifetime Value (CLV): 
-- Calculate the total revenue generated by each customer over all their orders.

SELECT 
	o.customer_id,
	c.customer_name,
	SUM(o.total_amount) as CLV
FROM orders as o
JOIN customers as c
ON o.customer_id = c.customer_id
GROUP BY 1, 2;

## Monthly Sales Trends: 
-- Identify sales trends by comparing each month's total sales to the previous month.

SELECT 
	EXTRACT(YEAR FROM order_date) as year,
	EXTRACT(MONTH FROM order_date) as month,
	SUM(total_amount) as total_sale,
	LAG(SUM(total_amount), 1) OVER(ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) as prev_month_sale
FROM orders
GROUP BY 1, 2;


## Track the popularity of specific order items over time and identify seasonal demand spikes.

SELECT 
	order_item,
	seasons,
	COUNT(order_id) as total_orders
FROM 
(
SELECT 
		*,
		EXTRACT(MONTH FROM order_date) as month,
		CASE 
			WHEN EXTRACT(MONTH FROM order_date) BETWEEN 4 AND 6 THEN 'Spring'
			WHEN EXTRACT(MONTH FROM order_date) > 6 AND 
			EXTRACT(MONTH FROM order_date) < 9 THEN 'Summer'
			ELSE 'Winter'
		END as seasons
	FROM orders
) as t1
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

## Rank each city based on the total revenue for last year 2023 

SELECT 
	r.city,
	SUM(total_amount) as total_revenue,
	RANK() OVER(ORDER BY SUM(total_amount) DESC) as city_rank
FROM orders as o
JOIN
restaurants as r
ON o.restaurant_id = r.restaurant_id
GROUP BY 1;

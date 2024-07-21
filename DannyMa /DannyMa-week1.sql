/* Danny wants to analyze customer data to understand their visiting patterns, 
--spending habits, and favorite menu items. This will help him deliver a more 
personalized experience and decide on expanding the customer loyalty program. 
He also needs assistance in generating basic datasets for his team to inspect 
without using SQL. Due to privacy concerns, he has provided a sample of the overall 
customer data, hoping it's sufficient for creating fully functional SQL queries to 
answer his questions. */

--Load file in PostgreSQL 

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


/* Case Study Questions */

-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(mn.price)
FROM dannys_diner.sales s
JOIN dannys_diner.menu mn
ON mn.product_id = s.product_id
GROUP BY 1;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,
		COUNT(EXTRACT(DAY FROM order_date))
FROM
	(SELECT customer_id, order_date, COUNT(order_date) AS order_count
	FROM dannys_diner.sales
	GROUP BY 1,2
	ORDER BY 1) multiple_day_count
GROUP BY 1;

-- 3. What was the first item from the menu purchased by each customer?
SELECT DISTINCT customer_id,
		order_date
FROM dannys_diner.sales
ORDER BY 2,1
LIMIT 3;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT s.product_id,
		product_name,
		COUNT(s.product_id) qty 
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
SELECT customer_id, product_id, count(customer_id)
FROM dannys_diner.sales
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 3;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT t1.customer_id, t1.product_id
FROM
	(SELECT s.customer_id, 
		s.order_date, 
		s.product_id,
		ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS row_num	
	FROM dannys_diner.sales s
	JOIN dannys_diner.members m
	ON s.customer_id=m.customer_id AND 
	s.order_date > m.join_date + INTERVAL '0 days') t1
WHERE t1.row_num = 1
GROUP BY 1,2;



-- 7. Which item was purchased just before the customer became a member?
SELECT m.customer_id, 
		s.order_date,
		m.join_date,
		s.product_id,
		m.join_date - s.order_date AS diff,
		RANK() OVER (PARTITION BY m.customer_id ORDER BY m.join_date - s.order_date) AS rank
FROM dannys_diner.sales s
JOIN dannys_diner.members m
ON m.customer_id=s.customer_id AND m.join_date > s.order_date
ORDER BY diff
LIMIT 3;

		
 
-- 8. What is the total items and amount spent for each member before they became a member?
SELECT m.customer_id, SUM(price)
FROM dannys_diner.members m
FULL OUTER JOIN dannys_diner.sales s
ON m.customer_id = s.customer_id
FULL OUTER JOIN dannys_diner.menu mn
ON mn.product_id = s.product_id 
WHERE m.join_date > s.order_date
GROUP BY 1;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT customer_id, SUM(menu_points)
FROM
	
	(SELECT s.customer_id, 
			CASE WHEN m.product_name = 'sushi' THEN m.price*20 ELSE m.price*10 END menu_points

	FROM dannys_diner.menu m
	JOIN dannys_diner.sales s
	ON s.product_id = m.product_id)
GROUP BY 1;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT m.customer_id, 
		SUM(mn.price*20) menu_points
FROM dannys_diner.members m
JOIN dannys_diner.sales s
ON m.customer_id = s.customer_id 
AND s.order_date >= m.join_date 
JOIN dannys_diner.menu mn
ON mn.product_id = s.product_id
WHERE s.order_date < '2021-01-31'::date
GROUP BY 1
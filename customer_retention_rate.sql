-------------------------------------------------------------------------------------------
-- EXAMPLE NR 1
-------------------------------------------------------------------------------------------
CREATE TABLE orders2 (
    order_id     INT,
    customer_id  INT,
    order_date   DATE
);

INSERT INTO orders2 VALUES
(1,  101, '2024-01-05'),
(2,  102, '2024-01-10'),
(3,  103, '2024-01-15'),
(4,  104, '2024-01-20'),
(5,  105, '2024-01-25'),
(6,  101, '2024-02-03'),
(7,  102, '2024-02-14'),
(8,  106, '2024-02-18'),
(9,  107, '2024-02-22'),
(10, 101, '2024-03-01'),
(11, 103, '2024-03-10'),
(12, 106, '2024-03-15'),
(13, 108, '2024-03-18'),
(14, 109, '2024-03-22'),
(15, 102, '2024-04-05'),
(16, 101, '2024-04-10'),
(17, 106, '2024-04-14'),
(18, 110, '2024-04-18'),
(19, 103, '2024-05-02'),
(20, 101, '2024-05-08'),
(21, 106, '2024-05-15'),
(22, 111, '2024-05-20'),
(23, 101, '2024-06-01'),
(24, 103, '2024-06-10'),
(25, 106, '2024-06-18'),
(26, 112, '2024-06-22');


SELECT * FROM orders2

-- customer count per each month, 1 cust 1 month
WITH customer_months AS (
	SELECT 
		customer_id,
		DATE_TRUNC('month', order_date)::DATE AS active_month
	FROM orders2
	GROUP BY customer_id, DATE_TRUNC('month', order_date)::DATE
),
retention AS (
	SELECT
		COUNT(curr.customer_id) AS retained_customer,
		curr.active_month AS month
	FROM customer_months AS curr
	JOIN customer_months AS prev
		ON curr.customer_id = prev.customer_id
		AND curr.active_month = prev.active_month + INTERVAL '1 month' -- where magic happens
	GROUP BY curr.active_month
),
monthly_base AS (
	SELECT 
		COUNT(customer_id) AS total_customers,
		active_month
	FROM customer_months
	GROUP BY active_month
)
SELECT
	r.month,
	r.retained_customer,
	mb.total_customers AS total_customers,
	ROUND(
		100.0 * r.retained_customer / NULLIF(mb.total_customers, 0), 2
	) AS retention_rate
FROM retention AS r
JOIN monthly_base AS mb
	ON r.month = mb.active_month + INTERVAL '1 month'


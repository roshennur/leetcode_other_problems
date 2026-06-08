CREATE TABLE transactions (
    transaction_id  INT,
    customer_id     INT,
    amount          DECIMAL(10,2),
    transaction_date DATE
);

INSERT INTO transactions VALUES
(1,  101, 150.00, '2024-01-05'),
(2,  102, 200.00, '2024-01-12'),
(3,  103, 350.00, '2024-01-18'),
(4,  104, 100.00, '2024-01-25'),
(5,  101, 220.00, '2024-02-03'),
(6,  105, 180.00, '2024-02-10'),
(7,  102, 310.00, '2024-02-14'),
(8,  106, 90.00,  '2024-02-20'),
(9,  103, 410.00, '2024-03-05'),
(10, 107, 275.00, '2024-03-11'),
(11, 101, 190.00, '2024-03-18'),
(12, 104, 320.00, '2024-03-22'),
(13, 102, 150.00, '2024-04-04'),
(14, 108, 430.00, '2024-04-10'),
(15, 103, 280.00, '2024-04-16'),
(16, 105, 210.00, '2024-04-23'),
(17, 101, 370.00, '2024-05-02'),
(18, 109, 490.00, '2024-05-09'),
(19, 106, 160.00, '2024-05-15'),
(20, 102, 340.00, '2024-05-21'),
(21, 103, 510.00, '2024-06-03'),
(22, 110, 230.00, '2024-06-11'),
(23, 101, 290.00, '2024-06-18'),
(24, 107, 175.00, '2024-06-25');

select * from transactions;

with revenue_month as (
	select 
		SUM(amount) as revenue,
		date_trunc('month', transaction_date)::date as months
	from transactions
	group by months
)
select 
	months,
	revenue,
	LAG(revenue) over (order by months) as previous_revenue,
	ROUND(((revenue - LAG(revenue) over (order by months)) /
			nullif(LAG(revenue) over (order by months), 0)) * 100.0, 2) as mom_grwth
from revenue_month
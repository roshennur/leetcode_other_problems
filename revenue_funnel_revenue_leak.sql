CREATE TABLE events (
    event_id    INT,
    user_id     INT,
    event_type  VARCHAR(50),
    event_date  DATE
);

INSERT INTO events VALUES
(1,  101, 'page_visit',   '2024-01-01'),
(2,  102, 'page_visit',   '2024-01-01'),
(3,  103, 'page_visit',   '2024-01-02'),
(4,  104, 'page_visit',   '2024-01-02'),
(5,  105, 'page_visit',   '2024-01-03'),
(6,  106, 'page_visit',   '2024-01-03'),
(7,  107, 'page_visit',   '2024-01-04'),
(8,  108, 'page_visit',   '2024-01-04'),
(9,  101, 'sign_up',      '2024-01-01'),
(10, 102, 'sign_up',      '2024-01-01'),
(11, 103, 'sign_up',      '2024-01-02'),
(12, 104, 'sign_up',      '2024-01-03'),
(13, 105, 'sign_up',      '2024-01-03'),
(14, 106, 'sign_up',      '2024-01-04'),
(15, 101, 'add_to_cart',  '2024-01-02'),
(16, 102, 'add_to_cart',  '2024-01-02'),
(17, 103, 'add_to_cart',  '2024-01-03'),
(18, 104, 'add_to_cart',  '2024-01-04'),
(19, 101, 'purchase',     '2024-01-02'),
(20, 102, 'purchase',     '2024-01-03'),
(21, 103, 'purchase',     '2024-01-04'),
(22, 109, 'page_visit',   '2024-01-05'),
(23, 110, 'page_visit',   '2024-01-05'),
(24, 109, 'sign_up',      '2024-01-05'),
(25, 110, 'sign_up',      '2024-01-06'),
(26, 109, 'add_to_cart',  '2024-01-06'),
(27, 111, 'page_visit',   '2024-01-06'),
(28, 112, 'page_visit',   '2024-01-07'),
(29, 111, 'sign_up',      '2024-01-07'),
(30, 112, 'page_visit',   '2024-01-07');

SELECT * FROM events;

----------------------------------------------------------------------------------------------
-- REVENUE FUNNEL ANALYSIS
----------------------------------------------------------------------------------------------

WITH stage AS (
	SELECT
		COUNT(DISTINCT CASE WHEN event_type = 'page_visit' THEN user_id END) AS page_visit_nr,
		COUNT(DISTINCT CASE WHEN event_type = 'sign_up' THEN user_id END) AS signup_nr,
		COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS add_to_cart_nr,
		COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase_nr
	FROM events
)
select 
	'Page visit' as stage,
	page_visit_nr as customer_nr,
	ROUND(100.0 * page_visit_nr / page_visit_nr, 2) as conversion_rate
from stage
union all
select 
	'Sign up',
	signup_nr,
	ROUND(100.0 * signup_nr / page_visit_nr, 2)
from stage
union all
select 
	'Added to cart',
	add_to_cart_nr,
	ROUND(100.0 * add_to_cart_nr / signup_nr, 2)
from stage
union all
select 
	'Purchase',
	purchase_nr,
	ROUND(100.0 * purchase_nr / signup_nr, 2)
from stage;


----------------------------------------------------------------------------------------------
-- REVENUE LEAK
----------------------------------------------------------------------------------------------


with stages as (
	select
		count(distinct case when event_type = 'page_visit' then user_id end) as page_visit_nr,
		count(distinct case when event_type = 'sign_up' then user_id end) as signup_nr,
		count(distinct case when event_type = 'add_to_cart' then user_id end) as add_to_cart_nr,
		count(distinct case when event_type = 'purchase' then user_id end) as purchase_nr
	from events
), 
funnels as (
    SELECT 
		'Page visit' AS stage, 
		page_visit_nr AS users, 
		NULL AS prev_users 
	FROM stages
    UNION ALL
    SELECT 
		'Sign up',               
		sign_up_nr,              
		page_visit_nr              
	FROM stages
    UNION ALL
    SELECT 
		'Add to cart',           
		add_to_cart_nr,          
		sign_up_nr                 
	FROM stages
    UNION ALL
    SELECT 
		'Purchase',              
		purchase_nr,             
		add_to_cart_nr             
	FROM stages
)
SELECT 
	stage,
	users,
	ROUND(100.0 * users / NULLIF(prev_users, 0), 2) AS conversion_rate,
	ROUND(100.0 - users * 100.0 / NULLIF(prev_users, 0), 2)  AS revenue_leak
FROM funnels

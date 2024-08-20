use mavenfuzzyfactory;


-- Analyzing top traffic sources
SELECT website_sessions.utm_content, COUNT(DISTINCT website_sessions.website_session_id) AS sessions, 
COUNT(DISTINCT orders.order_id) AS orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_cnv_rt
FROM website_sessions
LEFT JOIN orders ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000 -- arbitary
GROUP BY 1
ORDER BY 2 DESC;

-- Finding top traffic sources
-- Breakdown of the website sessions by UTM source, campaign and referring domain
SELECT utm_source, utm_campaign, http_referer, COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at<'2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;

-- Traffic Source Conversion
-- Calculating the conversion rate(CVR) from session to order
SELECT COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_cnv_rt
FROM website_sessions
LEFT JOIN orders ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at<'2012-04-14' AND website_sessions.utm_source='gsearch' AND website_sessions.utm_campaign='nonbrand';

-- Bid Analysis and Trend Analysis
-- Bid Optimization is about understanding the value of various segments of paid traffic so that you can optimize the marketing budget
SELECT MONTH(created_at), WEEK(created_at), MIN(DATE(created_at)) AS start_date, COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000 -- arbitary
GROUP BY 1, 2;

-- Pivoting Data with Count and Case
SELECT order_id, primary_product_id, items_purchased, created_at
FROM orders
WHERE order_id BETWEEN 31000 AND 32000;

SELECT primary_product_id,
COUNT(DISTINCT CASE WHEN items_purchased=1 THEN order_id ELSE NULL end) AS orders_w_1_items,
COUNT(DISTINCT CASE WHEN items_purchased=2 THEN order_id ELSE NULL end) AS orders_w_2_items,
COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;

-- Traffic source Trending
-- Gsearch nonbranded trended session volume by week
SELECT MIN(DATE(created_at)) as week_start_date, COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at<'2012-05-10' AND utm_source='gsearch' AND utm_campaign='nonbrand'
GROUP BY WEEK(created_at);

-- Bid Optimization for Paid Traffic
-- Conversion rates from session to order by device type
SELECT website_sessions.device_type,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_orders_cnv_rate
FROM website_sessions
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at<'2012-05-11' AND utm_source='gsearch' AND utm_campaign='nonbrand'
GROUP BY website_sessions.device_type;

-- Trending w/ Granular Segments
-- Weekly trends for both desktop and mobile
SELECT MIN(DATE(created_at)) AS week_start_date,
COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) AS mob_sessions,
COUNT(DISTINCT CASE WHEN device_type='desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions
FROM website_sessions
WHERE DATE(created_at) BETWEEN '2012-04-15' and '2012-06-09' AND utm_source='gsearch' AND utm_campaign='nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at);

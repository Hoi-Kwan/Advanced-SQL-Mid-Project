-- task 1
-- gsearch' seem to be the biggest driver of our business. 
-- task 1 is to pull monthly trends for 'gsearch' sessions and orders

select 
	year(ws.created_at) as yr,
	month(ws.created_at) as mo,
	count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id) / count(distinct ws.website_session_id) as conv_rt
from website_sessions ws
	left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27'
	and ws.utm_source = 'gsearch'
group by 1, 2;


-- task 1 results
yr	mo	sessions	orders	conv_rt
2012	3	1860		60	0.0323
2012	4	3574		92	0.0257
2012	5	3410		97	0.0284
2012	6	3578		121	0.0338
2012	7	3811		145	0.0380
2012	8	4877		184	0.0377
2012	9	4491		188	0.0419
2012	10	5534		234	0.0423
2012	11	8889		373	0.0420

-- sessions, orders, conversion rate have increased over the 8 months









-- task 2
-- monthly trends for 'gsearch' sessions and orders, but this time splitting out nonbrand and brand campaign separately

select 
	year(ws.created_at) as yr,
    month(ws.created_at) as mo,
	count(distinct case when ws.utm_campaign = 'nonbrand' then ws.website_session_id else null end) as nonbrand_sessions,
    count(distinct case when ws.utm_campaign = 'nonbrand' then o.order_id else null end) as nonbrand_orders,
    count(distinct case when ws.utm_campaign = 'brand' then ws.website_session_id else null end) as brand_sessions,
    count(distinct case when ws.utm_campaign = 'brand' then o.order_id else null end) as brand_orders
from website_sessions ws
	left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27'
	and ws.utm_source = 'gsearch'
group by 1, 2;


-- task 2 results
yr	mo	nonbrand_sessions	nonbrand_orders	brand_sessions	brand_orders
2012	3	1852			60		8		0
2012	4	3509			86		65		6
2012	5	3295			91		115		6
2012	6	3439			114		139		7
2012	7	3660			136		151		9
2012	8	4673			174		204		10
2012	9	4227			172		264		16
2012	10	5197			219		337		15
2012	11	8506			356		383		17

-- the result shows that the major sources of sessions and orders are coming from 'gsearch nonbrand' campaign









-- task 3
-- pulling out monthly sessions and orders split by device type
select 
	year(ws.created_at) as yr,
    month(ws.created_at) as mo,
	count(distinct case when ws.device_type = 'desktop' then ws.website_session_id else null end) as desktop_sessions,
	count(distinct case when ws.device_type = 'desktop' then o.order_id else null end) as desktop_orders,
    count(distinct case when ws.device_type = 'mobile' then ws.website_session_id else null end) as mobile_sessions,
	count(distinct case when ws.device_type = 'mobile' then o.order_id else null end) as mobile_orders
from website_sessions ws
	left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27'
	and ws.utm_source = 'gsearch'
    and ws.utm_campaign = 'nonbrand'
group by 1, 2;


-- task 3 results
yr	mo	desktop_sessions	desktop_orders	mobile_sessions	mobile_orders
2012	3	1128			50		724		10
2012	4	2139			75		1370		11
2012	5	2276			83		1019		8
2012	6	2673			106		766		8
2012	7	2774			122		886		14
2012	8	3515			165		1158		9
2012	9	3171			155		1056		17
2012	10	3934			201		1263		18
2012	11	6457			323		2049		33

-- there are more sessions and orders coming from desktop then mobile device









-- task 4
-- monthly sessions and orders for 'Gsearch' and other channels
select 
	distinct utm_source,
    utm_campaign,
    http_referer
from website_sessions
where created_at < '2012-11-27';


select 
	year(ws.created_at) as yr,
    month(ws.created_at) as mo,
	count(distinct case when ws.utm_source = 'gsearch' then ws.website_session_id else null end) as gsearch_paid_sessions,
    count(distinct case when ws.utm_source = 'bsearch' then ws.website_session_id else null end) as bsearch_paid_sessions,
    count(distinct case when ws.utm_source is null and ws.http_referer is not null then ws.website_session_id else null end) as organic_search_sessions,
    count(distinct case when ws.utm_source is null and ws.http_referer is null then ws.website_session_id else null end) as direct_search_sessions
from website_sessions ws
	left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27'
group by 1, 2;


-- task 4 results
yr	mo	gsearch_paid_sessions	bsearch_paid_sessions	organic_search_sessions	direct_search_sessions
2012	3	1860			2			8			9
2012	4	3574			11			78			71
2012	5	3410			25			150			151
2012	6	3578			25			190			170
2012	7	3811			44			207			187
2012	8	4877			705			265			250
2012	9	4491			1439			331			285
2012	10	5534			1781			428			440
2012	11	8889			2840			536			485

-- the result shows that almost all the traffic was coming from 'gsearch' at the beginning
-- over the 8 months, the traffic from the other three channels has increased.









-- task 5
-- session to order conversion rate, by month

select
	year(ws.created_at) as yr,
    month(ws.created_at) as mo,
    count(distinct o.order_id) / count(distinct ws.website_session_id) as conv_rt
from website_sessions ws
	left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27'
group by 1, 2;


-- task 5 result
yr		mo	conv_rt
2012	3	0.0319
2012	4	0.0265
2012	5	0.0289
2012	6	0.0353
2012	7	0.0398
2012	8	0.0374
2012	9	0.0438
2012	10	0.0453
2012	11	0.0440

-- the conversion rate was generally increasing over the 8 month period









-- task 6
-- for the gsearch lander test, please estimate the revenue that test earned 

select
	min(website_pageview_id)
from website_pageviews
where pageview_url = '/lander-1';
-- min_pageview_id = 23504

create temporary table first_test_pageviews
select
	ws.website_session_id,
    min(wp.website_pageview_id) as min_pageview_id
from website_sessions ws
    left join website_pageviews wp on ws.website_session_id = wp.website_session_id
where ws.utm_source = 'gsearch'
    and ws.utm_campaign = 'nonbrand'
    and wp.website_pageview_id >= 23504
	and ws.created_at < '2012-07-28'
group by ws.website_session_id;


create temporary table landing_pages
select 
	ftp.website_session_id,
    wp.pageview_url
from first_test_pageviews ftp
	left join website_pageviews wp on ftp.min_pageview_id = wp.website_pageview_id
where wp.pageview_url in ('/home', '/lander-1');

-- select * from landing_pages;

create temporary table landing_pages_w_orders
select 
	lp.website_session_id,
    lp.pageview_url,
    o.order_id
from landing_pages lp
	left join orders o on lp.website_session_id = o.website_session_id;
    
    
select 
	pageview_url as landing_page,
    count(distinct website_session_id) as sessions,
    count(distinct order_id) as orders,
    count(distinct order_id) / count(distinct website_session_id) as conv_rt
from landing_pages_w_orders
group by 1;
-- /home has a conversion rate of 3.18%, and /lander-1 has a conversion rate of 4.06%
-- thus, conversion rate improved 0.88%


select 
	max(ws.website_session_id) as most_recent_session_id
from website_sessions ws
	left join website_pageviews wp on ws.website_session_id = wp.website_session_id
where ws.utm_source = 'gsearch'
	and ws.utm_campaign = 'nonbrand'
    and wp.pageview_url = '/home'
    and ws.created_at < '2012-11-27';
    
-- most recent session id = 17145


select
	count(website_session_id)
from website_sessions ws
where ws.utm_source = 'gsearch'
	and ws.utm_campaign = 'nonbrand'
    and ws.website_session_id > 17145
    and ws.created_at < '2012-11-27';
    
-- 22972 website session since the test
-- 22972 * 0.88% = 202 incremental orders over the 4 months









-- task 7
/* for the landing page analysed in the previous task, this task is to
show a full conversion funnel from each of the two pages to orders
(for the period of 06/19 - 07/28) */

create temporary table session_level
select 
	website_session_id,
    max(home) as home_pageviews,
    max(lander_1) as lander1_pageviews,
    max(product) as product_pageviews,
    max(mrfuzzy) as mrfuzzy_pageviews,
    max(cart) as cart_pageviews,
    max(shipping) as shipping_pageviews,
    max(billing) as billing_pageviews,
    max(orders) as order_pageviews
from 
(
select 
	ws.website_session_id,
    wp.pageview_url,
    case when pageview_url = '/home' then 1 else 0 end as home,
    case when pageview_url = '/lander-1' then 1 else 0 end as lander_1,
    case when pageview_url = '/products' then 1 else 0 end as product,
	case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy,
    case when pageview_url = '/cart' then 1 else 0 end as cart,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping,
    case when pageview_url = '/billing' then 1 else 0 end as billing,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as orders
from website_sessions ws
	left join website_pageviews wp on ws.website_session_id = wp.website_session_id
where ws.created_at > '2012-06-19'
	and ws.created_at < '2012-07-28'
	and ws.utm_source = 'gsearch'
    and ws.utm_campaign = 'nonbrand'
group by 1, 2
) as pageview_level
group by 1;



select
	case 
		when home_pageviews = 1 then '/home'
        when lander1_pageviews = 1 then '/lander-1'
        else null
	end as url,
	count(distinct website_session_id) as sessions,
    count(distinct case when product_pageviews = 1 then website_session_id else null end) as product,
    count(distinct case when mrfuzzy_pageviews = 1 then website_session_id else null end) as mrfuzzy,
    count(distinct case when cart_pageviews = 1 then website_session_id else null end) as cart,
    count(distinct case when shipping_pageviews = 1 then website_session_id else null end) as shipping,
    count(distinct case when billing_pageviews = 1 then website_session_id else null end) as billing,
    count(distinct case when order_pageviews = 1 then website_session_id else null end) as orders
from session_level
group by url;



-- task 7 result
url		sessions	product	mrfuzzy	cart	shipping	billing	orders
/home		2261		942	684	296	200		168	72
/lander-1	2316		1083	772	348	231		197	94










-- task 8
-- quantifying the impact of the billing test
-- 1. analyse the lift generated from the test 09/10 - 10/10, in terms of revenue per billing page session
-- 2. pull the number of billing page sessions for the past month to understnad monthly impact

select
	pageview_url,
    count(distinct website_session_id) as sessions,
    sum(price_usd)/count(distinct website_session_id) as revenue_per_page
from 
	(select
		wp.website_session_id,
		wp.pageview_url,
		o.price_usd
	from website_pageviews wp
		left join orders o on wp.website_session_id = o.website_session_id
	where wp.pageview_url in ('/billing', '/billing-2')
		and wp.created_at > '2012-09-10'
        and wp.created_at < '2012-11-10') as pageview_level
group by pageview_url;



-- task 8.1 result
pageview_url	sessions	revenue_per_page
/billing		657			22.826484
/billing-2		654			31.339297
-- /billing has a ~22.83 revenue per billing page
-- /billing-2 has a ~31.34 revenue per billing page
-- lift 8.51 per billing session




select 
	count(website_session_id) as sessions
from website_pageviews
where created_at between '2012-10-27' and '2012-11-27' -- past month
    and pageview_url in ('/billing', '/billing-2');

-- task 8.2 result
sessions
1193

-- 1193 sessions last month
-- lift 8.51 per billing session
-- total value of billing test = 10152 over the last month

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
url			sessions	product	mrfuzzy	cart	shipping	billing	orders
/home		2261		942		684		296		200			168		72
/lander_1	2316		1083	772		348		231			197		94








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



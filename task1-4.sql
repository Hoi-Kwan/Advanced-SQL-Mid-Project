/* Maven Fuzzy has been live for ~8 months, and CEO is due to present
company performance metrics to the board next week. I am the one tasked 
with preparing relevant metrics to show the company's promising growth */


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
yr		mo	sessions	orders	conv_rt
2012	3	1860		60		0.0323
2012	4	3574		92		0.0257
2012	5	3410		97		0.0284
2012	6	3578		121		0.0338
2012	7	3811		145		0.0380
2012	8	4877		184		0.0377
2012	9	4491		188		0.0419
2012	10	5534		234		0.0423
2012	11	8889		373		0.0420
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
yr		mo	nonbrand_sessions	nonbrand_orders	brand_sessions	brand_orders
2012	3	1852				60				8				0
2012	4	3509				86				65				6
2012	5	3295				91				115				6
2012	6	3439				114				139				7
2012	7	3660				126				151				9
2012	8	4673				174				204				10
2012	9	4227				172				264				16
2012	10	5197				219				337				15
2012	11	8506				356				383				17

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
yr		mo	desktop_sessions	desktop_orders	mobile_sessions	mobile_orders
2012	3	1128				50				724				10
2012	4	2139				75				1370			11
2012	5	2276				83				1019			8
2012	6	2673				106				766				8
2012	7	2774				122				886				14
2012	8	3515				165				1158			9
2012	9	3171				155				1056			17
2012	10	3934				201				1263			18
2012	11	6457				323				2049			33
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
yr		mo	gsearch_paid_sessions	bsearch_paid_sessions	organic_search_sessions	direct_search_sessions
2012	3	1860					2						8						9
2012	4	3574					11						78						71
2012	5	3410					25						150						151
2012	6	3578					25						190						170
2012	7	3811					44						207						187
2012	8	4877					705						265						250
2012	9	4491					1439					331						285
2012	10	5534					1781					428						440
2012	11	8889					2840					536						485


-- the result shows that almost all the traffic was coming from 'gsearch' at the beginning
-- over the 8 months, the traffic from the other three channels has increased.




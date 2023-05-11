/*B. Runner and Customer Experience*/

/*How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)*/

select  weekofyear(registration_date+interval 1 week), count(runner_id)
from runners
group by 1;

/*What was the average time in minutes it took for each runner to arrive 
at the Pizza Runner HQ to pickup the order?*/

select runner_id, avg(minute(timediff(pickup_time, order_time))) as avg_time
from customer_orders co
join runner_orders ro on co.order_id=ro.order_id 
group by runner_id;

/*Is there any relationship between the number of pizzas and how long the order takes to prepare?*/

with cte as
(select co.order_id, order_time, pickup_time,
	minute(timediff(pickup_time, order_time)) as preparation_time, 
	count(pizza_id) as pizza_count
from customer_orders co
join runner_orders ro on co.order_id=ro.order_id 
group by 1,2,3,4)

select pizza_count, avg(preparation_time)
from cte
group by pizza_count;

/*What was the average distance travelled for each customer?*/

select customer_id, avg(distance) as avg_dist_travelled
from customer_orders co
join runner_orders ro on co.order_id=ro.order_id 
group by customer_id;

/*What was the difference between the longest and shortest delivery times for all orders?*/

select max(duration) as max_duration, min(duration) as min_duration,
	max(duration)-min(duration) as difference
from runner_orders;
  
/*What was the average speed for each runner for each delivery and 
do you notice any trend for these values?*/  

select runner_id, 	round((distance*60/duration),1) as speed, 
	round(avg(distance*60/duration) over(partition by runner_id),2) as avg_speed
from runner_orders;

/*What is the successful delivery percentage for each runner?*/ 

with cte as
(select runner_id, 
sum(case when cancellation is not NULL then 1 else 0 end) as cancelled_order,
sum(case when cancellation is NULL then 1 else 0 end) as delivered_order
from runner_orders
group by runner_id)

select runner_id, cancelled_order, delivered_order, 
	round((delivered_order/(delivered_order+cancelled_order))*100,1) as succesful_delivery_prcnt
from cte;

/*A. Pizza Metrics*/

/*How many pizzas were ordered?*/
select count(order_id) 
from customer_orders;

/*How many unique customer orders were made?*/
select count(distinct customer_id) 
from customer_orders;

/*How many successful orders were delivered by each runner?*/
select runner_id, sum(case when cancellation is null then 1 else 0 end) 
from runner_orders
group by runner_id;

/*How many of each type of pizza was delivered?*/
select pizza_id, count(pizza_id) 
from customer_orders co
join runner_orders ro on co.order_id=ro.order_id
where cancellation is null
group by pizza_id;

/*How many Vegetarian and Meatlovers were ordered by each customer?*/
select customer_id, co.pizza_id, pizza_name, count(co.pizza_id) 
from customer_orders co
join pizza_names pn on co.pizza_id=pn.pizza_id
group by customer_id, co.pizza_id, pizza_name
order by customer_id;

/*What was the maximum number of pizzas delivered in a single order?*/
with cte as
(select co.order_id, count(co.order_id) as pizza_count
from customer_orders co
join runner_orders ro on co.order_id=ro.order_id
where cancellation is null
group by co.order_id)

select max(pizza_count)
from cte;

/*For each customer, how many delivered pizzas had at least 1 change 
and how many had no changes?*/
select customer_id, sum(case when exclusions is null and extras is null then 1 else 0 end) as no_change_count,
	sum(case when exclusions is not null or extras is not null then 1 else 0 end) as change_count
from customer_orders co
join runner_orders ro on co.order_id=ro.order_id
where cancellation is null
group by customer_id;

/*How many pizzas were delivered that had both exclusions and extras?*/
select sum(case when exclusions is not null and extras is not null then 1 else 0 end) 
from customer_orders co
join runner_orders ro on co.order_id=ro.order_id
where cancellation is null;

/*What was the total volume of pizzas ordered for each hour of the day?*/
select hour(order_time) as time, count(hour(order_time)) as pizza_vol
from customer_orders
group by time
order by pizza_vol desc;

/*What was the volume of orders for each day of the week?*/
select dayname(order_time) as day, count(dayname(order_time)) as pizza_vol
from customer_orders
group by day
order by pizza_vol desc;

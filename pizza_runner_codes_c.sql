/*C.  Ingredient Optimisation*/

/*What are the standard ingredients for each pizza?*/

with recursive cte as
(select *
from pizza_recipes
union all 
select pizza_id, regexp_replace(toppings,'^[^,]*,','') toppings
from cte 
where toppings like '%,%'),

cte2 as
(select pizza_id, trim(regexp_replace(toppings,',.*','')) toppings
from cte
order by pizza_id),

cte3 as
(select *
from cte2
join pizza_toppings pt on cte2.toppings=pt.topping_id)

select pizza_id, group_concat(topping_name) as standard_ingredients
from cte3
group by pizza_id;

/*What was the most commonly added extra?*/

with recursive cte as
(select extras
from customer_orders
union all 
select regexp_replace(extras,'^[^,]*,','') extras
from cte 
where extras like '%,%'),

cte2 as
(select trim(regexp_replace(extras,',.*','')) extras, count(extras) as count
from cte
where extras is not NULL
group by 1
order by extras)

select cte2.extras, count, topping_name
from cte2
join pizza_toppings pt on cte2.extras=pt.topping_id;

/*What was the most common exclusion?*/

with recursive cte as
(select exclusions
from customer_orders
union all 
select regexp_replace(exclusions,'^[^,]*,','') exclusions
from cte 
where exclusions like '%,%'),

cte2 as
(select trim(regexp_replace(exclusions,',.*','')) exclusions, count(exclusions) as count
from cte
where exclusions is not NULL
group by 1
order by count desc)

select cte2.exclusions, count, topping_name
from cte2
join pizza_toppings pt on cte2.exclusions=pt.topping_id;

/*Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/

with recursive cte as
(select order_id, customer_id, pizza_id, exclusions, extras
from customer_orders
union all 
select order_id, customer_id, pizza_id, regexp_replace(exclusions,'^[^,]*,','') exclusions, 
	regexp_replace(extras,'^[^,]*,','') extras
from cte 
where exclusions like '%,%' and extras like '%,%'),

cte2 as
(select order_id, customer_id, pizza_id, 
	trim(regexp_replace(exclusions,',.*','')) exclusions, trim(regexp_replace(extras,',.*','')) extras
from cte)

select order_id, customer_id, pizza_name, 
	group_concat(case when exclusions is not null then topping_name end)exclusions,
	group_concat(case when extras is not null then topping_name end) extras
from cte2
left join pizza_toppings pt on cte2.exclusions=pt.topping_id
	or cte2.extras=pt.topping_id
join pizza_names pn on cte2.pizza_id=pn.pizza_id
group by 1,2,3

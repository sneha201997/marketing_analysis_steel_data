/*cleaning customer_orders table*/

select * 
from customer_orders;

update customer_orders
set exclusions= case when exclusions='' or exclusions like '%null%' then null
					 else exclusions
                end;
update customer_orders
set extras= case when extras='' or extras like '%null%' then null
					 else extras
                end; 
                
select * 
from customer_orders;

/*cleaning runner_orders table*/
select * 
from runner_orders;

update runner_orders
set cancellation= case when cancellation='' or cancellation like '%null%' then null
					 else cancellation
                end;
                
update runner_orders
set pickup_time = case when pickup_time like '%null%' then null
					   else pickup_time
                  end;

update runner_orders
set distance = case when distance like '%null%' then null
					when distance like '%km' then replace(distance,'km','')
					else distance
               end;                                

update runner_orders
set duration = case when duration like '%null%' then null
					when duration like '%minutes' then replace(duration,'minutes','')
                    when duration like '%mins' then replace(duration,'mins','')
                    when duration like '%minute' then replace(duration,'minute','')
					else duration
               end; 
          
          


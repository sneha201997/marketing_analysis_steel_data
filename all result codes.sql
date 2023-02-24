/*list of markets in which customer "Atliq Exclusive" operates its business in the APAC region*/

select distinct market from dim_customer
where customer = "Atliq Exclusive" and region = "APAC" ;

/*percentage of unique product increase in 2021 vs. 2020*/

with cte1 as (select count(distinct product_code) as unique_product_2020
from fact_sales_monthly
where fiscal_year="2020"),
cte2 as (select count(distinct product_code) as unique_product_2021
from fact_sales_monthly
where fiscal_year="2021")

select unique_product_2020, unique_product_2021, 
round(((unique_product_2021-unique_product_2020)/unique_product_2020)*100,2)as percentage_chg from cte1, cte2;

/* all the unique product counts for each segment */

select segment, count(distinct product_code) as product_count
from dim_product
group by segment
order by product_count desc;

/* segment had the most increase in unique products in 2021 vs 2020 */

with cte as (select dm.segment, count(distinct case when fsm.fiscal_year=2020 then dm.product_code end) as product_count_2020,
 count(distinct case when fsm.fiscal_year=2021 then dm.product_code end) as product_count_2021
from dim_product dm 
join fact_sales_monthly fsm on dm.product_code=fsm.product_code
group by segment)

select *, (product_count_2021-product_count_2020) as difference from cte
order by difference desc;

/* products that have the highest and lowest manufacturing costs */

select dm.product_code, product, manufacturing_cost
from dim_product dm
join fact_manufacturing_cost fmc on fmc.product_code=dm.product_code
where manufacturing_cost= (select min(manufacturing_cost) from fact_manufacturing_cost)
union
select dm.product_code, product, manufacturing_cost
from dim_product dm
join fact_manufacturing_cost fmc on fmc.product_code=dm.product_code
where manufacturing_cost= (select max(manufacturing_cost) from fact_manufacturing_cost);

/* top 5 customers who received an average high pre_invoice_discount_pct for the 
fiscal year 2021 and in the Indian market */

select dc.customer_code, customer, round((avg(pre_invoice_discount_pct)*100),2) as avg_discount_percentage
from dim_customer dc
join fact_pre_invoice_deductions fpid on fpid.customer_code=dc.customer_code
where fiscal_year=2021 and market="India"
group by dc.customer_code, customer
order by avg_discount_percentage desc
limit 5;

/* Gross sales amount for the customer “Atliq Exclusive” for each month */

select month(date) as Month, year(date) as Year, round((sum(fgp.gross_price*fsm.sold_quantity)),2) as Gross_sales_Amount 
from fact_gross_price fgp
join fact_sales_monthly fsm on fsm.product_code=fgp.product_code
join dim_customer dm on fsm.customer_code=dm.customer_code
where customer="Atliq Exclusive"
group by Month, Year
order by Year;

/* In which quarter of 2020, got the maximum total_sold_quantity */

select case when month(date) in (9,10,11) then "Quarter1"
			when month(date) in (12,1,2) then "Quarter2"
            when month(date) in (3,4,5) then "Quarter3"
            else "Quarter4"
       end as Quarter  , sum(sold_quantity) as total_sold_quantity 
from fact_sales_monthly
where fiscal_year="2020"
group by Quarter
order by total_sold_quantity desc;

/* Which channel helped to bring more gross sales in the fiscal year 2021 and 
the percentage of contribution */

with cte as (select channel, sum(fgp.gross_price*fsm.sold_quantity) as gross_sale
from fact_gross_price fgp
join fact_sales_monthly fsm on fsm.product_code=fgp.product_code
join dim_customer dm on fsm.customer_code=dm.customer_code
where fsm.fiscal_year="2021"
group by channel)

select channel, round((gross_sale/1000000),2) as gross_sale_mln,
round(((gross_sale/sum(gross_sale)over())*100),2) as percentage from cte
order by gross_sale_mln desc;

/* Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021 */

with cte1 as (select division, fsm.product_code, product, sum(sold_quantity) as total_sold_quantity
from fact_sales_monthly fsm
join dim_product dp on dp.product_code=fsm.product_code
where fiscal_year="2021" 
group by division, fsm.product_code, product),
cte2 as (select *, 
			rank() over(partition by division order by total_sold_quantity desc) as rank_order from cte1)

select * from cte2 
where  rank_order <= 3;           





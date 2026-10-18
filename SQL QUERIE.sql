CREATE TABLE store (
    Transaction_ID VARCHAR(50),
    Transaction_Date DATE,
    Store_ID VARCHAR(50),
    Store_Name VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Segment VARCHAR(50),
    Employee_ID VARCHAR(50),
    Employee_Name VARCHAR(50),
    Product_ID VARCHAR(50),
    Product VARCHAR(50),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Quantity NUMERIC(10,2),
    Unit_Price NUMERIC(10,2),
    Discount NUMERIC(6,4),
    Sales NUMERIC(12,2),
    Cost NUMERIC(12,2),
    Profit NUMERIC(12,2),
    Payment_Method VARCHAR(50),
    Order_Status VARCHAR(50),
    Sales_Channel VARCHAR(50),
    Profit_Margin NUMERIC(6,4),
    Month VARCHAR(20),
    Year INT,
    Discount_type VARCHAR(50)
);
select * from store

#BASICS OF SQL
1.Find all transactions from Mumbai.
select *
from store
where city='Mumbai'

#2.Find transactions with sales > ₹5,000.
select *
from store
where sales>5000

#3.Find cancelled transactions.
select * 
from store
where order_status='Cancelled'

#4.Find transactions with discount > 10%.
select * 
from store
where discount=0.1000

#Aggregation
select * from store

#1.Total sales?
select sum(sales) as total_sales from store
#2.Total profit?
select sum(profit) as total_profit from store
#3.Total quantity sold?
select sum(quantity) as total_quantity from store
#4.Average transaction value?
select avg(sales) as average_transaction from store
#5.Sales by store?
select sum(sales) as sales_by_store  from store
#6.Profit by category?
select category,sum(profit) as profit_by_category
from store group by category
#7.Sales by state?
select state,sum(sales) as sales_by_state from store 
group by state
#8.Profit by customer segment?
select customer_segment,sum(profit) as profit_by_customersegement from store
group by customer_segment

#CASE WHEN
select
profit,
case 
when profit>5000 then 'high profit'
when profit>2000 then 'medium profit'
else 'low profit'
end as profit_type
from store

#Date Analysis
#1.Monthly sales
select 
DATE_TRUNC('month',transaction_date) as month,
sum(sales) as monthly_sale
from store
group by DATE_TRUNC('month',transaction_date)
order by DATE_TRUNC('month',transaction_date)

#2.Monthly profit
select 
DATE_TRUNC('month',transaction_date) as month,
sum(profit) as monthly_profit
from store
group by DATE_TRUNC('month',transaction_date)
order by DATE_TRUNC('month',transaction_date)

#3.Quarterly sales
select 
DATE_TRUNC('quarter',transaction_date) as quater,
sum(sales) as monthly_profit
from store
group by DATE_TRUNC('quarter',transaction_date)
order by DATE_TRUNC('quarter',transaction_date)

#4.Monthly transaction count
select 
DATE_TRUNC('month',transaction_date) as month,
count(transaction_id) as monthly_transaction
from store
group by DATE_TRUNC('month',transaction_date) 
order by DATE_TRUNC('month',transaction_date)

#5.Monthly profit margin
select
extract(month from transaction_date) as month,
sum(profit_margin) as monthly_profit_margin
from store
group by extract(month from transaction_date)
order by extract(month from transaction_date)

#CTE
#1A.Calculate store sales
SELECT
store_id,
store_name,
sum(sales) as total_sale
from store
group by store_id,store_name

#1B.Calculate average store sales
with store_sales as(
SELECT
store_id,
store_name,
sum(sales) as total_sale
from store
group by store_id,store_name
)
select avg(total_sale) as average_store_sale
from store_sales

#1C.Find stores above average
with store_sales as(
SELECT
store_id,
store_name,
sum(sales) as total_sale
from store
group by store_id,store_name
),
average_sales as(
select avg(total_sale) as average_store_sale
from store_sales
)
select 
s.store_id,
s.store_name,
s.total_sale,
a.average_store_sale
from store_sales s
cross join average_sales a
where s.total_sale>a.average_store_sale

#2.Stores above average profit
with store_profit as(
select
store_id,
store_name,
sum(profit) as total_profit
from store
group by store_id,store_name
) , average_store as  
(select 
avg(total_profit) as average_store
from store_profit
)
select
s.store_id,
s.store_name,
s.total_profit,
a.average_store
from store_profit s
cross join average_store a
where s.total_profit>a.average_store

#3.Customers above average spending
with customer_spending as(
select
customer_id,
sum(quantity*unit_price) as total_spending
from store
group by customer_id
),
average as (
select avg(total_spending) as average
from customer_spending
)
select
c.customer_id,
c.total_spending,
a.average
from customer_spending c
cross join average a
where c.total_spending >a.average

#4.Categories above average profit margin
with category_value as
(
select 
category,
sum(profit_margin) as total_profit
from store
group by category
),
average as (
select avg(total_profit) as average_profit
from category_value
)
select
c.category,
c.total_profit,
a.average_profit
from category_value c
cross join average a
where c.total_profit>a.average_profit

#WINDOW FUNCTIONS
1.Find top products within each category.
with products as (
select
product,
category,
sum(sales) as total
from store
group by product,category
),
top_product as(
select
product,category,total,
row_number() over(
partition by category
order by total desc
) as top_products
 from products)

select * from top_product
where top_products<2

#Rank stores based on profit.
select
store_name,
sum(profit) as total,
rank() over(
order by sum(profit) desc
)
from store 
group by store_name

#Rank employees by sales.
select
employee_id,employee_name,
sum(sales) as total,
dense_rank() over(
order by sum(sales) desc
) from store
group by employee_id,employee_name

select * from store

#Compare current month's sales with previous month's sales.
with total_date as(
select
date_trunc('month',transaction_date) as month,
sum(sales) as total
from store
group by date_trunc('month',transaction_date)
),
last_month as(
select 
month,total,
lag(total) over(
order by month
) as previous_month from total_date
)

select month,total,previous_month,
round((total-previous_month)/nullif(previous_month,0)*100,2) as month_growth_per
from last_month
order by month
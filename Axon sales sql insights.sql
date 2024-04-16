use classicmodels;
select * from payment;
select * from orderdetails;
select * from orders;

-- 1) What is the average time it takes for customers to make payments after placing an order?

create temporary table Payment_Time(with cte as (select o.customernumber,o.orderdate, 
sum(od.priceeach * od.quantityordered) as total_price from orders o
join orderdetails od using (orderNumber)
where status = 'shipped'
group by o.orderNumber)
select c.customernumber,p.paymentdate, c.orderdate, datediff(p.paymentdate, c.orderdate) as timetaken_to_pay, c.total_price from cte c
join payments p
on (c.customernumber = p.customernumber)
and (c.total_price = p.amount));


select * from Payment_Time
order by customernumber, timetaken_to_pay;

select avg(timetaken_to_pay) as average_payment_Settlement_time from payment_time
where paymentdate >= orderdate;

select customernumber, avg(timetaken_to_pay) as average_payment_Settlement_time from payment_time
group by customernumber
order by average_payment_settlement_time asc;

select * from products;

-- 2) Which customers have placed orders for the greatest variety of unique products?

with cte as (select ordernumber, productcode, productname, productline, customerNumber, quantityordered 
from orders o join orderdetails od using (ordernumber)
join products using (productcode)
where status = 'shipped')
select customerNumber, count(distinct ordernumber) as no_of_orders, 
count(distinct productline) as no_of_productline, count(distinct productcode) as no_of_products,
sum(quantityordered) as total_quantity from cte
group by customerNumber
order by no_of_productline desc, no_of_products desc, total_quantity desc; 

-- 3) What is the ordering frequency for each customer?

select no_of_orders, count(customernumber) as no_of_customers from
(Select customernumber, count(ordernumber) as no_of_orders from orders
where status = 'shipped'
group by customernumber) as ordertable
group by no_of_orders
order by no_of_customers desc;

 
-- 4)what is the average number of days between each order for these customers?
with cte as 
(select customernumber,ordernumber, orderdate, lag(orderdate) over (partition by customernumber order by orderdate) as lagdate from orders),
cte1 as (select customernumber, ordernumber, orderdate, lagdate, datediff(orderdate,lagdate) as timediff from cte)
select customernumber,count(ordernumber) as no_of_orders, round(avg(timediff)) as avg_days_between_eachorders from cte1
where timediff is not null
group by customernumber
order by no_of_orders desc, avg_days_between_eachorders;

select * from customers 
where customernumber = 141;

select max(orderdate), min(orderdate) from orders;




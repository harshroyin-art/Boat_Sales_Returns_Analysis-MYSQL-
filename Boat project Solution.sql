/**************************************************************************************************************************************************************************************************************************************************************************************************************************
a) "Boat_customer" analysis:-
  1.Find the total number of customers.  **/
Select
      count(distinct customer_id) AS Total_customer
From boat_customer;

# 2.Find the total number of customers registered according to the month.
Select
      count(distinct customer_id) AS total_customer,
      monthname(registration_date) AS month_name
From boat_customer
group by monthname(registration_date);

# 3.Find the total number of customers registered according to the state.  
Select
      count(distinct customer_id) AS total_customer,
      state
from boat_customer
group by state;

# 4.What is the average age of the customer upto zero decimal place. 
Select
      round(sum(age)/count(distinct customer_id),0) AS avg_age
from boat_customer;

# 5. What is the top five products according to the sale.
/**

b) "Order_boat" analysis:-
 1. Find the total number of orders.   **/
Select
	  count(distinct order_id) AS Total_orders
from order_boat;

# 2. Find total orders according to the payment methods.
select
      count(distinct order_id) AS Total_orders,
      payment_method
From order_boat
group by payment_method;

# 3.Find the total orders according to the month names.
Select
      count(distinct order_id) AS Total_orders,
      monthname(order_date) AS Month_name
From order_boat
group by month_name;

# 4.Find the total orders according to the order channel. 
Select
      count(distinct order_id) AS Total_orders,
      order_channel
From order_boat
group by order_channel;

# 5. How many product were ordered in May, where order status is "Shipped".   
Select
      count(distinct order_id) AS Total_orders
From order_boat
where monthname(order_date) = "May"
and order_status = "Shipped";
/**
c) "Order_detail" table analysis:-
 1. Find the total number of quantities ordered.       **/
Select
      sum(quantity) AS Total_quantity
From order_detail;

# 2. Find total amount given by customers on each different product id.
Select
	  product_id,
      ((quantity)*(unit_price))*(100-(discount_percent)) AS Total_amount
From order_detail
group by product_id, Total_amount;
 /**
d) "Products" table analysis:-
1. Find the total products according to the different category.   **/
Select
      category,
      count(distinct product_id) as Total_products
from products
group by category;
      
# 2. Find the average rating for each category.
Select 
      round(sum(rating)/count(distinct product_id),2) AS Avg_rating
From products;

# 3. Find the total number of products according to the review given by the customers. 
Select
	  review,
      count(distinct product_id) as Total_products
From products
group by review;
/**
e) "Returns" table analysis:-
1. Find the total return products according to the reasons given by the customers.   **/
Select 
      reason,
      count(distinct return_id) AS Total_returns
From returns
group by reason;

# 2. Find the total returned products according to the refund status. 
Select
      refund_status,
      count(distinct return_id) AS Total_returns
From returns
group by refund_status;
/**
Complex Analysis:-

1. Find top 5 highest products as per selling price.  **/
# Solution:- Here we have connected tables 'Order_detail' and 'Products'.
Select
      d.product_id,
      p.product_name,
      round(sum((d.quantity*d.unit_price)*((100-d.discount_percent)/100)),2) AS total_revenue
From order_detail as d
Left join products as p
On d.product_id = p.product_id
group by d.product_id,p.product_name
order by total_revenue DESC
Limit 5;

#2. Find how many orders each customer placed.
#Solution:- Here we have used tables "Boat customer" and "Order boat".
Select 
      c.customer_id,
      c.name,
      c.last_name,
      count(distinct b.order_id) AS total_order
From boat_customer AS c
Left join order_boat AS b
on c.customer_id = b.customer_id
group by c.customer_id,c.name,c.last_name
order by total_order DESC;

#3. Find top 5 customers by Revenue.
/** First we will filter the "order_detail_id" from the table "amount" by comparing this table with "Returns". **/
with amount_new as (
                    Select 
                          order_id,
                          sum(total_amount) as revenue
					From amount
                    where order_detail_id Not in (Select order_detail_id 
												  From returns
                                                  where refund_status = "Processed"
                                                  or refund_status = "Approved")
					group by order_id
                    )
/** Now we will connect the tables "Amount_new", "order_boat" and " Boat_customer" to find the result.  **/
Select
      bc.customer_id,
      bc.name,
      bc.last_name,
      round(sum(an.revenue),2) as net_revenue
From amount_new as an
Left join order_boat as ob
On ob.order_id = an.order_id
inner join boat_customer as bc
On bc.customer_id = ob.customer_id
group by bc.customer_id,bc.name,bc.last_name
order by net_revenue DESC
Limit 5;

#4. Find the most sold product.
With order_detail_new as (
                          Select 
                                product_id,
                                sum(quantity) as total_quantity
						  From order_detail
                          where order_detail_id Not in (Select order_detail_id 
												        From returns
														where refund_status = "Processed"
                                                        or refund_status = "Approved")
					      group by product_id
                          )
# After filtering the data we have connected our CTE with the table 'Products'
Select
      p.product_id,
      p.product_name,
      n.total_quantity
From products as p
Left join order_detail_new as n
On n.product_id = p.product_id
order by n.total_quantity DESC
Limit 1;

# 5. Find customers who ordered more than once.
# Solution:- WE have connected tables 'Boat_customer' with 'Order_boat'.
Select 
      c.customer_id,
      c.name,
      c.last_name,
      count(distinct b.order_id) AS total_orders
from boat_customer as c
left join order_boat as b
On b.customer_id = c.customer_id
group by c.customer_id,c.name,c.last_name
having total_orders > 1
Order by total_orders desc;

# 6. Show the monthly growth (increase/decrease in revenue).
# Solution:- Monthly growth = [(current month value - previous month value)/previous month value]*100
/** First of all we will remove all those Orders from the table "Order_detail" which are going to be returned
or which are already returned using the table "Returns" and we will display order_id with their total revenue
for the orders which are not returned or not going to be returned naming this table as "order_detail_new".  **/
with order_detail_new AS (
                          Select
                                order_id,
                                round(sum((quantity*unit_price)*((100-discount_percent)/100)),2) AS revenue
						  From order_detail
                          where order_detail_id Not in (Select order_detail_id
                                                         From returns)
						  group by order_id
                          ) ,
/** Now we have merged the two tables "order_detail_new" with "order_boat" to find out the total revenue of each 
month in a serial manner and named this table to be "total_revenue". **/
total_revenue AS (
                  Select
                        monthname(b.order_date) AS months,
						year(b.order_date) AS Years,
                        month(b.order_date) AS month_num,
                        round(sum(n.revenue),2) AS net_revenue
                  From order_detail_new AS n
				  Left join order_boat AS b
                  On b.order_id = n.order_id
                  group by monthname(b.order_date),year(b.order_date),month(b.order_date)
				  order by years,month(b.order_date)
                  )
                   
/** Now we will find out the revenue growth from the table "total_revenue" by using Lag function.   **/
Select
      months,
      years,
      round(((net_revenue-Lag(net_revenue)
      Over ( partition by years order by month_num))/Lag(net_revenue)
      Over ( partition by years order by month_num)) * 100,2) AS growth_revenue
From total_revenue;
       
#7. Calculate return rate in percentage.
# Solution:-
/** Return rate in percentage = (total returned products/number of products ordered) * 100
Here we will create a CTE to find out total products ordered for every individual order id  **/
With ordered_quantity as (
                          Select
                                order_id,
                                sum(quantity) as total_orders
						  From order_detail
                          group by order_id
                          ) ,
# Here we will create another CTE to find out the products that are returned for every individual order id.
returned_quantity as (
                      Select
                            od.order_id,
                            sum(od.quantity) as total_returns
					  From returns as r
                      inner join order_detail as od
                      On r.order_detail_id = od.order_detail_id
                      group by od.order_id
                      )
# Now we will connect the tables "boat customer", "order boat", "returned quantity" and "order quantity".
Select
      bc.customer_id,
      bc.name,
      bc.last_name,
      round(((rq.total_returns/oq.total_orders) * 100),2) as return_rate
From boat_customer as bc
Left join order_boat as ob
On bc.customer_id = ob.customer_id
inner join returned_quantity as rq
On rq.order_id = ob.order_id
Left join ordered_quantity as oq
On rq.order_id = oq.order_id;

#8.Find most returned product.
/** Solution:- WE have connected the 'Returns' with 'order_detail' through inner join to fetch the common data while we have
connected 'Products' with 'Order_detail' through left join.   **/
Select
      p.product_name,
      sum(d.quantity) AS total_returned_quantity
From returns as r
inner join order_detail AS d
On d.order_detail_id = r.order_detail_id
left join products as p
On p.product_id = d.product_id
where r.refund_status = "processed"
or r.refund_status = "Approved"
group by p.product_id
order by total_returned_quantity DESC
Limit 1;
      
# 9.Which product has generated the highest revenue?
# Solution:- Here we will use table "Total_product_revenue" to find the out the product with hghest revenue.
Select * From total_product_revenue
order by total_revenue DESC
Limit 1;

# 10. Find inactive customers (no orders in last 30/60 days).
# Solution:-
# List of the customers who placed order in the last 60 days.
Select
      b.customer_id,
      c.name,
      c.last_name
From order_boat as b
Left join boat_customer AS c
On c.customer_id = b.customer_id
where b.order_date >= date((Select max(order_date) from order_boat))-interval 60 day
And b.order_date <= date((Select max(order_date) from order_boat));

# List of the customers who didn't placed any orders in the last 60 days.
Select
      customer_id,
      name,
      last_name
From boat_customer
where customer_id Not in (Select
                                b.customer_id
                         From order_boat as b
						 Left join boat_customer AS c
						 On c.customer_id = b.customer_id
						 where b.order_date >= date((Select max(order_date) from order_boat))-interval 60 day
						 And b.order_date <= date((Select max(order_date) from order_boat)));
                              
# 11. Find 2nd highest selling product with respect to the revenue generated.
# Solution:- Here we will use the table "total_product_revenue".
Select 
      product_id,
      product_name,
      total_revenue
From total_product_revenue
where total_revenue = (Select max(total_revenue)
					   From total_product_revenue
					   where total_revenue < (Select max(total_revenue) 
											  From total_product_revenue));
					   
# 12. Find customers who ordered in consecutive days.
/** Solution:- WE first create a CTE with the help of the table 'Boat_customer' and 'Order_boat' to find out the order_date
 and to fetch the next order date by using 'Lead window function' for each customers.    **/
with customer as (
                  Select 
                        c.customer_id,
                        c.name,
                        c.last_name,
                        b.order_date,
                        Lead(b.order_date)
                            over( partition by c.customer_id order by b.order_date) as next_order_date
				  from boat_customer as c
                  inner join order_boat as b
                  On b.customer_id = c.customer_id
                  group by c.customer_id,c.name,c.last_name,b.order_date
                  )
/** Now we find out those customers whose order date difference equals to '1' so which is satisfies the condition for 
consecutive days.   **/
Select
      customer_id,
      name,
      last_name
From customer
where datediff(next_order_date,order_date) = 1
group by customer_id,name,last_name;

# 13.Find customers who spent above average.
# Solution:-
select
    bc.customer_id,
	bc.name,
    bc.last_name,
    round(sum(a.total_amount),2) as total_sum
from boat_customer bc
left join order_boat ob
on bc.customer_id=ob.customer_id
join amount a
on ob.order_id=a.order_id
group by bc.name,bc.customer_id,bc.last_name
having sum(a.total_amount) > (select avg(total_amount) from amount);
                        
# 14.Find orders with maximum number of items.
# Solution:- Here we will find out that customer who has ordered the maximum numbers of items using tables "Order_detail",
# "order_boat" and "boat_customer".
Select
      ob.order_id,
      bc.customer_id,
      bc.name,
      bc.last_name,
      sum(od.quantity) as items_ordered
From order_detail as od
join order_boat as ob
ON ob.order_id = od.order_id
join boat_customer as bc
ON bc.customer_id = ob.customer_id
group by ob.order_id,bc.customer_id,bc.name,bc.last_name
order by items_ordered DESC
limit 1;
      
# 15. Find daily average sales.
# Solution:-
/** Here we will find out the average sales in terms of revenue for different days. Here first of all we will filter
the orders that are returned or going to be returned by using table "returns"   **/
with order_detail_new as (
                          Select 
                                order_id,
                                total_amount
						  From amount
                          where order_detail_id not in (Select order_detail_id
                                                        From returns
                                                        where refund_status = "Approved"
                                                        or refund_status = "Processed")
						  )
# Now we will connect the table "order_detail_new" with "order_boat".
Select
      dayname(ob.order_date) as Days,
      round(avg(od.total_amount),2) as average_sale
From order_detail_new as od
inner join order_boat as ob
On ob.order_id = od.order_id
group by Days
order by average_sale DESC;

# 16.How many products were returned in each category?
/** Solution:- Here we will connect the tables "total_product_revenue" with "Products" and will apply group by on category 
to count the product id.   **/
Select
      p.category,
      count(p.product_id) as total_returned_product
From total_product_revenue as tpr
Inner join products as p
On p.product_id = tpr.product_id
group by p.category
order by total_returned_product;

# 17. How many products were returned in February, and what were the reasons for those returns?
/** Solution:- Here we will connect two tables "products","order_detail" and "returns", use inner join to connect them applying 
group by on product_id to count the values of column 'quantity'.    **/
Select
      p.product_id,
      p.product_name,
      sum(od.quantity) as total_products,
      r.reason
From returns as r
inner join order_detail as od
On od.order_detail_id = r.order_detail_id
inner join products as p
On p.product_id = od.product_id
where monthname(r.return_date) = "February"
group by p.product_id,p.product_name,r.reason;

# 18.How many products were ordered through each order channel, and what is the total amount for each channel?
/** Solution:- First we will make a CTE from table "amount" to display total_amount, and total_products by applying group by
on order_id.   **/
with cte as (
             Select
                   order_id,
                   round(sum(total_amount),2) as net_amount,
		           sum(quantity) as total_products
			 From amount
             group by order_id
             )
# Now we will connect table "cte' with 'order_boat' and will group by on order_channel.
Select
      ob.order_channel,
      sum(c.total_products) as total_product,
      round(sum(c.net_amount),2) as total_amount
From cte as c
Inner join order_boat as ob
On c.order_id = ob.order_id
group by ob.order_channel;

# 19. Find the total revenue generated in May 2024 for each state.
# solution:- boat_customer---> State,order_boat--> order_date,amount filter apply with returns ----> total_amount
/** Let us filter the table 'Amount' usign the table 'Returns' using CTE to fetch total_amount.  **/
with cte as (
             Select 
                   order_id,
                   round(sum(total_Amount),2) as net_amount
			 From amount
             where order_detail_id not in (Select order_detail_id From returns
                                           where refund_status = "Approved"
                                           or refund_status = "Processed")
			 group by order_id
             )
# Now we will connect 'Boat_customer', 'order_boat' and 'Cte'.
Select
      bc.state,
      round(sum(c.net_amount),2) as net_revenue
From cte as c
inner join order_boat as ob
On ob.order_id = c.order_id
inner join boat_customer as bc
On bc.customer_id = ob.customer_id
where monthname(ob.order_date) = "May"
and year(ob.order_date) = 2024
group by bc.state
order by net_revenue DESC;

# 20.How many days does it take for a product to be delivered?
# Solution:- Using table 'Order_boat'
Select
      order_id,
      datediff(delivery_date,order_date) as no_of_days
From order_boat
group by order_id;

# 21. Find the total revenue by every month(monthname).
# Solution:- Here we have connected tables 'Amount' with 'Order_boat'.
select
      monthname(ob.order_date) as monthname_1,
      round(sum(a.total_amount),2) as total_revenue
From order_boat ob
Left join amount a
on ob.order_id = a.order_id
group by monthname_1,(ob.order_date)
order by month(ob.order_date);
						  
/***********************************************************************************************************************************************************************************************************************************************************************************************************************************************************/


						


					  

                      



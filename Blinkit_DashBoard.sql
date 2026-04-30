create database Blinkit_redownload;

-- data cleaning process
-- customer feedback 
select distinct feedback_id
from blinkit_customer_feedback;

select distinct customer_id
from blinkit_customer_feedback;

select distinct order_id 
from blinkit_customer_feedback;

select distinct sentiment 
from blinkit_customer_feedback;

select distinct sentiment 
from blinkit_customer_feedback;

select distinct sentiment 
from blinkit_customer_feedback;

-- customers
select distinct customer_id
from blinkit_customers;

select distinct area
from blinkit_customers;

select distinct customer_segment
from blinkit_customers;

-- delivery performance
select distinct order_id
from blinkit_delivery_performance;

select distinct delivery_status
from blinkit_delivery_performance;

-- market performance
select distinct campaign_id
from blinkit_marketing_performance;

select distinct campaign_name
from blinkit_marketing_performance;

select distinct channel
from blinkit_marketing_performance;

select distinct target_audience
from blinkit_marketing_performance;

-- order items
select distinct order_id
from blinkit_order_items;

create table TotalQuantityPerProduct
select distinct product_id,
	sum(quantity) as Total_Quantity,
    unit_price
from blinkit_order_items
group by
	product_id,
    unit_price;

-- orders
select distinct order_id
from blinkit_orders;

-- Create table RecurringCustomers
select distinct customer_id, 
	sum(order_total) as TotalOrders,
    count(*) as RecurringCustomer
from blinkit_orders 
group by customer_id
having RecurringCustomer > 1;

select distinct payment_method
from blinkit_orders;

select distinct store_id
from blinkit_orders;

-- Products
select product_id
from blinkit_products;

select distinct product_name
from blinkit_products;

select distinct category
from blinkit_products;

select distinct brand
from blinkit_products;

-- category Inventory
create table InventoryYear
select product_id,
	right(date,4) as Years,
    sum(stock_received) as TotalYearStock,
    sum(damaged_stock) as TotalYearDamge
from blinkit_inventory
group by 
	product_id,
	Years
;

create table InventoryNewYear
select product_id,
case 
	when right(date,2) = 23 then '2023'
    when right(date,2) = 24 then '2024'
    end as Years,
    sum(stock_received) as TotalYearStock,
    sum(damaged_stock) as TotalYearDamge
from blinkit_inventorynew
group by 
	product_id,
	Years
;

create table TotalMergedInventory
select *
from inventoryyear
union
select * 
from inventorynewyear;

create table FInalInventory
select product_id,
	years,
	sum(TotalYearStock) as TotalStock,
	sum(TotalYearDamge) as TotalDamageStock
from totalmergedinventory
group by 
	product_id,
    years;
    
    

SELECT
    customer_id,
    MAX(feedback_date) AS last_activity_date
FROM blinkit_customer_feedback
GROUP BY customer_id;
------------
-- Churn Rate
-- Create Table CFB_Days
select feedback_id,
	order_id,
    customer_id,
    rating,
    feedback_category,
    sentiment,
    case 
		when left(feedback_date,4) = '2023' then mid(feedback_date,6,2) * 30 + right(feedback_date,2)
        when left(feedback_date,4) = '2024' then 365+ mid(feedback_date,6,2) * 30 + right(feedback_date,2)
        end as Days
from blinkit_customer_feedback;

select 
    count(customer_id) / 1061 * 100 as Churn_Rate
from CFB_days
where days >630;


-- churn rate monthwise
-- create table ChurnRateMonth
select 
    count(customer_id) as Customer_amount,
    left(feedback_date,7) as monthdate
from blinkit_customer_feedback
group by
	left(feedback_date,7);

select 
	*,
    lag(Customer_amount,1) over(order by monthdate) as previous_month,
    Customer_amount - lag(Customer_amount,1) over(order by monthdate) as MonthDifference,
    (Customer_amount - lag(Customer_amount,1) over(order by monthdate))/Customer_amount * 100 as churn_Rate
from churnratemonth
limit 20;



-- Total Customer
Select 
 count(customer_id)
 from cfb_days;

-- CUsotmer Lifetime values
select 
	total_orders,
	avg_order_value,
    total_orders*avg_order_value as CLTV
from blinkit_customers;

-- Net Promoter Score
select 
	avg(rating) as Avg_Rating
    from CFB_days;
    
-- Areas
Select 
	area,
    address,
    pincode,
    avg_order_value
from blinkit_customers;

-- Orders Vs Satisfaction
Select 	
	rating,
	count(order_id) as Total_orders
from CFB_days
group by 	
	rating;
    
-- Sentiment DIstribution
select 
	Sentiment,
	count(feedback_id) as Customers
from cfb_days
group by
	Sentiment;
    
-- feedback and rating over time
select 
	count(feedback_id) as Feedbacks,
    round(avg(rating),1) as Rating,
    left(feedback_date,7) as Time
from blinkit_customer_feedback
group by
	Time;
    
-- customer vs satisfaction
select 
	Sentiment,
	count(customer_id) as Customers
from cfb_days
group by
	Sentiment;
    
-- Performance analysis
-- on time delivery %
select 
	count(
		case
			when delivery_time_minutes < 0 then 1 else NUll end) /
	count(delivery_time_minutes) as On_Time_Delivery
from blinkit_delivery_performance;

-- Avg delivery time
Select 
	round(avg(delivery_time_minutes),2) as Avg_Delivery_Time
from blinkit_delivery_performance;

-- CTR%
select 
	sum(clicks) /
    sum(impressions) as CTR
    
from blinkit_marketing_performance;

-- COnversion rate
select 
    sum(conversions) / 
    sum(clicks) as Conversion_Rate    
from blinkit_marketing_performance;

-- ontime vs late delivery
select 
	count(
		case
			when delivery_time_minutes > 0 then 1 else Null end
    ) as Late_Delivery,
    count(
		case
			when delivery_time_minutes <0 then 1 else Null end
            )as On_time_delivery
from blinkit_delivery_performance;

-- delay Vs Distance
select 	
	delivery_time_minutes as Delivery_time,
    round(avg(distance_km),2) as Avg_Distance,
    count(order_id) as Total_Orders
from blinkit_delivery_performance
group by 
    delivery_time_minutes
    ;

-- conversion rate vs targetted audience    
select 
	sum(conversions)
from blinkit_marketing_performance
;

select 
	target_audience,
    sum(conversions)/298038
from blinkit_marketing_performance
group by 
	target_audience;

-- Champign vs ROAS
select
	campaign_name ,
    round(avg(roas),2) as Avg_ROAS
from blinkit_marketing_performance
group by
	campaign_name;
    
-- revenue vs channel
select
	channel,
    round(sum(revenue_generated),2) as Total_Revenue_Generated,
    round(sum(spend),2) as Total_Spending
from blinkit_marketing_performance
group by 
	channel;
    
-- Inventory analysis
-- damage rate
select 
        sum(TotalDamageStock) /
		sum(TotalDamageStock + TotalStock)
from finalinventory;

-- Current Stock in Inventory
select 
	sum(TotalStock) as total_stock,
    sum(TotalDamageStock) as Damage_stock,
    sum(TotalStock) -sum(TotalDamageStock) as current_stock
from finalinventory;

-- avg shelf life
select
	round(avg(shelf_life_days),1) as avg_shelf_life
from blinkit_products;

-- avg stock level
select 
	avg(min_stock_level),
    avg(max_stock_level)
from blinkit_products;

-- total stores
select
	count(store_id)
from blinkit_orders;

-- store performance
Select 
	store_id,
    concat('ID ',store_id) as StoreId,
    order_total
from blinkit_orders
order by order_total desc
limit 10;

-- payment method
select 
	payment_method,
    round(sum(order_total),2)as total_orders
from blinkit_orders
group by
	payment_method;
    
-- inventory analysis
select
	years,
    sum(TotalStock) as Stock_Recieved,
    sum(TotalDamageStock) as Stock_Damage
from finalinventory
group by
	years;
    
-- price vs Product
select
	totalquantityperproduct.product_id,
    product_name,
    unit_price,
    Total_Quantity
from totalquantityperproduct
join blinkit_products
	on blinkit_products.product_id = totalquantityperproduct.product_id
order by Total_Quantity desc
limit 6;

-- delivery status
select 
	delivery_status,
	count(delivery_status)
from blinkit_orders
group by
	delivery_status;
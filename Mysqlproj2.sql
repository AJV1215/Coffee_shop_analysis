select * from coffee_shop_sales;	
SET SQL_SAFE_UPDATES = 0 ;
describe coffee_shop_sales;

-- _______________________________________________________________________________________________________--
-- data cleansing --

-- changing the data format for transaction date 

update coffee_shop_sales
set transaction_date= str_to_date(transaction_date,'%d-%m-%y');

alter table coffee_shop_sales
modify column transaction_date date;

-- changing the data format for transaction time

 update coffee_shop_sales
 set transaction_time= str_to_date(transaction_time,'%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time time;

-- change the name of the filed name for transaction id 
alter table coffee_shop_sales
change column ï»¿transaction_id transaction_id int;

-- ______________________________________________________________________________________________________________________ --

-- problem statements 

/*
1.Total sales analysis 
	i) cal total sales for each respective month
    ii) determine month on month increase or decrease in sales 
    iii) difference in sales between the selected month and prev month
 */   
 
 -- total sales for each month 
select concat((round(sum(unit_price * transaction_qty)))/1000,'k') as total_sales
from coffee_shop_sales
where 
month(transaction_date) = 5 -- may month

-- month on month DIFF and % for sales
select 
month_number , currentmonthsales , Prevmonthsales ,
currentmonthsales - prevmonthsales as mom_diff ,
Round((currentmonthsales - prevmonthsales) / prevmonthsales * 100 ,2) as mom_percent
From 
(
select
	month(transaction_date) as month_number,
	sum(unit_price * transaction_qty) as currentmonthsales,
	lag(sum(unit_price * transaction_qty)) over ( order by month(transaction_date)) as Prevmonthsales
From coffee_shop_sales
Group by month(transaction_date) 
)t;

/*
2.Total order analysis 
	i) cal total order for each respective month
    ii) determine month on month increase or decrease in no of order 
    iii) difference in order between the selected month and prev month
 */   

-- total num of orders for each month 
select month(transaction_date) as month_num ,count(transaction_id) as total_orders
from coffee_shop_sales
group by
month(transaction_date);

-- month on month DIFF and % for orders
select 
month_number , currentmonthorders , Prevmonthorders ,
currentmonthorders - Prevmonthorders as mom_diff ,
Round((currentmonthorders - Prevmonthorders) / Prevmonthorders * 100 ,2) as mom_percent
From 
(
select
	month(transaction_date) as month_number,
	count(unit_price * transaction_qty) as currentmonthorders,
	lag(count(unit_price * transaction_qty)) over ( order by month(transaction_date)) as Prevmonthorders
From coffee_shop_sales
Group by month(transaction_date) 
)t;

/*
3.Total quantity analysis 
	i) cal total quantity for each respective month
    ii) determine month on month increase or decrease in no of quantity sold 
    iii) difference in order between the selected month and prev month
 */  
 
-- total num of quantity sold for each month 
select month(transaction_date) as month_num ,sum(transaction_qty) as total_qantity
from coffee_shop_sales
group by
month(transaction_date);

-- month on month DIFF and % for quantity sold
select 
month_number , currentmonthquantity , Prevmonthquantity ,
currentmonthquantity - Prevmonthquantity as mom_diff ,
Round((currentmonthquantity - Prevmonthquantity) / Prevmonthquantity * 100 ,2) as mom_percent
From 
(
select
	month(transaction_date) as month_number,
	sum(transaction_qty) as currentmonthquantity,
	lag(sum(transaction_qty)) over ( order by month(transaction_date)) as Prevmonthquantity
From coffee_shop_sales
Group by month(transaction_date) 
)t;

-- 4.for the heat map hovering ( total slaes,total quantity sold,total order) 

select 
    month(transaction_date) as Month_num ,
	concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales ,
	concat(round(count(transaction_id)/1000,1),'k') as total_orders ,
	concat(round(sum(transaction_qty)/1000,1),'k') as total_qantity
From coffee_shop_sales
group by month(transaction_date) ;


/*
5.sales analysis by weekdays and weekends
	i) segment sales data into weekdays and weekends to analyze performance variations
    ii) insights into whether sales patterns differ significantly between weekdays and weekends
 */  

select 
	case when dayofweek(transaction_date) in (1,7) then 'weekends'
	else 'weekdays'
	end as day_type ,
	concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales
From coffee_shop_sales
Group by 
	case when dayofweek(transaction_date) in (1,7) then 'weekends'
	else 'weekdays'
	end ;
    
/*
6.sales analysis by store loaction
	i) sales data by different stor locations
 */ 
select 
store_location,
concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales
From coffee_shop_sales 
-- where	month(transaction_date)='5' ( if you specificly need a month to be filtered)
group by store_location
order by sum(unit_price * transaction_qty) DESC;

/*
7.daily sales with average analysis
 */ 
 
 -- avg sales
 select 
	concat(round(avg(total_sales)/1000,1),'k') as Avg_sales
From  
(   
	select sum(unit_price * transaction_qty) as total_sales
	from coffee_shop_sales
	-- where month(transaction_date)='5' -- ( if you specificly need a month to be filtered)
	Group by transaction_date
)t;
 
 -- daily sales
select 
	 day(transaction_date) as day_of_month,
	 sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
-- where month(transaction_date) = 5 -- ( if you specificly need a month to be filtered)
group by day(transaction_date)
order by day(transaction_date);

 -- comparing daily sales is above or below the avg sales 
 select 
 day_of_month,
 case 
	 when total_sales> avg_sales then ' above average'
	 when total_sales<avg_sales then ' Below average'
	 else 'average'
 end as sales_status , total_sales
 from 
 (
 select
     day(transaction_date) as day_of_month,
	 sum(unit_price * transaction_qty) as total_sales,
     avg(sum(unit_price * transaction_qty)) over() as avg_sales
from coffee_shop_sales
     -- where month(transaction_date) = 5 -- ( if you specificly need a month to be filtered)
     group by day(transaction_date)
 )sales_data
 order by day_of_month;
 
 /*
8. sales analysis by product category
 */ 
 select 
	 product_category,
	 concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales
 from coffee_shop_sales
 Group by product_category
 order by  sum(unit_price * transaction_qty) desc ;
 
 /*
 9.Top 10 prouducts by sales
 */
 select 
	 product_type,
	 concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales
 from coffee_shop_sales
 -- where month(transaction_date) = 5 and product_category ='coffee'
 Group by product_type
 order by  sum(unit_price * transaction_qty) desc 
 limit 10 ;
 
 /*
 10. display sales , orders, quantity over a specific day-hour
 */
select 
	month(transaction_date) mon,
	dayofweek(transaction_date) day_,
    hour(transaction_time) hr,
	concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales ,
	concat(round(count(transaction_id)/1000,1),'k') as total_orders ,
	concat(round(sum(transaction_qty)/1000,1),'k') as total_qantity_sold
 from coffee_shop_sales
 group by 
 	month(transaction_date),
	dayofweek(transaction_date),
    hour(transaction_time);
 /*
 insted of grp by 
 where month(transaction_date) = 5 -- for specific month
 and dayofweek(transaction_date) -- dayofweek(transaction_date) = 2 [ for getting result under specific day]
 and hour(transaction_time) -- hour(transaction_time) = 8 [ for getting result under specific hr]
 */
 
 
 
 /*
 11. display peak hours of a day wrt sales
 */
select 
 hour(transaction_time),
 concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales
 From coffee_shop_sales
 -- where month(transaction_date) = 5 -- for specific month
 Group by hour(transaction_time)
 order by hour(transaction_time);
 
 /*
 12. display peak days of a day wrt sales
 */
 
 SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
-- WHERE MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
    
    
-- TO GET SALES FOR ALL HOURS FOR MONTH
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffee_shop_sales
-- WHERE MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);


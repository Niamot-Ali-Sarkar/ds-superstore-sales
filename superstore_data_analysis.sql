/* Tasks: 
Dataset: Superstore Sales Data
Task:
CREATE A DATABASE IN MYSQL
CREATE A TABLE UNDER THAT DATABASE
INSERT THE ATTACH DATA THERE (PREFERABLY BULK INSERTION)
EXPLORE THE DATA AND CHECK IF ALL THE DATA IS IN THE PROPER FORMAT
DO THE NECESSARY CLEANING AND UPDATE THE TABLE SCHEMA IF REQUIRED
PERFORM EXPLORATORY DATA ANALYSIS
SEGMENT THE CUSTOMER USING RFM SEGMENTATION
*/
/* ==================================================
1. Create database, load the csv file and explore it
====================================================*/
select * from sales;
-- 1. create a database in mysql
drop database if exists superstore;
create database if not exists superstore;
use superstore;
-- 2. define the table columns
create table sales(
	RowID INT,
    OrderPriority VARCHAR(20),
    Discount DOUBLE,
    UnitPrice DOUBLE,
    ShippingCost DOUBLE,
    CustomerID INT,
    CustomerName VARCHAR(30),
    ShipMode VARCHAR(20),
    CustomerSegment VARCHAR(50),
    ProductCategory VARCHAR(50),
    ProductSubCategory VARCHAR(100),
    ProductContainer VARCHAR(50),
    ProductName VARCHAR(200),
    ProductBaseMargin DOUBLE,
    Region VARCHAR(30),
    Manager VARCHAR(30),
    StateOrProvince VARCHAR(30),
    City VARCHAR(30),
    PostalCode INT,
    OrderDate INT,
    ShipDate INT,
    Profit DOUBLE,
    QuantityOrderedNew INT,
    Sales DOUBLE,
    OrderID INT,
    ReturnStatus  VARCHAR(30)
);
-- 3. correct the table column after getting erros
ALTER TABLE sales MODIFY COLUMN OrderDate VARCHAR(25);
ALTER TABLE sales MODIFY COLUMN ShipDate VARCHAR(25);
ALTER TABLE sales MODIFY COLUMN ProductBaseMargin DECIMAL(10,2);
ALTER TABLE sales MODIFY COLUMN Profit DECIMAL(10,6);
ALTER TABLE sales MODIFY COLUMN PostalCode INT;

-- 4. bulk insertion
-- 		a. paste the csv filt in the "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/" location
-- 		b. Open csv file and search, if there any special character remove them
-- 		c. In the csv file, if there is any comma(,) of each cell, it will create lot's trouble
--         so you must remove or replace with suitable character
-- 		d. SHOW VARIABLES LIKE 'secure_file_priv'; -- paste location of csv file
-- 		e. SHOW WARNINGS; -- use to see warnings

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Superstore_Sales_Data.csv'
INTO TABLE sales
FIELDS TERMINATED BY ',' 
IGNORE 1 ROWS;  -- Skips header row
 
select * from sales;

-- 5. start exploring the table 
-- 	a. OrderDate/ ShipDate
select -- OrderDate
	orderdate -- 28-05-2012; dd-mm-yyyy
from sales;
select -- ShipDate
	ShipDate -- 30-05-2012; dd-mm-yyyy
from sales;
-- 	b. string to date format
select -- OrderDate
	orderdate, -- 28-05-2012
    str_to_date(orderdate, '%d-%m-%y') as date_formate -- 2020-05-28
from sales;
select -- ShipDate
	ShipDate, -- 30-05-2012
    str_to_date(ShipDate, '%d-%m-%y') as date_formate -- 2020-05-30
from sales;

-- 	c. year and month
select -- OrderDate
	OrderDate,
    year(str_to_date(OrderDate, "%d-%m-%y")) as Years,
    monthname(str_to_date(OrderDate, "%d-%m-%y")) as Months
from sales;
select -- ShipDate
	ShipDate,
    year(str_to_date(ShipDate, "%d-%m-%y")) as Years,
    monthname(str_to_date(ShipDate, "%d-%m-%y")) as Months
from sales;

-- 	d. Update the date format: string to date
set sql_safe_updates = 0; -- allow to update tables
-- update table
update sales
set OrderDate = str_to_date(OrderDate, "%d-%m-%Y");
update sales
set ShipDate = str_to_date(ShipDate, "%d-%m-%Y"); -- yyyy-mm-dd

select OrderDate, ShipDate from sales limit 10;

-- 	e. first and last order date using max and min
select 
	max(OrderDate) as last_OrderDate,
    max(ShipDate) as last_ShipDate,
    min(OrderDate) as first_OrderDate,
    min(ShipDate) as first_ShipDate
from sales;

/* ================================================
2. Last and First transection date of each customer
==================================================*/
select 
	CustomerName,
    max(OrderDate) as Last_OrderDate,
    min(OrderDate) as First_OrderDate,
	max(ShipDate) as Last_ShipDate,
    min(ShipDate) as First_ShipDate
from sales
group by CustomerName;

/* ============================================================
3.Find Recency Last and First transection date of each customer
===============================================================*/
select 
	CustomerName,
    max(OrderDate) as Last_OrderDate,
    datediff(
    (select max(OrderDate) from sales), max(OrderDate)) as Recency
from sales
group by CustomerName
order by Recency asc;

/* ================================================
4.Create View of the database calculate profit loss
==================================================*/
-- 	a. catagorized by OrderPriority (Order By), of Total Profit, 
-- Total Sales, Total Order, Individual Customer of Each catagory
select
	OrderPriority,
    count(RowID) as Total_Order,
    count(distinct CustomerID) as Individual_Customer,
    Round(sum(Profit),0) as Total_Profit,
    Round(sum(Sales),0) as Total_Sales
from sales
group by OrderPriority
order by 4 desc;

-- 	b. Prepare a profit/Loss Table
create or replace view profit_loss as 
with
cost_table as
(select 
	RowID,
    Discount,
    UnitPrice, 
    ShippingCost,
    ProductBaseMargin,
    QuantityOrderedNew as QtyNew
from sales),
new_sales as
(select
	c.*,
    Round((UnitPrice-Discount)*QtyNew,2) as Sales
from cost_table as c),
new_profit as
(select
	ns.*,
    round(((Sales*ProductBaseMargin)-ShippingCost),2) as Profit
from new_sales as ns)
select
	*
from new_profit;

select * from profit_loss;

/* ===================================================
5.Create View of the database find important customers
=====================================================*/
select * from sales;

create or replace view customer_importance as
with
-- 	a. operatio-1: extract info from main (sales) table
customer_info as
(select
	CustomerID,
    CustomerName,
    CustomerSegment,
    OrderDate,
    Profit,
    QuantityOrderedNew as QtyNew,
    Sales
from sales),
-- 	b. operatio-2: extract info from operation-1 and perform 
-- necessary operation.
each_customer_info as
(select 
	CustomerName,
    Round(sum(Profit),2) as total_profit,
    sum(QtyNew) as total_Qty,
    Round(sum(Sales),2) as total_sales,
	max(OrderDate) as Last_OrderDate,
    datediff((select max(OrderDate) from customer_info), max(OrderDate)) as Recency
from customer_info as c
group by CustomerName),

-- 	c. operation-3: give score to the profit, Quantity and total sales,
-- recency ect
customer_score as
(select 
	ec.*,
    -- higher total profit get higher number
    ntile(4) over (order by total_profit asc) as tf_score,
    ntile(4) over (order by total_Qty asc) as tq_score,
    ntile(4) over (order by total_sales asc) as ts_score,
    ntile(4) over (order by Recency desc) as r_score
from each_customer_info as ec)
-- 	d. select the variables you want to store in the view from the 
-- last operation (operation-3)
select 
	CustomerName, 
    total_profit,
    total_Qty,
    total_sales,
    concat_ws('',tf_score , tq_score , ts_score , r_score) as
    score_combination
from customer_score;

select * from customer_importance
order by score_combination desc;

/* ==========================================================
6.Create View from the view to  find important customers info
  and lable them as you want.
=============================================================*/
create or replace view important_customer_label as
with 
-- 	a. label the each customer using the score value
customer_score as
(select 
	ci.*,
    -- case when
    case
		when score_combination in (4444, 4434, 4443, 4344, 3444) then 'most active customer'
        when score_combination in (4433, 4334, 3344, 4343, 3434) then 'active customer'
        when score_combination in (4422, 2244, 2424, 4242, 2442) then 'can not lose'
        when score_combination in (2224, 2234, 2324, 2223, 2114, 2233, 2334, 2333) then 'new cutomer'
	else 'others'
    end as customer_segment
from customer_importance as ci)

select 
	CustomerName, total_profit, total_Qty, total_sales, 
    score_combination, customer_segment
from customer_score;

select * from important_customer_label
order by total_profit desc;

-- 	b. Find the total_profit, total_qty, total_sales of each customer category
-- 	   and also find the number of customers in each category
select 
	customer_segment,
	count(distinct CustomerName),
    round(sum(total_profit),0) as segment_total_profit,
    round(sum(total_Qty),0) as segment_total_qty,
    round(sum(total_sales),0) as segment_total_sales
from important_customer_label
group by customer_segment
order by segment_total_sales desc;

/* ==========================================================
7.Create View from the view to  find important customers info
=============================================================*/
-- using important_customer_label view find the important customer
-- information like customer name, total profit from the customer,
-- total quanitity of sales to the customer, customer segment,
-- customer id and location related information.
create or replace view customer_info_and_parameters as
with
customer_info_category as
(select 
	important_customer_label.CustomerName,
    important_customer_label.total_profit,
    important_customer_label.total_Qty,
    important_customer_label.total_sales,
    important_customer_label.customer_segment,
    sales.RowID,
    sales.CustomerSegment,
    sales.Region,
    sales.StateOrProvince,
    sales.City,
    sales.PostalCode
from important_customer_label
left join sales on important_customer_label.CustomerName =
					sales.CustomerName
order by important_customer_label.total_profit desc)
select * from customer_info_category;

select * from customer_info_and_parameters;
-- ----------- End -------------
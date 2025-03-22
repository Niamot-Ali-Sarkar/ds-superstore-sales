# Data Analysis of Superstore Sales Data using MySQL
## Main Overview
In this analysis a sales database of a superstore is used. This data set is loaded in the MySQL environment and performs different analyses. Using this analysis we find the:
- last and first transaction of each customer
- recency value of each customer
- calculate profit or loss, total sales, and total order, total quantity for each customer and create a view
- add a scoring system to the profit or loss, total sales, and total order, total quantity for each customer and create a view
- find the important customer from the scoring system
- find the important customer personal information like city, state, name, etc

Based on the result we want to perform some marketing campaign to the necessary customers so the we can increase sales and profit.
## Necessary Files
- `README.md`: readme file of the analysis. Overall discussion
- `Superstore_Sales_Data.csv`: dataset used to perform analysis
- `superstore_data_analysis.sql`: necessary SQL write to perform analysis
## Methodology
**1. Create a database, load the CSV file, and explore it**
- 1. Create a database in MySQL
- 2. Define the table columns
- 3. Correct the table column after getting errors
- 4. Bulk insertion
     While performing bulk insertion we got so many errors, to solve those errors we
     did those operation: 
  - a. paste the CSV file in the "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/" location
  - b. Open the CSV file and search, if there are any special characters remove them
  - c. In the CSV file, if there is any comma(,) in each cell, it will create a lot of trouble
         so you must remove or replace it with a suitable character
  - d. SHOW VARIABLES LIKE 'secure_file_priv'; -- paste location of CSV file
  -	e. SHOW WARNINGS; -- use to see warnings

- 5. start exploring the table 
- 	  a. OrderDate/ ShipDate
-     b. string-to-date format
-   	c. year and month
-     d. Update the date format: string to date
-   	e. first and last order date using max and min
/* ================================================
2. Last and First transection date of each customer
==================================================*/
/* ============================================================
3.Find Recency Last and First transection date of each customer
===============================================================*/
/* ================================================
4.Create View of the database calculate profit loss
==================================================*/
-- 	a. categorized by OrderPriority (Order By), of Total Profit, 
-- 	  Total Sales, Total Order, Individual Customer of Each catagory
-- 	b. Prepare a profit/Loss Table
/* ===================================================
5.Create View of the database find important customers
=====================================================*/
-- 	a. operatio-1: extract info from main (sales) table
-- 	b. operatio-2: extract info from operation-1 and perform 
-- 	c. operation-3: give score to the profit, Quantity and total sales,
-- 	d. select the variables you want to store in the view from the 
--         last operation (operation-3)
/* ==========================================================
6.Create View from the view to find important customers info
  and label them as you want.
=============================================================*/
--	a. label the each customer using the score value
-- 	b. Find the total_profit, total_qty, total_sales of each customer category
-- 	   and also find the number of customers in each category
/* ==========================================================
7.Create View from the view to find important customers info
=============================================================*/
-- using important_customer_label view find the important customer
-- information like customer name, total profit from the customer,
-- total quantity of sales to the customer, customer segment,
-- customer id and location related information.
-- ----------- End -------------
## Findings / Results

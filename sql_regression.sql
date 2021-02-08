/**
1. Create a database called house_price_regression.
**/
drop database if exists house_price_regression;
create database if not exists house_price_regression;
use house_price_regression;
drop table if exists house_price_data;
/**
2. Create a table house_price_data with the same columns as given in the csv file. Please make sure you use the correct data types for the columns.
**/
create table house_price_data (
	`id` bigint unique not null,
    `date` text,
    `bedrooms` int,
    `bathrooms` decimal,
    `sqft_living` int,
    `sqft_lot` int,
    `floors` decimal,
    `waterfront` int,
    `view` int,
    `condition` int,
    `grade` int,
    `sqft_above` int,
    `sqft_basement` int,
    `yr_built` int,
    `yr_renovated` int,
    `zipcode` int,
    `lat` float,
    `long` float,
    `sqft_living15` int,
    `sqft_lot15` int,
    `price` int
    );    


/**
3. Import the data from the csv file into the table. Before you import the data into the empty table, make sure that you have deleted the headers from the csv file. To not modify the original data, if you want you can create a copy of the csv file as well. Note you might have to use the following queries to give permission to SQL to import data from csv files in bulk:
**/

SHOW VARIABLES LIKE 'local_infile'; -- This query would show you the status of the variable ‘local_infile’. If it is off, use the next command, otherwise you should be good to go

SET GLOBAL local_infile = 1;
load data local infile 'C:/Users/Sara-/Desktop/Data_Analytics/week_5/data_mid_bootcamp_project_regression/regression_data.csv'
into table house_price_data
fields terminated BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
	(`id`,`date`,`bedrooms`,`bathrooms`,`sqft_living`,`sqft_lot`,`floors`,`waterfront`,`view`,`condition`,`grade`,
    `sqft_above`,`sqft_basement`,`yr_built`,`yr_renovated`,`zipcode`,`lat`,`long`,`sqft_living15`,`sqft_lot15`,`price`);

/**
4. Select all the data from table house_price_data to check if the data was imported correctly
**/
select * from house_price_data;
/**
5. Use the alter table command to drop the column date from the database, as we would not use it in the analysis with SQL. Select all the data from the table to verify if the command worked. Limit your returned results to 10.
**/
ALTER TABLE house_price_data DROP COLUMN date;
select * from house_price_data LIMIT 10;

/**
6. Use sql query to find how many rows of data you have.
**/
select COUNT(*) from house_price_data;

/**
7. Now we will try to find the unique values in some of the categorical columns:
**/
-- What are the unique values in the column bedrooms? 1, 2,3,4,5,6,7,8,9,10,11,33
SELECT distinct bedrooms FROM house_price_data;
-- What are the unique values in the column bathrooms?1,2,3,4,5,6,7,8
SELECT distinct bathrooms FROM house_price_data;
-- What are the unique values in the column floors?1,2,3,4
SELECT distinct floors FROM house_price_data;
-- What are the unique values in the column condition?1,2,3,4,5
SELECT distinct(`condition`) FROM house_price_data;
-- What are the unique values in the column grade? 3,4,5,6,7,8,9,10,11,12,13
SELECT distinct grade FROM house_price_data;

/**
8. Arrange the data in a decreasing order by the price of the house. Return only the IDs of the top 10 most expensive houses in your data.
**/

SELECT id, price FROM house_price_data order by price desc limit 10;

/**
9. What is the average price of all the properties in your data?
**/

select round(avg(price)) as average_price FROM house_price_data;

/**
10. In this exercise we will use simple group by to check the properties of some of the categorical variables in our data
**/

-- What is the average price of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the prices. Use an alias to change the name of the second column.
SELECT bedrooms, round(avg(price)) as average_price FROM house_price_data group by bedrooms order by bedrooms;

-- What is the average sqft_living of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the sqft_living. Use an alias to change the name of the second column.
SELECT bedrooms, round(avg(sqft_living)) as average_sqft_living FROM house_price_data group by bedrooms order by bedrooms;

-- What is the average price of the houses with a waterfront and without a waterfront? The returned result should have only two columns, waterfront and Average of the prices. Use an alias to change the name of the second column.
SELECT waterfront, round(avg(price)) as average_price FROM house_price_data group by waterfront;

-- Is there any correlation between the columns condition and grade? You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column. Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
select grade, avg(`condition`) as avg_condition
from house_price_data
group by grade
order by grade ASC; 

select avg(grade), `condition` as avg_condition
from house_price_data
group by `condition`
order by `condition` ASC;
-- they don't seem correlated

/**
11. One of the customers is only interested in the following houses:

- Number of bedrooms either 3 or 4
- Bathrooms more than 3
- One Floor
- No waterfront
- Condition should be 3 at least
- Grade should be 5 at least
- Price less than 300000
For the rest of the things, they are not too concerned. Write a simple query to find what are the options available for them?
**/
SELECT bedrooms, bathrooms, floors, waterfront, `condition`, grade, price 
FROM house_price_data 
where bedrooms IN (3,4) 
and bathrooms > 3 
and floors = 1 
and waterfront = 0 
and `condition` >=3 
and grade >= 5 
and price < 300000;
-- no results 

/**
12. Your manager wants to find out the list of properties whose prices are twice more than the average of all the properties in the database. Write a query to show them the list of such properties. You might need to use a sub query for this problem.
**/
SELECT id, price FROM house_price_data where price > (select avg(price)*2 from house_price_data);
/**
13. Since this is something that the senior management is regularly interested in, create a view of the same query.
**/
create view twice_average as SELECT id, price FROM house_price_data where price > (select avg(price)*2 from house_price_data);
select * from twice_average;
/**
14. Most customers are interested in properties with three or four bedrooms. What is the difference in average prices of the properties with three and four bedrooms?
**/
select bedrooms, round(avg(price)) as `average_`, round(avg(price))-lag(round(avg(price)),1) over (order by bedrooms) as difference  from house_price_data  where bedrooms in (3,4) group by bedrooms order by bedrooms;

-- another way
select round((AVG(b.price) - AVG(a.price)))
as Difference
from house_price_data as a
CROSS JOIN house_price_data as b
where a.bedrooms = 3
AND b.bedrooms = 4
group by b.bedrooms;

/**
15. What are the different locations where properties are available in your database? (distinct zip codes)
**/
select * from house_price_data;
select distinct zipcode from house_price_data;

/**
16. Show the list of all the properties that were renovated.
**/
-- with cte_values as (select *, Sqft_living15-Sqft_living as Sqft_living_total, Sqft_lot-Sqft_lot15 as Sqft_lot_total  from house_price_data) select * from cte_values where Sqft_living_total != 0 and Sqft_lot_total != 0;

select * from house_price_data where yr_renovated != 0;

/**
17. Provide the details of the property that is the 11th most expensive property in your database.
**/
with cte_rank as (select id, rank() over (order by price desc) as ranking_, price from house_price_data)
select * from cte_rank where ranking_ = 11;

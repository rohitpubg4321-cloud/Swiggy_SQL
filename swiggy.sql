
--------------------------- Swiggy * Advance * SQL * Project -----------------------------------------


-----Create a Table for Swiggy_Data-----
drop table if exists swiggy ;
Create table swiggy
(
State varchar(50),
City varchar(50),
Order_Date	date,
Restaurant_Name	varchar(60),
Location	varchar(100),
Category	varchar(100),
Dish_Name	varchar(200),
Price_INR	numeric(10,2),
Rating	numeric(2,1),
Rating_Count int
) ;



--Checking Null Values in the Dataset...

Select *
from swiggy 
where (state is null 
OR City is null 
OR order_dates	is null 
OR Restaurant_Name	is null 
OR Location is null 
OR Rating	is null 
OR Rating_Count is null );


       ----Hence there is no any columns that have null values---



--- Checking for Blank data/string in the Dataset...

SELECT *
FROM swiggy
where
State =''
OR City =''
OR Restaurant_Name =''
OR Dish_Name = ''
OR location = ''
OR category =''	 ;


   --- Here also ave Not any type Of blank String in any Columns ....


---- Detection Of Duplicate Data From The dataSet..

SELECT
city,state,order_dates,
restaurant_name,location,
category,dish_name,price_inr,
rating,rating_count,
count(*) as total_duplicate
FROM swiggy
GROUP BY 1,2,3,4,5,6,7,8,9,10 
Having count(*) >1;


   ---Here there are 27 rows have duplicate values and that number of duplicates is 2 ..
   


--- Delete The Duplicates Values From The Dataset...

WITH cte AS (
SELECT
ctid,
ROW_NUMBER() OVER 
(
PARTITION BY
city,state,order_dates,
restaurant_name,location,
category,dish_name,price_inr,
rating,rating_count
ORDER BY ctid
) AS rn

FROM swiggy
)
DELETE FROM swiggy
WHERE ctid IN (
SELECT ctid
FROM cte
WHERE rn > 1
);



--- Retrive the Resturants Name That Have Rating grater than and equal to 4.5..

SELECT *
FROM swiggy
WHERE rating >=4.5 ;


--- Which is The Top 5 City That Have Highest Number Of unique Resturant...


SELECT
city,
count(distinct(restaurant_name)) as highest_number_restaurant
FROM swiggy
Group by city
order by highest_number_restaurant desc
limit 5;


---What Is The Average Rating Of Resturants In Each City ?

SELECT
city,
restaurant_name ,
ROUND(AVG(rating),3) as Average_rating_restaurant
FROM swiggy
GROUP BY 1,2
ORDER BY  Average_rating_restaurant DESC ;
 

--Retrive The Total Number Of Resturant that Present In Each State ..

Select
state,
Count(restaurant_name) as Total_restaurant
From swiggy
Group by state 
Order By Total_restaurant DESC;





-----INTERMEDIATE SQL QUERIES:--------
--1). TOP 5 Most Expensive Dishes In Each City..

      Select
	  city,
	  dish_name,
	  restaurant_name,
	  price_inr
	  FROM (
Select *,
ROW_NUMBER() OVER (Partition by city Order by price_inr DESC) as rnk
From swiggy
) as t

  Where rnk <=5
  Order by City,Price_inr DESC ;


--Using CTE Table..

With CTE As
(
Select *,
ROW_NUMBER() OVER (Partition by city Order by price_inr DESC) as rnk
From swiggy
) 

   SELECT
   city,
   dish_name,
   restaurant_name,
   price_inr
   FROM CTE
   WHERE rnk <=5
  Order by City,Price_inr DESC ;


--2).Average Dish Price By Category...

    SELECT
	category,
	ROUND(AVG(price_inr),3)as Average_price
	FROM swiggy
	Group by 1
	Order by 2 DESC ;


--3).Restaurant With The Maximum Number Of Dishes....

     Select
	 restaurant_name,
	 count(distinct dish_name) as total_dishes 
	 FROM swiggy
	 GROUP BY restaurant_name
	 ORDER BY total_dishes DESC
	 LIMIT 1 ;
     
--4). City Having The Highest Average Rating...

	Select
	city,
	round(AVG(rating),3) as avg_rating
	FROM swiggy
	Group by city
	order by 2 DESC
	limit 1;

--5). Average Price Of Dishes In Every Restaurant ...

	 SELECT
	distinct(restaurant_name),
	 Round(AVG(Price_inr),3) as avg_price
	 FROM swiggy
	 Group by restaurant_name
	 ORDER BY 2 DESC ;



-----ADVANCED SQL QUERIES:--------
--6).Rank Restaurants Within Each City Based On Ratings..

	Select 
	city,
	restaurant_name,
	rating,
	RANK () OVER (partition by city Order by rating DESC ) as resturant_rank
	From swiggy
	Order by city asc,resturant_rank DESc;


--7).Find The 3 Most Expensive Dishes In Every Category....

 With CTE as
(
select *,
ROW_NUMBER() OVER(partition by category order by price_inr DESC) as rnk
FROM swiggy
)
 SELECT
 category,
 dish_name,
 restaurant_name,
 price_inr
 FROM CTE
 Where rnk <=3
 ORDER BY category,price_inr DESC ;


--8).Running Average Of Dish Prices By Order Date..

  Select
  dish_name,
  order_dates,
  price_inr,
  ROUND(AVG(price_inr) Over (order by order_dates Rows BEtween Unbounded Preceding and Current Row),2)
  as running_avg_price
  FROM swiggy
  Order by Order_dates ASC ;
    

--9). Best Value For Money Restaurants (high rating and have less price for dishes)..

    Select
	restaurant_name,state,
	ROUND(AVG(rating),2) as avg_rating,
	ROUND(AVG(price_inr),2) as avg_price
	FROM swiggy
	GROUP BY 1,2
	HAVING AVG(rating) >=4.5
	ORDER BY 3 desc,4 asc ; 


--10). Top restaurant in Each Category ..

 WITH CTE AS
 (
  Select
  category,
  restaurant_name,
  rating,
  Row_NUMBER() Over (partition by category ORDER BY rating DESC) as rnt
  FROM swiggy
  )
SELECT category,restaurant_name,rating
FROM CTE
WHERE rnt =1
ORDER BY 1 ;




-----Business Insights Queries:--------
--11). Which Category Generates The Highest Average Price ?

 Select
 category,
 ROUND(AVG(price_inr),2) as Avg_price
 FROM swiggy
 GROUP BY 1
 ORDER BY 2 desc 
 LIMIT 1;


--12). Find Restaurants Whose Average Price is Above Their City's Average.

  Select
  city,restaurant_name,
  ROUND(AVG(price_inr),2) as restaurant_avg_price
  FROM swiggy as s
  GROUP BY 1,2
  HAVING AVG(price_inr) >
  (
   select
   avg(price_inr)
   from swiggy
   where city =s.city
  )
  ORDER BY city,restaurant_avg_price DESC ;


--13). Use Lag/Lead to compare Monthly Average Prices...

  With CTE as
  (
  select
  Date_trunc('month',order_dates) as month,
  ROUND(AVG(price_inr),2) as avg_price
  FROM swiggy
  GROUP BY 1
  )
  SELECT
  month,avg_price,
  LAG(avg_price) OVER (ORDER BY month) as prev_month_price,
  ROUND(avg_price - LAG(avg_price) OVER (order by month),2) as price_differ
  FROM CTE
  ORDER BY month ;


--14).Make restaurant rating  as good , average, excellent for each category .

 SELECT
 restaurant_name,
 rating,
 CASE
 WHEN rating >= 4.5 THEN 'Excellent'
 WHEN rating >= 4.0 THEN 'Good'
 WHEN rating >= 3.0 THEN 'Average'
 ELSE 'Poor'
 END as rating_category
 FROM swiggy ;


--15).Compare The Total Number Of Orders Placed On Weekends And Weekdays..

 SELECT
 CASE
 WHEN EXTRACT(DOW FROM order_dates) IN (0,6) THEN 'Weekend'
 ELSE 'Weekday'
 END as day_type,
 COUNT(*) as total_orders
 FROM swiggy
 GROUP BY day_type ;

 select *
 from swiggy
 limit 10 ;




















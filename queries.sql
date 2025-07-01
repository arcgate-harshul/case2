

-- before we start executing questions we need to clean the data remove the null values , nav values 


-- these are the tables available by us with the data as showed in the images 


show tables;


select * from customer_orders
-- we will try to remove all the null values as blank values  from customer table 
update customer_orders set exclusions = CASE WHEN exclusions IS NULL THEN '' ELSE exclusions END;
update customer_orders set extras = CASE WHEN extras IS NULL THEN '' ELSE extras END;

-- // table updated

select * from  runner_orders

-- the enxt table we need to fix is this one 
update runner_orders set distance = CASE WHEN distance IS NULL THEN '' ELSE distance END;
update runner_orders set duration = CASE WHEN duration IS NULL THEN '' ELSE duration END;
update runner_orders set cancellation = CASE WHEN cancellation IS NULL THEN '' ELSE cancellation END;

-- table corrected
select * from runner_orders;

-- now we can start the questions 


-- 1. How many pizzas were ordered?

 select COUNT(order_id) as pizzas_ordered from customer_orders;



-- 2. How many unique customer orders were made?


 select COUNT(DISTINCT(order_id)) as order_count from runner_orders;


-- 3. How many successful orders were delivered by each runner?


select runner_id , COUNT(DISTINCT(order_id)) as orders_per_runner from runner_orders where distance != 0 group by runner_id;

-- 4. How many of each type of pizza was delivered?

select pizza_id ,COUNT(order_id) as orders_per_pizza from customer_orders group by pizza_id;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?


WITH f AS 
( select customer_id  ,pizza_id ,COUNT(order_id) 
as counts from customer_orders 
group by pizza_id,customer_id ) 
select  customer_id  , pizza_name , f.pizza_id ,counts from f JOIN pizza_names ON pizza_names.pizza_id = f.pizza_id;



-- 6. What was the maximum number of pizzas delivered in a single order?

 select order_id ,COUNT(pizza_id ) FROM customer_orders group by order_id order by COUNT(pizza_id) DESC LIMIT 1;


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select DISTINCT customer_id , CASE WHEN exclusions!= '' OR  extras!= '' THEN "YES" ELSE "NO" END AS CHANEGS FROM customer_orders ;

SELECT  customer_id,CHANEGS FROM t group by customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?


select COUNT(customer_orders.order_id)  as count from  customer_orders JOIN runner_orders 
ON runner_orders.order_id = customer_orders.order_id  where exclusions != '' AND extras != '' AND  distance !=0;


-- 9. What was the total volume of pizzas ordered for each hour of the day? 


-- grouping by both date and hour this gives total order in one hour for all dates 

select count(order_id) as orders ,
HOUR(order_time) as hour, 
DATE(order_time) AS order_date
from customer_orders 
group by order_date, hour order by hour ;

-- grouping by just hour this gives partition by hours for all dates 

select count(order_id) as orders ,
HOUR(order_time) as hour
from customer_orders 
group by  hour order by hour ;

-- 10. What was the volume of orders for each day of the week?

select count(order_id) as orders ,
DATE(order_time) as day
from customer_orders 
group by  day   order by day ;

-- B. Runner and Customer Experience 
-- these are second set of questions please view the solution below 


-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select  WEEK(registration_date) as week ,count(runner_id )   from runners group by week;


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH sample as (
select runner_id,  TIMESTAMPDIFF(MINUTE, customer_orders.order_time, runner_orders.pickup_time) as tima from customer_orders 
JOIN runner_orders 
ON customer_orders.order_id  = runner_orders.order_id
WHERE DATE(order_time) = DATE(pickup_time)
)
select  runner_id ,AVG(tima)  from sample group by runner_id;


-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?


-- firs we need to correct some data in the table running_orders as some of the dates are 2020 but 
-- the order placed was in 2021 so how an order placed in 2021 can be picked up in 2021


UPDATE runner_orders
SET pickup_time = CASE
    WHEN YEAR(pickup_time) = 2020 THEN DATE_ADD(pickup_time, INTERVAL 1 YEAR)
    ELSE pickup_time
END;

-- now we will write the query 

create view cte as
select COUNT(customer_orders.order_id) as count
,TIMESTAMPDIFF(MINUTE,order_time , pickup_time) as time_diff
from customer_orders JOIN runner_orders using (order_id)
where distance != 0
group by order_id , time_diff;


-- this will give the final output 
select count ,AVG(time_diff) from cte group by count ;






-- 4. What was the average distance travelled for each customer?

select customer_id , AVG(distance) from customer_orders join runner_orders using (order_id) where distance!= 0 group by customer_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?


-- first we have to remove the strings attached in duration 
update runner_orders set duration = CASE WHEN duration LIKE '%minute' OR duration LIKE '%minutes' 
OR duration LIKE '%mins' THEN  LEFT(duration , 2) else duration END ;


-- then we will find the max and min and between of them 

WITH cte AS (SELECT MAX(duration) AS max ,MIN(duration) as min from runner_orders where distance!= 0 ) select max - min from cte;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?


-- this will give you average speed which shows that runner 2 has deliveredat speed of 35 as well 90 which brings a huge diffrence 

select runner_id ,distance / (duration/60) as speed from runner_orders  where distance!=0 ;


-- 7. What is the successful delivery percentage for each runner?


-- we need to provide some correction before solving it 

update runner_orders SET distance = CASE WHEN distance LIKE '%km' THEN LEFT(distance ,2)  else distance END ;

-- now we can start executing the queries 

WITH cte as (
select runner_id ,COUNT(runner_id) as success from runner_orders where cancellation= '' group by  runner_id 
),
cte1 as (
select runner_id , COUNT(runner_id) as total  from runner_orders group by runner_id
)
select runner_id, success / total * 100 as success_percent from cte JOIN cte1 using (runner_id) group by runner_id;


-- C. Ingredient Optimisation


-- 1. What are the standard ingredients for each pizza?


create view s as 
WITH RECURSIVE split_toppings AS (

  SELECT
    pizza_id,
    SUBSTRING_INDEX(toppings, ',', 1) AS topping_id,
    SUBSTRING(toppings, LENGTH(SUBSTRING_INDEX(toppings, ',', 1)) + 2) AS remaining
  FROM pizza_recipes

  UNION ALL

  SELECT
    pizza_id,
    SUBSTRING_INDEX(remaining, ',', 1) AS topping_id,
    SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
  FROM split_toppings
  WHERE remaining != ''
)

SELECT pizza_id, topping_id
FROM split_toppings
ORDER BY pizza_id, topping_id;


select topping_name as ingredients ,pizza_id, RANK() OVER(PARTITION BY pizza_id ORDER BY s.topping_id) as ransks from pizza_toppings JOIN s on s.topping_id = pizza_toppings.topping_id ;



-- 2. What was the most commonly added extra?


create view s2 as 
WITH RECURSIVE split_toppings AS (

  SELECT
    pizza_id,
    order_id,
    extras,
    SUBSTRING_INDEX(extras, ',', 1) AS topping_id,
    SUBSTRING(extras, LENGTH(SUBSTRING_INDEX(extras, ',', 1)) + 2) AS remaining
  FROM customer_orders

  UNION ALL

  SELECT
    pizza_id,
    order_id,
    extras,
    SUBSTRING_INDEX(remaining, ',', 1) AS topping_id,
    SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
  FROM split_toppings
  WHERE remaining != ''
)

SELECT pizza_id,order_id ,extras, topping_id
FROM split_toppings
ORDER BY extras, topping_id;

select topping_id ,topping_name , COUNT(topping_id) as count from s2 JOIN pizza_toppings using (topping_id) group by topping_id , topping_name;





-- 3. What was the most common exclusion?


create view s3 as 
WITH RECURSIVE split_toppings AS (

  SELECT
    order_id,
    pizza_id,
    exclusions,
    SUBSTRING_INDEX(exclusions, ',', 1) AS topping_id,
    SUBSTRING(exclusions, LENGTH(SUBSTRING_INDEX(exclusions, ',', 1)) + 2) AS remaining
  FROM customer_orders

  UNION ALL

  SELECT
    order_id,
    pizza_id
    exclusions,
    SUBSTRING_INDEX(remaining, ',', 1) AS topping_id,
    SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
  FROM split_toppings
  WHERE remaining != ''
)

SELECT exclusions, topping_id
FROM split_toppings
ORDER BY exclusions, topping_id;

select topping_id ,topping_name , COUNT(topping_id) as count from s3 JOIN pizza_toppings using (topping_id) group by topping_id , topping_name;


-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:

-- Meat Lovers
select * from customer_orders JOIN pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id where pizza_name = "Meat Lovers"  AND extras != "Bacon";


-- Meat Lovers - Exclude Beef
select * from customer_orders JOIN pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id where pizza_name = "Meat Lovers"  AND extras != "beef";

-- Meat Lovers - Extra Bacon
select * from customer_orders JOIN pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id where pizza_name = "Meat Lovers"  AND extras = "Bacon";


-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
select * from customer_orders JOIN pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id where pizza_name = "Meat Lovers"  AND extras != "Bacon" AND 
extras != "Cheese" AND extras != "Mushroom" AND extras != "Peppers";


-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table 
-- and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"


-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-- D. Pricing and Ratings


-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
-- how much money has Pizza Runner made so far if there are no delivery fees?

-- THE TOTAL SHOULD BE 160 BUT AS 2 ORDERS WERE NOT DELIVERED THE TOTAL WOULD BE 138 GIVEN IN BELOW QUERIES 

WITH cte1 as (
select  count(customer_orders.order_id) as meat_count from customer_orders JOIN pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id 
JOIN runner_orders ON runner_orders.order_id =
customer_orders.order_id where pizza_name = "Meat Lovers" AND distance !=0),

cte2 as (select  count(customer_orders.order_id) as veg_count  from customer_orders JOIN pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id 
JOIN runner_orders ON runner_orders.order_id =
customer_orders.order_id where pizza_name = "Vegetarian" AND distance !=0 ) ,

cte3 as (select (select * from cte1)*12 as meat_total , veg_count * 10  as veg_total from cte2 )
select meat_total , veg_total  , veg_total+meat_total as grand_total from cte3;


-- 2. What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

-- here we will use previously created S2 AND S3 for comma seprated value to row



-- here as for all exrtras including cheese the price is fixed at  1$ we are 
-- calculatinf from conacted srtrings using commas 


WITH  d1 as 
(SELECT 
  order_id,
  pizza_id,
  extras,
  CASE 
    WHEN extras IS NULL OR extras = '' THEN 0
    ELSE LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1
  END AS extras_count
FROM customer_orders),
cte as(
select  d1.order_id , pizza_id , extras_count,
CASE 
WHEN pizza_id = 1 AND extras_count!= '' THEN  12 + extras_count
WHEN pizza_id = 2 AND extras_count != '' THEN  10 + extras_count
WHEN pizza_id = 1 AND extras_count = '' THEN  12  
WHEN pizza_id = 2 AND extras_count = '' THEN  10 
else 0
END AS cost from d1
JOIN runner_orders ON runner_orders.order_id = d1.order_id 
) select  SUM(cost) as total from cte ;



-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design 
-- an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful 
-- customer order between 1 to 5.


-- we have created a table named runner_ratinigs 
CREATE TABLE runner_ratings (
  runner_id int primary key,
  order_id  int ,
  ratings int 
);

-- HERE WE HAVE INSERTED VALUES SAMPLE FOR 5 ORDERS 

insert into runner_ratings values 
(1,1,7),
(2,2,6),
(3,3,5),
(4,4,10),
(5,5,9);


-- here we are printing values of top 5 orders 

select runner_ratings.order_id ,customer_id , ratings from runner_ratings join customer_orders 
ON customer_orders.order_id = runner_ratings.order_id where runner_ratings.order_id between 1 AND 5;




-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas


-- below is the solution for all the columns asked ->

WITH try AS (
  SELECT COUNT(order_id) AS order_count 
  FROM customer_orders  JOIN runner_orders using(order_id)
  WHERE distance != 0
)
SELECT 
  customer_orders.customer_id, 
  customer_orders.order_id, 
  runner_orders.runner_id, 
  runner_ratings.ratings, 
  customer_orders.order_time, 
  runner_orders.pickup_time, 
  TIMESTAMPDIFF(MINUTE, customer_orders.order_time, runner_orders.pickup_time) AS time_diff, 
  runner_orders.duration, 
  runner_orders.distance / (runner_orders.duration / 60) AS speed,
  (SELECT order_count FROM try) AS total_completed_orders
FROM customer_orders 
JOIN runner_orders ON runner_orders.order_id = customer_orders.order_id 
JOIN runner_ratings ON runner_ratings.runner_id = runner_orders.runner_id
WHERE runner_orders.distance != 0;



-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

    WITH base_pizza_cost AS (
    SELECT 
        SUM(CASE
            WHEN pizza_id = 1 THEN 12
            WHEN pizza_id = 2 THEN 10
        END) AS pizza_cost
    FROM customer_orders
    ),
    runner_cost_list AS (
    SELECT distance,
        CASE
            WHEN distance IS NOT NULL THEN distance*0.30
        END AS runner_cost
    FROM runner_orders
    ),
    runner_cost_total AS (
    SELECT SUM(runner_cost) AS total_runner_cost
    FROM runner_cost_list
    )
    SELECT
        pizza_cost - total_runner_cost
    FROM base_pizza_cost, runner_cost_total;
-- E. Bonus Questions
-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an 
-- INSERT statement to demonstrate what would happen if a new Supreme 
-- pizza with all the toppings was added to the Pizza Runner menu?
INSERT INTO customer_orders 
VALUES 
(15, 103, 2, 3, 2, '2021-02-04 13:23:46'),
(15, 103, 3, 3, 2, '2021-02-04 13:23:46');


select * from customer_orders
 ALTER
 -- here teh case study comes to an end 

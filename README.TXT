BEFORE WE START WITH QUERY EXECUTION WE NEED TO SOLVWE MAKE SOME CHANGES TO THE TABLES WHICH ARE AS FOLLOWS 



 Data Cleaning Steps
1. customer_orders

UPDATE customer_orders 
SET exclusions = CASE WHEN exclusions IS NULL THEN '' ELSE exclusions END;
UPDATE customer_orders 
SET extras = CASE WHEN extras IS NULL THEN '' ELSE extras END;
2. runner_orders

UPDATE runner_orders 
SET distance = CASE WHEN distance IS NULL THEN '' ELSE distance END;
UPDATE runner_orders 
SET duration = CASE WHEN duration IS NULL THEN '' ELSE duration END;
UPDATE runner_orders 
SET cancellation = CASE WHEN cancellation IS NULL THEN '' ELSE cancellation END;
3. Duration and Distance Cleanup

-- Remove text from duration and distance
UPDATE runner_orders 
SET duration = CASE 
    WHEN duration LIKE '%minute%' THEN LEFT(duration, 2)
    ELSE duration END;

UPDATE runner_orders 
SET distance = CASE 
    WHEN distance LIKE '%km%' THEN LEFT(distance, 2)
    ELSE distance END;
4. Fixing Dates

-- Adjust 2020 pickup_time into 2021
UPDATE runner_orders
SET pickup_time = DATE_ADD(pickup_time, INTERVAL 1 YEAR)
WHERE YEAR(pickup_time) = 2020;

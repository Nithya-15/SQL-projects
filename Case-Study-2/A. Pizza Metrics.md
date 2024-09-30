**Schema (PostgreSQL v9.6)**

    CREATE SCHEMA pizza_runner;
    SET search_path = pizza_runner;
    
    DROP TABLE IF EXISTS runners;
    CREATE TABLE runners (
      "runner_id" INTEGER,
      "registration_date" DATE
    );
    INSERT INTO runners
      ("runner_id", "registration_date")
    VALUES
      (1, '2021-01-01'),
      (2, '2021-01-03'),
      (3, '2021-01-08'),
      (4, '2021-01-15');
    
    
    DROP TABLE IF EXISTS customer_orders;
    CREATE TABLE customer_orders (
      "order_id" INTEGER,
      "customer_id" INTEGER,
      "pizza_id" INTEGER,
      "exclusions" VARCHAR(4),
      "extras" VARCHAR(4),
      "order_time" TIMESTAMP
    );
    
    INSERT INTO customer_orders
      ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
    VALUES
      ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
      ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
      ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
      ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
      ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
      ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
      ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
      ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
      ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
      ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
      ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
      ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
      ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
      ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
    
    
    DROP TABLE IF EXISTS runner_orders;
    CREATE TABLE runner_orders (
      "order_id" INTEGER,
      "runner_id" INTEGER,
      "pickup_time" VARCHAR(19),
      "distance" VARCHAR(7),
      "duration" VARCHAR(10),
      "cancellation" VARCHAR(23)
    );
    
    INSERT INTO runner_orders
      ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
    VALUES
      ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
      ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
      ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
      ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
      ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
      ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
      ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
      ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
      ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
      ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
    
    
    DROP TABLE IF EXISTS pizza_names;
    CREATE TABLE pizza_names (
      "pizza_id" INTEGER,
      "pizza_name" TEXT
    );
    INSERT INTO pizza_names
      ("pizza_id", "pizza_name")
    VALUES
      (1, 'Meatlovers'),
      (2, 'Vegetarian');
    
    
    DROP TABLE IF EXISTS pizza_recipes;
    CREATE TABLE pizza_recipes (
      "pizza_id" INTEGER,
      "toppings" TEXT
    );
    INSERT INTO pizza_recipes
      ("pizza_id", "toppings")
    VALUES
      (1, '1, 2, 3, 4, 5, 6, 8, 10'),
      (2, '4, 6, 7, 9, 11, 12');
    
    
    DROP TABLE IF EXISTS pizza_toppings;
    CREATE TABLE pizza_toppings (
      "topping_id" INTEGER,
      "topping_name" TEXT
    );
    INSERT INTO pizza_toppings
      ("topping_id", "topping_name")
    VALUES
      (1, 'Bacon'),
      (2, 'BBQ Sauce'),
      (3, 'Beef'),
      (4, 'Cheese'),
      (5, 'Chicken'),
      (6, 'Mushrooms'),
      (7, 'Onions'),
      (8, 'Pepperoni'),
      (9, 'Peppers'),
      (10, 'Salami'),
      (11, 'Tomatoes'),
      (12, 'Tomato Sauce');

---

**Query #1**

    UPDATE pizza_runner.customer_orders
    SET exclusions=CASE
       WHEN exclusions='null' THEN NULL
       WHEN exclusions='' THEN NULL
       ELSE exclusions
       END,
       extras=CASE
       WHEN extras='null' THEN NULL
       WHEN extras='' THEN NULL
       ELSE extras
       END;

There are no results to be displayed.

---
**Query #2**

    UPDATE pizza_runner.runner_orders
    SET pickup_time=CASE
        WHEN pickup_time='null' THEN NULL
        WHEN pickup_time='' THEN NULL
        ELSE pickup_time
        END,
        distance=CASE
        WHEN distance='null' THEN NULL
        ELSE distance
        END,
        duration=CASE
        WHEN duration='null' THEN NULL
        ELSE duration
        END,
        cancellation=CASE
        WHEN cancellation='null' THEN NULL
        WHEN cancellation='' THEN NULL
        ELSE cancellation
        END;

There are no results to be displayed.

---
**Query #3**

    SELECT COUNT(pizza_id) as No_of_pizzas_ordered
    FROM pizza_runner.customer_orders;

| no_of_pizzas_ordered |
| -------------------- |
| 14                   |

---
**Query #4**

    SELECT COUNT(DISTINCT order_id) as No_of_unique_customer_orders
    FROM pizza_runner.customer_orders;

| no_of_unique_customer_orders |
| ---------------------------- |
| 10                           |

---
**Query #5**

    SELECT runner_id, COUNT(order_id) as No_of_successful_orders
    FROM pizza_runner.runner_orders
    WHERE cancellation IS NULL
    GROUP BY runner_id;

| runner_id | no_of_successful_orders |
| --------- | ----------------------- |
| 1         | 4                       |
| 2         | 3                       |
| 3         | 1                       |

---
**Query #6**

    SELECT pizza_name, COUNT(A.order_id)
    FROM pizza_runner.customer_orders a
    LEFT JOIN pizza_runner.PIZZA_NAMES B ON A.pizza_id=b.pizza_id
    LEFT JOIN pizza_runner.runner_orders C ON A.order_id=C.order_id
    WHERE cancellation IS NULL
    GROUP BY pizza_name;

| pizza_name | count |
| ---------- | ----- |
| Meatlovers | 9     |
| Vegetarian | 3     |

---
**Query #7**

    SELECT customer_id, pizza_name, COUNT(order_id)
    FROM pizza_runner.customer_orders A
    LEFT JOIN pizza_runner.pizza_names B ON A. pizza_id=B.pizza_id
    GROUP BY customer_id, pizza_name
    ORDER BY customer_id;

| customer_id | pizza_name | count |
| ----------- | ---------- | ----- |
| 101         | Meatlovers | 2     |
| 101         | Vegetarian | 1     |
| 102         | Meatlovers | 2     |
| 102         | Vegetarian | 1     |
| 103         | Meatlovers | 3     |
| 103         | Vegetarian | 1     |
| 104         | Meatlovers | 3     |
| 105         | Vegetarian | 1     |

---
**Query #8**

    SELECT MAX(count) as max_order_count FROM
    (SELECT A.order_id, COUNT(A.order_id) as count
    FROM pizza_runner.customer_orders A
    LEFT JOIN pizza_runner.runner_orders B ON A.order_id=B.order_id
    WHERE cancellation IS NULL
    GROUP BY A.order_id
    ORDER BY A.order_id) AS max_count;

| max_order_count |
| --------------- |
| 3               |

---
**Query #9**

    SELECT customer_id, SUM(CASE 
              WHEN (exclusions IS NULL AND extras IS NULL) THEN 1
              ELSE 0
              END) AS no_changes,
              SUM(CASE
              WHEN (exclusions IS not NULL OR extras IS not NULL) THEN 1
              ELSE 0
              END) AS atleast_one_change
    FROM pizza_runner.customer_orders a
    LEFT JOIN pizza_runner.runner_orders b on a.order_id=b.order_id
    WHERE cancellation IS NULL
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | no_changes | atleast_one_change |
| ----------- | ---------- | ------------------ |
| 101         | 2          | 0                  |
| 102         | 3          | 0                  |
| 103         | 0          | 3                  |
| 104         | 1          | 2                  |
| 105         | 0          | 1                  |

---
**Query #10**

    SELECT customer_id, SUM(CASE 
                            WHEN (exclusions IS NOT NULL AND EXTRAS IS NOT NULL) THEN 1
                            ELSE 0
                            END) AS both_exclusions_extras
    FROM pizza_runner.customer_orders a
    LEFT JOIN pizza_runner.runner_orders b on a.order_id=b.order_id
    WHERE cancellation IS NULL
    GROUP BY customer_id
    order by customer_id;

| customer_id | both_exclusions_extras |
| ----------- | ---------------------- |
| 101         | 0                      |
| 102         | 0                      |
| 103         | 0                      |
| 104         | 1                      |
| 105         | 0                      |

---
**Query #11**

    SELECT EXTRACT(hour FROM order_time) AS Hours,
           count(order_id) AS Number_of_pizzas_ordered,
           round(100 * count(order_id) / sum(count(order_id)) OVER (), 2) AS Volume_of_pizzas_ordered
    FROM pizza_runner.customer_orders
    GROUP BY hours
    ORDER BY hours;

| hours | number_of_pizzas_ordered | volume_of_pizzas_ordered |
| ----- | ------------------------ | ------------------------ |
| 11    | 1                        | 7.14                     |
| 13    | 3                        | 21.43                    |
| 18    | 3                        | 21.43                    |
| 19    | 1                        | 7.14                     |
| 21    | 3                        | 21.43                    |
| 23    | 3                        | 21.43                    |

---
**Query #12**

    SELECT EXTRACT(day from order_time) as each_Day,
           count(order_id) as Number_of_pizzas_ordered,
           round(100*count(order_id)/sum(count(order_id)) over(), 2) as volume_of_orders_day
    FROM pizza_runner.customer_orders
    GROUP BY each_Day
    ORDER BY each_day;

| each_day | number_of_pizzas_ordered | volume_of_orders_day |
| -------- | ------------------------ | -------------------- |
| 1        | 2                        | 14.29                |
| 2        | 2                        | 14.29                |
| 4        | 3                        | 21.43                |
| 8        | 3                        | 21.43                |
| 9        | 1                        | 7.14                 |
| 10       | 1                        | 7.14                 |
| 11       | 2                        | 14.29                |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/2993)
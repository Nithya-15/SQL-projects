**Schema (PostgreSQL v13)**

    CREATE SCHEMA dannys_diner;
    SET search_path = dannys_diner;
    
    CREATE TABLE sales (
      "customer_id" VARCHAR(1),
      "order_date" DATE,
      "product_id" INTEGER
    );
    
    INSERT INTO sales
      ("customer_id", "order_date", "product_id")
    VALUES
      ('A', '2021-01-01', '1'),
      ('A', '2021-01-01', '2'),
      ('A', '2021-01-07', '2'),
      ('A', '2021-01-10', '3'),
      ('A', '2021-01-11', '3'),
      ('A', '2021-01-11', '3'),
      ('B', '2021-01-01', '2'),
      ('B', '2021-01-02', '2'),
      ('B', '2021-01-04', '1'),
      ('B', '2021-01-11', '1'),
      ('B', '2021-01-16', '3'),
      ('B', '2021-02-01', '3'),
      ('C', '2021-01-01', '3'),
      ('C', '2021-01-01', '3'),
      ('C', '2021-01-07', '3');
     
    
    CREATE TABLE menu (
      "product_id" INTEGER,
      "product_name" VARCHAR(5),
      "price" INTEGER
    );
    
    INSERT INTO menu
      ("product_id", "product_name", "price")
    VALUES
      ('1', 'sushi', '10'),
      ('2', 'curry', '15'),
      ('3', 'ramen', '12');
      
    
    CREATE TABLE members (
      "customer_id" VARCHAR(1),
      "join_date" DATE
    );
    
    INSERT INTO members
      ("customer_id", "join_date")
    VALUES
      ('A', '2021-01-07'),
      ('B', '2021-01-09');

---

**Query #1 What is the total amount each customer spent at the restaurant?**


    SELECT
      	product_id,
        product_name,
        price
    FROM dannys_diner.menu
    ORDER BY price DESC
    LIMIT 5;

| product_id | product_name | price |
| ---------- | ------------ | ----- |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |
| 1          | sushi        | 10    |

---
**Query #2 How many days has each customer visited the restaurant?**


    SELECT customer_id, COUNT(DISTINCT order_date) as no_of_days
    FROM dannys_diner.sales
    GROUP BY customer_id;

| customer_id | no_of_days |
| ----------- | ---------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

---
**Query #3 What was the first item from the menu purchased by each customer?**


    WITH rank_table as
    (
    SELECT customer_id, product_name, 
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as rank
    FROM dannys_diner.sales A
    LEFT JOIN dannys_diner.menu B
    ON A.product_id=B.product_id
    )
    SELECT customer_id, product_name
    FROM rank_table
    WHERE rank=1
    ;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |
| C           | ramen        |

---
**Query #4 What is the most purchased item on the menu and how many times was it purchased by all customers?**

    SELECT product_name, COUNT(A.product_id) as count
    FROM dannys_diner.sales A
    LEFT JOIN dannys_diner.menu B ON A.product_id=B.product_id
    GROUP BY B.product_name
    ORDER BY count;

| product_name | count |
| ------------ | ----- |
| sushi        | 3     |
| curry        | 4     |
| ramen        | 8     |

---
**Query #5 Which item was the most popular for each customer?**


    WITH table_2 as
    (WITH table_1 as
    (SELECT customer_id, product_name, COUNT(A.product_id)
    FROM dannys_diner.sales A
    LEFT JOIN dannys_diner.menu B ON A.product_id=B.product_id
    GROUP BY customer_id, product_name)
    SELECT customer_id, product_name,count, 
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY count DESC) as rank
    FROM table_1)
    SELECT customer_id, product_name
    FROM table_2
    WHERE rank=1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | ramen        |
| B           | curry        |
| B           | sushi        |
| C           | ramen        |

---
**Query #6 Which item was purchased first by the customer after they became a member?** 

    With table_3 as
    (With table_2 as
    (With table_1 as
    (SELECT A.customer_id, order_date, product_id, join_date
    FROM dannys_diner.sales A
    INNER JOIN dannys_diner.members B on A.customer_id=B.customer_id
    WHERE B.join_date<A.order_date)
    SELECT customer_id, order_date, C.product_id, product_name
    FROM table_1 C
    LEFT JOIN dannys_diner.menu D ON C.product_id=D.product_id)
    SELECT customer_id, order_date, product_name,
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as rank
    FROM table_2)
    SELECT customer_id, product_name
    FROM table_3
    WHERE rank=1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | sushi        |

---
**Query #7 Which item was purchased just before the customer became a member?** 

    With table_3 as
    (With table_2 as
    (With table_1 as
    (SELECT A.customer_id, order_date, product_id, join_date
    FROM dannys_diner.sales A
    INNER JOIN dannys_diner.members B on A.customer_id=B.customer_id
    WHERE B.join_date>A.order_date)
    SELECT customer_id, order_date, C.product_id, product_name
    FROM table_1 C
    LEFT JOIN dannys_diner.menu D ON C.product_id=D.product_id)
    SELECT customer_id, order_date, product_name, 
    DENSE_RANK() OVER(PARTITION BY customer_id order by order_date DESC) as rank
    FROM table_2)
    SELECT customer_id, product_name
    FROM table_3 
    WHERE rank=1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

---
**Query #8 What is the total items and amount spent for each member before they became a member?** 

    With table_2 as
    (With table_1 as
    (SELECT A.customer_id, order_date, product_id, join_date
    FROM dannys_diner.sales A
    INNER JOIN dannys_diner.members B on A.customer_id=B.customer_id
    WHERE B.join_date>A.order_date)
    SELECT customer_id, order_date, C.product_id, product_name, price
    FROM table_1 C
    LEFT JOIN dannys_diner.menu D ON C.product_id=D.product_id)
    SELECT customer_id, SUM(price)
    FROM table_2
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | sum |
| ----------- | --- |
| A           | 25  |
| B           | 40  |

---
**Query #9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
  

    With table_2 as
    (With table_1 as
    (SELECT product_id, product_name,
    CASE 
    WHEN product_id=1 THEN price*20
    ELSE price*10
    END AS points
    FROM dannys_diner.menu)
    SELECT customer_id, A.product_id, points
    FROM dannys_diner.sales A
    LEFT JOIN table_1 B ON A.product_id=B.product_id)
    SELECT customer_id, SUM(points)
    FROM table_2
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | sum |
| ----------- | --- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

---
**Query #10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?** 

    With table_1 as
    (SELECT *, 
       join_date + INTERVAL '6 DAY' AS valid_date, 
       '2021-01-31'::DATE + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS last_date
    FROM dannys_diner.members)
    SELECT A.customer_id,
    SUM(CASE WHEN A.product_id=1 THEN price*20
         WHEN order_date BETWEEN join_date AND valid_date THEN price*20
         ELSE price*10 END) AS points    
    FROM dannys_diner.sales A
    JOIN table_1 B ON A.customer_id=B.customer_id
    JOIN dannys_diner.menu C ON A.product_id=C.product_id
    WHERE order_date<last_date
    GROUP BY A.customer_id;

| customer_id | points |
| ----------- | ------ |
| A           | 1370   |
| B           | 940    |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/8294)
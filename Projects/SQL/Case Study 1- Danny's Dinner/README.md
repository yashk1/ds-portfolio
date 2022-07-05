# Case Study 1 - Danny's Diner :rice:

<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" width="500">

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

## Available Data

Danny shared 3 key datasets for this case study:
- `sales`;
- `menu`;
- `members`.

### Table 1: `sales`

The `sales` table captures all `customer_id` level purchases with an corresponding `order_date` and `product_id` information for when and what menu items were ordered.

| customer_id | order_date | product_id |
|-------------|------------|------------|
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |

### Table 2: `menu`

The `menu` table maps the `product_id` to the actual `product_name` and price of each menu item.

| product_id | product_name | price |
|------------|--------------|-------|
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |

### Table 3: `members`

The final members table captures the `join_date` when a `customer_id` joined the beta version of the Danny’s Diner loyalty program.

| customer_id | join_date  |
|-------------|------------|
| A           | 2021-01-07 |
| B           | 2021-01-09 |

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

## Case Study Questions

<details>
<summary>
View questions
</summary>

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
10. What is the total items and amount spent for each member before they became a member?
11. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
12. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
</details>

***

<details>
    <summary>Solution </summary>

# Case Study 1 - Danny's Diner :rice:

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers. 

Full description: [Case Study #1 - Danny's Diner](https://8weeksqlchallenge.com/case-study-1/)

## Entity Relationaship Diagram
![изображение](https://user-images.githubusercontent.com/98699089/156034410-8775d5d2-eda5-4453-9e33-54bfef253084.png)


## Case Study Questions

#### 1. What is the total amount each customer spent at the restaurant?

````sql
select s.customer_id , sum(m.price) as total_amount_spent
from dannys_diner.sales s inner join dannys_diner.menu m on s.product_id = m.product_id
group by s.customer_id 
order by sum(m.price) DESC
  ````

| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---
#### 2. How many days has each customer visited the restaurant?

````sql
select customer_id, count(distinct order_date) as num_of_days_visited
from dannys_diner.sales 
group by customer_id
  ````
  
| customer_id | num_days_of_visited |
| ----------- | ------------------- |
| A           | 4                   |
| B           | 6                   |
| C           | 2                   |

---

#### 3. What was the first item from the menu purchased by each customer?

To get the first item we need to rank the items ordered by each customer in a temporary table using `WITH` statement. 

After we have those ranks, we can select the rows with the rank = 1. 

````sql
with item_rank_by_order_date as (
select s.customer_id, s.product_id, m.product_name, dense_rank() over(partition by s.customer_id order by s.order_date) as rnk
from dannys_diner.sales s inner join dannys_diner.menu m 
on s.product_id = m.product_id)

select customer_id, product_name 
from item_rank_by_order_date
where rnk=1
````  
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |
| C           | ramen        |

---
 
  
The first purchase for customer A was :sushi

The first purchase for customer B was :curry:

The first (and the only) purchase for customer C was :ramen:

#### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
select product_id, count(*) from dannys_diner.sales
group by product_id
  ````
| product_id   | count                   |
| ------------ | ----------------------- |
| 3            | 8                       |
| 2            | 4                       |
| 1            | 3                       |


---
 
The most purchased item on the menu was :ramen:, it was purchased 8 times in total

#### 5. Which item was the most popular for each customer?

Let's look at all the results sorted by purchase frequency:

````sql
SET
  search_path = dannys_diner;
SELECT
  customer_id,
  product_name,
  COUNT(product_name) AS total_purchase_quantity
FROM
  sales AS s
  INNER JOIN menu AS m ON s.product_id = m.product_id
GROUP BY
  customer_id,
  product_name
ORDER BY
  total_purchase_quantity DESC
````

| customer_id | product_name | total_purchase_quantity |
| ----------- | ------------ | ----------------------- |
| C           | ramen        | 3                       |
| A           | ramen        | 3                       |
| B           | curry        | 2                       |
| B           | sushi        | 2                       |
| B           | ramen        | 2                       |
| A           | curry        | 2                       |
| A           | sushi        | 1                       |

---

 
The most popular item for customer A was :ramen:, they purchased it 3 times

The most popular item for customer B was :curry:, :ramen: and :sushi:, they purchased each dish 2 times

The most popular item for customer C was :ramen:, they purchased it 3 times

#### 6. Which item was purchased first by the customer after they became a member?

Let's consider that if the purchase date matches the membership date, then the purchase made on this date, was the first customer's purchase as a member. 
It means that we need to include this date in the WHERE statement.

````sql
WITH member_sales_cte AS 
(
 SELECT s.customer_id, m.join_date, s.order_date,   s.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rank
     FROM dannys_diner.sales AS s
 JOIN dannys_diner.members AS m
  ON s.customer_id = m.customer_id
 WHERE s.order_date >= m.join_date
)

SELECT s.customer_id,m.join_date, s.order_date, m2.product_name 
FROM member_sales_cte AS s
JOIN dannys_diner.menu AS m2
 ON s.product_id = m2.product_id
WHERE rank = 1;
  ````

| customer_id | join_date  | order_date | product_name |
| ----------- | ---------- | ---------- | ------------ |
| A           | 2021-01-07 | 2021-01-07 | curry        |
| B           | 2021-01-09 | 2021-01-11 | sushi        |

---

#### 7. Which item was purchased just before the customer became a member?

Customer A purchased their membership on January, 7 - and they placed an order that day. 
We do not have time and therefore can not say exactly if this purchase was made before of after they became a member. 
Let's consider that if the purchase date matches the membership date, then the purchase made on this date, was the first customer's purchase as a member. 
It means that we need to exclude this date in the `WHERE` statement.

````sql
with customer_purchase_before_join_date as(select s.customer_id, m.join_date, s.product_id, s.order_date,
dense_rank() over(partition by s.customer_id order by s.order_date DESC) as rnk
from dannys_diner.sales s join dannys_diner.members m 
on m.customer_id = s.customer_id 
where s.order_date < m.join_date)

select customer_id,join_date, order_date , t2.product_name
from customer_purchase_before_join_date t1
join dannys_diner.menu t2
on t1.product_id=t2.product_id
where rnk =1
  ````

| customer_id | join_date  | order_date | product_name |
| ----------- | ---------- | ---------- | ------------ |
| B           | 2021-01-09 | 2021-01-04 | sushi        |
| A           | 2021-01-07 | 2021-01-01 | sushi        |
| A           | 2021-01-07 | 2021-01-01 | curry        |


---

Customer A purchased two items on January, 1 - the date before they became a member. 
We need more information to tell exactly what item was purchased before they became a member: order number or purchase time. I am keeping two items in the list for now.

Customer B purchased :sushi: on 2021-01-04

Customer A purchased :curry: and :sushi: on 2021-01-01

#### 8. What is the total items and amount spent for each member before they became a member?

Let's consider that if the purchase date matches the membership date, then the purchase made on this date, was the first customer's purchase as a member. 
It means that we need to exclude this date in the WHERE statement.

````sql
select mem.customer_id, count(distinct m.product_id) , sum(price) as amount_spent_before_joining
from dannys_diner.menu m join dannys_diner.sales s
on m.product_id = s.product_id
inner join dannys_diner.members mem 
on mem.customer_id = s.customer_id
where s.order_date < mem.join_date 
group by mem.customer_id
  ````

| customer_id | count                 | amount_spent_before_joining |
| ----------- | --------------------- | --------------------------- |
| A           | 2                     | 25                          |
| B           | 3                     | 40                          |

---

#### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
select s.customer_id , 
Sum(case 
  when 
    m.product_name ='sushi' then m.price *10 * 2 
    else m.price * 10 
END) as points
from dannys_diner.menu m inner join dannys_diner.sales s 
on m.product_id = s.product_id
group by s.customer_id
  ````

| customer_id | points |
| ----------- | ------ |
| B           | 940    |
| C           | 360    |
| A           | 860    |

---

#### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

First we need to count points as usual: 10 points for each dollar spent on :curry: and :ramen: and 20 points for each dollar spent on :sushi:. 
We add this calculation to the `CTE` using `WITH` statement. Next we use this `CTE` to add extra 10 points for all the purchases of :curry: and :ramen: made by customers on the first week of their membership and return the sum of new points. The points for :sushi: remain the same - 20 points.

````sql
SET
  search_path = dannys_diner;
WITH count_points AS (
    SELECT
      s.customer_id,
      order_date,
      join_date,
      product_name,
      SUM(point) AS point
    FROM
      sales AS s
      JOIN (
        SELECT
          product_id,
          product_name,
          CASE
            WHEN product_name = 'sushi' THEN price * 20
            ELSE price * 10
          END AS point
        FROM
          menu AS m
      ) AS p ON s.product_id = p.product_id
      JOIN members AS mm ON s.customer_id = mm.customer_id
    GROUP BY
      s.customer_id,
      order_date,
      join_date,
      product_name,
      point
  )
SELECT
  customer_id,
  SUM(
    CASE
      WHEN order_date >= join_date
      AND order_date < join_date + (7 * INTERVAL '1 day')
      AND product_name != 'sushi' THEN point * 2
      ELSE point
    END
  ) AS new_points
FROM
  count_points
WHERE
  DATE_PART('month', order_date) = 1
GROUP BY
  1
ORDER BY
  1
  ````

| customer_id | new_points |
| ----------- | ---------- |
| A           | 1370       |
| B           | 820        |

---

Customer A at the end of January would have 1370 points

Customer B at the end of January would have 820 points*** and 0 benefits from their first week membership

## Bonus Questions

### Join  and Rank All The Things

````sql
with cte as (select s.customer_id, s.order_date, m.product_name , m.price,
case when s.order_date < mem.join_date then 'N'
else 'Y'
END as member
from dannys_diner.sales s inner join dannys_diner.menu m 
on s.product_id = m.product_id
inner join dannys_diner.members mem 
on mem.customer_id = s.customer_id
order by s.customer_id, s.order_date)

select *, case when member='N' then NULL
else dense_rank() over (partition by customer_id,member order by order_date)
end as ranking
from cte
````

| customer_id | order_date | product_name | price | member | ranking  |
| ----------- | ---------- | ------------ | ----- | ------ | -------- |
| A           | 2021-01-01 | curry        | 15    | N      | null     |
| A           | 2021-01-01 | sushi        | 10    | N      | null     |
| A           | 2021-01-07 | curry        | 15    | Y      | 1        |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2        |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3        |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3        |
| B           | 2021-01-01 | curry        | 15    | N      | null     |
| B           | 2021-01-02 | curry        | 15    | N      | null     |
| B           | 2021-01-04 | sushi        | 10    | N      | null     |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1        | 
| B           | 2021-01-16 | ramen        | 12    | Y      | 2        |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3        |
| C           | 2021-01-01 | ramen        | 12    | N      | null     |
| C           | 2021-01-01 | ramen        | 12    | N      | null     |
| C           | 2021-01-07 | ramen        | 12    | N      | null     |

---


</details>
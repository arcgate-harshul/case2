# Case Study #2 - Pizza Runner

![image](https://github.com/user-attachments/assets/7b21aaef-861b-4893-a296-b532b24344da)
Here's a concise and clear `README.md` for your Pizza Delivery database project:

---

# Pizza Runner - SQL Analytics Project

This project models a simplified pizza delivery business called **Pizza Runner**, where customer orders, pizza types, delivery details, and toppings are stored across multiple normalized tables. The data provides realistic scenarios for practicing SQL joins, cleaning data, aggregation, window functions, and CTEs.

##  Project Objective

To analyze Pizza Runner’s operations using SQL — including customer behavior, runner performance, ingredient usage, and delivery metrics — by querying and transforming data from multiple related tables.

---

## Database Schema Overview

### 1. **runners**

Stores runner details and their registration date.

| runner\_id | registration\_date |
| ---------- | ------------------ |
| 1          | 2021-01-01         |
| ...        | ...                |

---

### 2. **customer\_orders**

Captures individual pizza orders (one row per pizza). `exclusions` and `extras` contain ingredient IDs as comma-separated values.

| order\_id | customer\_id | pizza\_id | exclusions | extras | order\_time         |
| --------- | ------------ | --------- | ---------- | ------ | ------------------- |
| 1         | 101          | 1         |            |        | 2021-01-01 18:05:02 |
| ...       | ...          | ...       | ...        | ...    | ...                 |

---

### 3. **runner\_orders**

Details of order assignments, deliveries, and cancellations. Fields like `distance` and `duration` may contain inconsistent formats (e.g., "20km", "32 minutes").

| order\_id | runner\_id | pickup\_time        | distance | duration   | cancellation |
| --------- | ---------- | ------------------- | -------- | ---------- | ------------ |
| 1         | 1          | 2021-01-01 18:15:34 | 20km     | 32 minutes |              |
| ...       | ...        | ...                 | ...      | ...        | ...          |

---

### 4. **pizza\_names**

Pizza ID mapping to names.

| pizza\_id | pizza\_name |
| --------- | ----------- |
| 1         | Meat Lovers |
| 2         | Vegetarian  |

---

### 5. **pizza\_recipes**

Default toppings for each pizza type (comma-separated `topping_id`s).

| pizza\_id | toppings         |
| --------- | ---------------- |
| 1         | 1,2,3,4,5,6,8,10 |
| 2         | 4,6,7,9,11,12    |

---

### 6. **pizza\_toppings**

Mapping of `topping_id` to actual topping names.

| topping\_id | topping\_name |
| ----------- | ------------- |
| 1           | Bacon         |
| ...         | ...           |

---


## 🛠Technologies

* **SQL (MySQL compatible)**
* Schema normalized for performance and clarity.
* Useful for practicing joins, subqueries, window functions, CTEs, string functions, and aggregation.

---

## Ideal For

* SQL learners and analysts
* Data cleaning and transformation practice
* Real-world analytics case study

---

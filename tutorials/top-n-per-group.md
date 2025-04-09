# Top N Records Per Group in SQL
**By Kazi Mohammad Ali Nur (Romel)**

> 🧠 **Inspired by my answer to this Stack Overflow question:**  
> [Select 2 products per city with most counts in PostgreSQL](https://stackoverflow.com/questions/67475198/select-2-products-per-city-with-most-counts-in-postgresql/67475289#67475289)  
>
> In the original question, the user asked how to retrieve **two products per city** with the highest total count using PostgreSQL.
>
> In my answer, I’ve used `ROW_NUMBER()` in combination with a **Common Table Expression (CTE)** to extract the top N records per group.
>
> This approach is clean, modular, and supported across most modern SQL engines. The `ROW_NUMBER()` function allows us to rank each row within a partition (like rows per city), and the CTE helps us separate the ranking logic from the filtering logic.
>
> If you're new to either concept, don't worry — we’ll break down both at the bottom of this tutorial.

---

> In this tutorial, we’ll use a CTE to isolate the ranked rows before filtering out the top N per group.

---

## ✅ Solutions by Database

### 🐘 PostgreSQL

In this solution, I’ve used `ROW_NUMBER()` to rank products within each city based on their count — from highest to lowest. The `PARTITION BY the_city` clause ensures that the ranking restarts for every city, while `ORDER BY count(*) DESC` gives us the most frequent products first.

The ranking logic is wrapped inside a Common Table Expression (CTE) named `city_products`, which simplifies the final selection: we just filter where `rn <= 2` to get the top 2 products per city.

This approach is elegant, readable, and performs well in most SQL engines that support window functions.

```sql
WITH city_products AS (
  SELECT
    the_city,
    the_product,
    COUNT(*) AS product_count,
    ROW_NUMBER() OVER (PARTITION BY the_city ORDER BY COUNT(*) DESC) AS rn
  FROM my_table
  GROUP BY the_city, the_product
)
SELECT the_city, the_product, product_count
FROM city_products
WHERE rn <= 2;
```

**Sample Output:**

| the_city | the_product | product_count |
|----------|-------------|----------------|
| EVORA    | D           | 4              |
| EVORA    | B           | 2              |
| LISBO    | A           | 5              |
| LISBO    | B           | 2              |
| PORTO    | C           | 3              |
| PORTO    | B           | 2              |

👉 [Try it live on DB Fiddle](https://dbfiddle.uk/ZlUjxoMm)

---

### 🪟 SQL Server

👉 [Try it live on DB Fiddle](https://dbfiddle.uk/rsq8MqN8)

---

### 🟠 Oracle (12c+)

👉 [Try it live on DB Fiddle](https://dbfiddle.uk/Q-1c5-R-)

---

### 🟡 MySQL 8+

👉 [Try it live on DB Fiddle](https://dbfiddle.uk/MmB_1WEk)

---

## 🧠 What is ROW_NUMBER()?

`ROW_NUMBER()` is a **window function** that assigns a unique, sequential number to each row within a result set, based on a specified sort order.

You can use `PARTITION BY` to reset the numbering **within each group**, and `ORDER BY` to define how rows are sorted before numbers are assigned.

### 📘 Example:
Suppose you want to rank students by their score:

```sql
SELECT student, score,
  ROW_NUMBER() OVER (ORDER BY score DESC) AS rank
FROM results;
```

This produces:

| student | score | rank |
|---------|-------|------|
| Alice   | 95    | 1    |
| Bob     | 90    | 2    |
| Carol   | 85    | 3    |

If you add `PARTITION BY class`, the numbering restarts for each class.

> In our solution, we'll use `ROW_NUMBER()` to identify the **top N products per city**, based on total quantity sold.

---

## 📘 What is a CTE?

A **CTE (Common Table Expression)** is a temporary result set defined using the `WITH` keyword. It allows you to write **complex queries in a readable, modular way**, especially when working with window functions like `ROW_NUMBER()`.

Think of it like a named subquery that you can reference as if it's a table:

```sql
WITH ranked_sales AS (
  SELECT ...
)
SELECT ...
FROM ranked_sales
WHERE ...
```

---

## 📦 Downloadable SQL Scripts by Database

- 🐘 [PostgreSQL](../sql/top-n-per-group/postgres.sql)
- 🪟 [SQL Server](../sql/top-n-per-group/sql-server.sql)
- 🟠 [Oracle](../sql/top-n-per-group/oracle.sql)
- 🟡 [MySQL 8+](../sql/top-n-per-group/mysql-8plus.sql)
- ⚠️ [MySQL 5.7 or earlier](../sql/top-n-per-group/mysql-5.7.sql)

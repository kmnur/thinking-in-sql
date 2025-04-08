# Top N Records Per Group in SQL
**By Kazi Mohammad Ali Nur (Romel)**

> In the proposed solution, I’ve used `ROW_NUMBER()` in combination with a **Common Table Expression (CTE)** to extract the top N records per group.
>
> This approach is clean, modular, and supported across most modern SQL engines. The `ROW_NUMBER()` function allows us to rank each row within a partition (like rows per city), and the CTE helps us separate the ranking logic from the filtering logic.
>
> If you're new to either concept, don't worry — we’ll break down both below.

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

> In this tutorial, we’ll use a CTE to isolate the ranked rows before filtering out the top N per group.

---

## ✅ Solutions by Database

### 🐘 PostgreSQL

```sql
WITH ranked_sales AS (
  SELECT
    city,
    product,
    SUM(quantity) AS total_quantity,
    ROW_NUMBER() OVER (PARTITION BY city ORDER BY SUM(quantity) DESC) AS rn
  FROM sales
  GROUP BY city, product
)
SELECT city, product, total_quantity
FROM ranked_sales
WHERE rn <= 2;
```

---

### 🪟 SQL Server

```sql
WITH ranked_sales AS (
  SELECT
    city,
    product,
    SUM(quantity) AS total_quantity,
    ROW_NUMBER() OVER (PARTITION BY city ORDER BY SUM(quantity) DESC) AS rn
  FROM sales
  GROUP BY city, product
)
SELECT city, product, total_quantity
FROM ranked_sales
WHERE rn <= 2;
```

---

### 🟠 Oracle (12c+)

```sql
SELECT city, product, total_quantity
FROM (
  SELECT
    city,
    product,
    SUM(quantity) AS total_quantity,
    ROW_NUMBER() OVER (PARTITION BY city ORDER BY SUM(quantity) DESC) AS rn
  FROM sales
  GROUP BY city, product
)
WHERE rn <= 2;
```

---

### 🟡 MySQL 8+

```sql
WITH ranked_sales AS (
  SELECT
    city,
    product,
    SUM(quantity) AS total_quantity,
    ROW_NUMBER() OVER (PARTITION BY city ORDER BY SUM(quantity) DESC) AS rn
  FROM sales
  GROUP BY city, product
)
SELECT city, product, total_quantity
FROM ranked_sales
WHERE rn <= 2;
```

---

### ⚠️ MySQL 5.7 and Below

```sql
SELECT s1.city, s1.product, s1.total_quantity
FROM (
  SELECT city, product, SUM(quantity) AS total_quantity
  FROM sales
  GROUP BY city, product
) s1
WHERE (
  SELECT COUNT(*)
  FROM (
    SELECT city, product, SUM(quantity) AS total_quantity
    FROM sales
    GROUP BY city, product
  ) s2
  WHERE s2.city = s1.city
    AND s2.total_quantity > s1.total_quantity
) < 2;
```

---

## 📦 Downloadable SQL Scripts by Database

- 🐘 [PostgreSQL](../sql/top-n-per-group/postgres.sql)
- 🪟 [SQL Server](../sql/top-n-per-group/sql-server.sql)
- 🟠 [Oracle](../sql/top-n-per-group/oracle.sql)
- 🟡 [MySQL 8+](../sql/top-n-per-group/mysql-8plus.sql)
- ⚠️ [MySQL 5.7 or earlier](../sql/top-n-per-group/mysql-5.7.sql)
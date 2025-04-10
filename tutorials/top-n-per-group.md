---
layout: default
title: Top N Records Per Group
---

# Top N Records Per Group in SQL
**By Kazi Mohammad Ali Nur (Romel)**

> 🧠 Inspired by this Stack Overflow post:  
> [Select 2 products per city with most counts](https://stackoverflow.com/a/67475289/8651601)

This tutorial shows how to extract the top N entries per group using `ROW_NUMBER()` and `CTE`.  
We’ll apply this using real SQL examples across major databases.

---

## 🐘 PostgreSQL  
```sql
WITH ranked AS (
  SELECT city, product, COUNT(*) AS qty,
         ROW_NUMBER() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS rn
  FROM sales
  GROUP BY city, product
)
SELECT * FROM ranked WHERE rn <= 2;
```
👉 [Try it on DB Fiddle](https://dbfiddle.uk/ZlUjxoMm)

---

## 🪟 SQL Server  
Same logic applies in SQL Server — no changes needed.  
👉 [Try it on DB Fiddle](https://dbfiddle.uk/rsq8MqN8)

---

## 🟠 Oracle  
Oracle supports `ROW_NUMBER()` and CTEs as well.  
👉 [Try it on DB Fiddle](https://dbfiddle.uk/Q-1c5-R-)

---

## 🟡 MySQL 8+  
CTEs and `ROW_NUMBER()` are available starting from MySQL 8.  
👉 [Try it on DB Fiddle](https://dbfiddle.uk/MmB_1WEk)

---

## 🧠 Concept: What is ROW_NUMBER()?

`ROW_NUMBER()` is a **window function** that assigns a unique number to each row within a group, based on order.

```sql
SELECT student, score,
  ROW_NUMBER() OVER (ORDER BY score DESC) AS rank
FROM results;
```

| student | score | rank |
|---------|-------|------|
| Alice   | 95    | 1    |
| Bob     | 90    | 2    |
| Carol   | 85    | 3    |

---

## 📘 What is a CTE?

A **Common Table Expression (CTE)** is a temporary result set defined with `WITH`. It helps break down complex queries:

```sql
WITH ranked AS (
  SELECT ...
)
SELECT ...
FROM ranked
WHERE ...
```

---

✅ This approach works across major SQL databases and keeps your queries modular and readable.
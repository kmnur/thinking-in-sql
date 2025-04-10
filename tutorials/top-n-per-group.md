---
layout: default
title: Top N Records Per Group
---

# Top N Records Per Group in SQL

> 🧠 Inspired by this Stack Overflow post:  
> [Select 2 products per city with most counts](https://stackoverflow.com/a/67475289/8651601)

This tutorial shows how to extract the top N entries per group using `ROW_NUMBER()` and `CTE`.

```sql
WITH ranked AS (
  SELECT city, product, COUNT(*) AS qty,
         ROW_NUMBER() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS rn
  FROM sales
  GROUP BY city, product
)
SELECT * FROM ranked WHERE rn <= 2;
```

👉 [Try in DB Fiddle](https://dbfiddle.uk/ZlUjxoMm)
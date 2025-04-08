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
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
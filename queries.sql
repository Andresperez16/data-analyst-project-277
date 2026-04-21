-- Esta consulta cuenta el número total de clientes en la tabla customers
SELECT COUNT(*) AS customers_count
FROM customers;

-- Esta consulta obtiene los 10 vendedores con mayores ingresos totales
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM employees AS e
INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;

-- Esta consulta identifica a los vendedores cuyo promedio es inferior al global
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(
        AVG(s.quantity * p.price)
    ) AS average_income
FROM employees AS e
INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY seller
HAVING AVG(s.quantity * p.price) < (
    SELECT
        AVG(
            s2.quantity * p2.price
        )
    FROM sales AS s2
    INNER JOIN products AS p2 ON s2.product_id = p2.product_id
)
ORDER BY average_income ASC;

-- Ingreso por vendedor por día
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TRIM(LOWER(TO_CHAR(s.sale_date, 'Day'))) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM employees AS e
INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY
    EXTRACT(ISODOW FROM s.sale_date),
    TRIM(LOWER(TO_CHAR(s.sale_date, 'Day'))),
    CONCAT(e.first_name, ' ', e.last_name)
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date) ASC,
    seller ASC;

-- Esta consulta muestra los clientes por rango de edad
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

-- Agrupa las ventas por año-mes y suma los ingresos
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;

-- clientes cuya primera compra fue durante una promoción
SELECT
    sub.customer,
    sub.sale_date,
    sub.seller
FROM (
    SELECT
        s.sale_date,
        p.price,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.sale_date ASC
        ) AS purchase_order
    FROM sales AS s
    INNER JOIN customers AS c ON s.customer_id = c.customer_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
    INNER JOIN products AS p ON s.product_id = p.product_id
) AS sub
WHERE
    sub.purchase_order = 1
    AND sub.price = 0
ORDER BY sub.customer;

-- Obtiene los 10 productos más vendidos sumando sus cantidades
SELECT
    product_id AS "ProductID",
    SUM(quantity) AS "TotalQuantity"
FROM sales
GROUP BY product_id
ORDER BY "TotalQuantity" DESC
LIMIT 10;

-- Calcula los 10 productos con mayor recaudación total
SELECT
    s.product_id AS "ProductID",
    CAST(SUM(s.quantity * p.price) AS BIGINT) AS "Amount"
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY s.product_id
ORDER BY "Amount" DESC
LIMIT 10;

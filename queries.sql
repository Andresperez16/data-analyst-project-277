-- Esta consulta cuenta el número total de clientes en la tabla customers 
SELECT COUNT(*) AS customers_count
FROM customers;

--Esta consulta obtiene los 10 vendedores 
--con mayores ingresos totales  
select 
   CONCAT(e.first_name, ' ', e.last_name) as seller, 
   COUNT(s.sales_id) as operations,
   floor(SUM(s.quantity * p.price)) as income
from employees e 
join sales s on e.employee_id = s.sales_person_id
join products p on s.product_id = p.product_id
group by seller
order by income desc 
limit 10;

--Esta consulta identifica a los vendedores cuyo promedio de 
--ingresos por ventas es inferior al promedio global 
select 
   CONCAT(e.first_name, ' ', e.last_name) as seller, 
   FLOOR(AVG(s.quantity * p.price)) as average_income
from employees e 
join sales s on e.employee_id = s.sales_person_id
join products p on s.product_id = p.product_id 
group by seller 
having AVG(s.quantity * p.price) < (
   select AVG(s2.quantity * p2.price)
   from sales s2 
   join products p2 on s2.product_id = p2.product_id 
) 
order by average_income asc;
-- Ingreso por vendedor por día 
WITH data AS (
    SELECT 
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        TRIM(LOWER(TO_CHAR(s.sale_date, 'Day'))) AS day_of_week,
        s.quantity * p.price AS line_total,
        EXTRACT(ISODOW FROM s.sale_date) AS day_num
    FROM employees e 
    JOIN sales s ON e.employee_id = s.sales_person_id 
    JOIN products p ON s.product_id = p.product_id
)
SELECT 
    seller,
    day_of_week,
    FLOOR(SUM(line_total)) AS income
FROM data
GROUP BY day_num, day_of_week, seller
ORDER BY day_num ASC, seller ASC;

--Esta consulta muestra los clientes por rango de eddad
--y cuenta el total por grupo 
select
   case 
	  when age between 16 and 25 then '16-25' 
	  when age between 26 and 40 then '26-40'
	  else '40+'
   end as age_category,
   COUNT(*) as age_count 
 from customers 
 group by age_category 
 order by age_category; 

--Agrupa las ventas por año-mes y suma los ingresos 
select 
   TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
   COUNT(distinct s.customer_id) as total_cuatomers,
   floor(SUM(s.quantity * p.price)) as income 
from sales s 
join products p on s.product_id = p.product_id 
group by selling_month 
order by selling_month asc;

--clientes cuya primera compra fue 
--durante una promoción
WITH first_purchases AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        s.sale_date,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        p.price,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.sale_date ASC) as purchase_order
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN employees e ON s.sales_person_id = e.employee_id
    JOIN products p ON s.product_id = p.product_id
)
SELECT 
    customer,
    sale_date,
    seller
FROM first_purchases
WHERE purchase_order = 1 AND price = 0
ORDER BY customer;

-- Obtiene los 10 productos más vendidos sumando sus cantidades
SELECT 
    product_id AS "ProductID", 
    SUM(quantity) AS "TotalQuantity"
FROM sales
GROUP BY product_id
ORDER BY "TotalQuantity" DESC
LIMIT 10;

-- Calcula los 10 productos con mayor recaudación total (cantidad * precio)
SELECT 
    s.product_id AS "ProductID", 
    CAST(SUM(s.quantity * p.price) AS BIGINT) AS "Amount"
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY s.product_id
ORDER BY "Amount" DESC
LIMIT 10;

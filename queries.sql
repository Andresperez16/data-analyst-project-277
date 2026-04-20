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

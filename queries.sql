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

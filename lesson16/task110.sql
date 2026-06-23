-- Вывести отчёт показывающий по сотрудникам суммы продаж SUM(unit_price*quantity),
-- и сопоставляющий их со средним значением суммы продаж по сотрудникам (AVG по SUM(unit_price*quantity)) сортированный по сумме продаж по убыванию.
SELECT 
  e.first_name,
  e.last_name,
  SUM(od.unit_price * od.quantity) AS sum_sales,
  AVG(SUM(od.unit_price * od.quantity)) OVER () AS avg_sales
FROM employees e
JOIN orders o USING(employee_id)
JOIN order_details od USING(order_id)
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY sum_sales DESC;

-- Вывести ранг сотрудников по их зарплате, без пропусков. Также вывести имя, фамилию и должность.
SELECT 
  first_name,
  last_name,
  title,
  DENSE_RANK() OVER(ORDER BY salary) AS salary_rank
FROM employees;
-- 1. Создать представление, которое выводит следующие колонки:
-- order_date, required_date, shipped_date, ship_postal_code, company_name, contact_name, phone, last_name, first_name, title из таблиц orders, customers и employees.
-- Сделать select к созданному представлению, выведя все записи, где order_date больше 1го января 1997 года.
CREATE VIEW order_customer_employee_view AS
SELECT
  o.order_date,
  o.required_date,
  o.shipped_date,
  o.ship_postal_code,
  c.company_name,
  c.contact_name,
  c.phone,
  e.last_name,
  e.first_name,
  e.title,
FROM orders o
JOIN customers c USING(customer_id)
JOIN employees e USING(employee_id);

SELECT *
FROM order_customer_employee_view
WHERE order_date > '1.01.1997';

-- 2. Создать представление, которое выводит следующие колонки:
-- order_date, required_date, shipped_date, ship_postal_code, ship_country, company_name, contact_name, phone, last_name, first_name, title из таблиц orders, customers, employees.
-- Попробовать добавить к представлению (после его создания) колонки ship_country, postal_code и reports_to. Убедиться, что проихсодит ошибка. Переименовать представление и создать новое уже с дополнительными колонками.
-- Сделать к нему запрос, выбрав все записи, отсортировав их по ship_county.
-- Удалить переименованное представление.
CREATE VIEW order_customer_employee_view AS
SELECT
  o.order_date,
  o.required_date,
  o.shipped_date,
  o.ship_postal_code,
  c.company_name,
  c.contact_name,
  c.phone,
  e.last_name,
  e.first_name,
  e.title,
FROM orders o
JOIN customers c USING(customer_id)
JOIN employees e USING(employee_id);


ALTER VIEW order_customer_employee_view
ADD COLUMN ship_country varchar;

ALTER VIEW order_customer_employee_view
ADD COLUMN postal_code varchar;

ALTER VIEW order_customer_employee_view
ADD COLUMN reports_to int;

ALTER VIEW order_customer_employee_view
RENAME TO oce_old;

CREATE VIEW order_customer_employee_view AS
SELECT
  o.order_date,
  o.required_date,
  o.shipped_date,
  o.ship_postal_code,
  c.company_name,
  c.contact_name,
  c.phone,
  e.last_name,
  e.first_name,
  e.title,
  o.ship_country,
  c.postal_code,
  e.reports_to
FROM orders o
JOIN customers c USING(customer_id)
JOIN employees e USING(employee_id);

SELECT *
FROM order_customer_employee_view
ORDER BY ship_country;

DROP VIEW oce_old;

-- 3.  Создать представление "активных" (discontinued = 0) продуктов, содержащее все колонки. Представление должно быть защищено от вставки записей, в которых discontinued = 1.
-- Попробовать сделать вставку записи с полем discontinued = 1 - убедиться, что не проходит.
CREATE VIEW active_products AS
SELECT *
FROM products
WHERE discontinued = 0
WITH LOCAL CHECK OPTION;

INSERT INTO active_products (
  product_id,
  product_name,
  supplier_id,
  category_id,
  quantity_per_unit,
  unit_price,
  units_in_stock,
  units_on_order,
  reorder_level,
  discontinued
)
VALUES (
  78,
  'Aniseed Syrup',
  1,
  1,
  '10 boxes',
  20,
  50,
  0,
  10,
  1
);
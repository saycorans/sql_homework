-- 1. Создать таблицу exam с полями:
-- - идентификатора экзамена - автоинкрементируемый, уникальный, запрещает NULL;
-- - наименования экзамена
-- - даты экзамена
CREATE TABLE exam
(
	exam_id serial PRIMARY KEY,
	exam_name varchar,
	exam_date date
);

-- 2. Удалить ограничение уникальности с поля идентификатора
ALTER TABLE exam
DROP CONSTRAINT exam_pkey;


-- 3. Добавить ограничение первичного ключа на поле идентификатора
ALTER TABLE exam
ADD PRIMARY KEY (exam_id)

-- 4. Создать таблицу person с полями
-- - идентификатора личности (простой int, первичный ключ)
-- - имя
-- - фамилия
CREATE TABLE person
(
	person_id int,
	person_name varchar,
	person_surname varchar,

	CONSTRAINT PK_person_id PRIMARY KEY(person_id)
);

-- 5. Создать таблицу паспорта с полями:
-- - идентификатора паспорта (простой int, первичный ключ)
-- - серийный номер (простой int, запрещает NULL)
-- - регистрация
-- - ссылка на идентификатор личности (внешний ключ)
CREATE TABLE passport
(
	passport_id int,
	serial_number int NOT NULL,
	registration varchar,
	person_id int,

	CONSTRAINT PK_passport_id PRIMARY KEY(passport_id),
	CONSTRAINT FK_passport_person FOREIGN KEY(person_id) REFERENCES person(person_id)
);

-- 6. Добавить колонку веса в таблицу book (создавали ранее) с ограничением, проверяющим вес (больше 0 но меньше 100)
ALTER TABLE book
ADD COLUMN weight int 
CONSTRAINT CHK_book_weight 
CHECK(weight > 0 AND weight < 100);

-- 7. Убедиться в том, что ограничение на вес работает (попробуйте вставить невалидное значение)
INSERT INTO book
VALUES 
(1, 'title', 'isbn', 4 , -5);


-- 8. Создать таблицу student с полями:
-- - идентификатора (автоинкремент)
-- - полное имя
-- - курс (по умолчанию 1)
CREATE TABLE student
(
	student_id serial PRIMARY KEY,
	full_name varchar,
	course int DEFAULT 1
);

-- 9. Вставить запись в таблицу студентов и убедиться, что ограничение на вставку значения по умолчанию работает
INSERT INTO student (full_name)
VALUES 
('name');

-- 10. Удалить ограничение "по умолчанию" из таблицы студентов
ALTER TABLE student
ALTER COLUMN course DROP DEFAULT;

-- 11. Подключиться к БД northwind и добавить ограничение на поле unit_price таблицы products (цена должна быть больше 0)
ALTER TABLE products
ADD CONSTRAINT chk_products_unit_price
CHECK (unit_price > 0);

-- 12. "Навесить" автоинкрементируемый счётчик на поле product_id таблицы products (БД northwind). Счётчик должен начинаться с числа следующего за максимальным значением по этому столбцу.
CREATE SEQUENCE products_product_id_seq;
SELECT setval(
    'products_product_id_seq',
    (SELECT MAX(product_id) FROM products)
);
ALTER TABLE products
ALTER COLUMN product_id
SET DEFAULT nextval('products_product_id_seq');

-- 13. Произвести вставку в products (не вставляя идентификатор явно) и убедиться, что автоинкремент работает. Вставку сделать так, чтобы в результате команды вернулось значение, сгенерированное в качестве идентификатора.
INSERT INTO products (
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
    'Test Product',
    1,
    1,
    '10 boxes',
    25.00,
    100,
    0,
    10,
    0
)
RETURNING product_id;
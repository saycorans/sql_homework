-- 1. Создайте функцию, которая делает бэкап таблицы customers (копирует все данные в другую таблицу),предварительно стирая таблицу для бэкапа, если такая уже существует (чтобы в случае многократного запуска таблица для бэкапа перетиралась).
CREATE OR REPLACE FUNCTION backup_customers() 
RETURNS void AS $$
BEGIN
    DROP TABLE IF EXISTS backup_customers;
    CREATE TABLE backup_customers AS
    SELECT * FROM customers;
END;
$$ LANGUAGE plpgsql;

-- 2. Создать функцию, которая возвращает средний фрахт (freight) по всем заказам
CREATE OR REPLACE FUNCTION avg_freight_func() 
RETURNS int AS $$
SELECT AVG(freight) FROM orders;
$$ LANGUAGE SQL;

-- 3. Написать функцию, которая принимает два целочисленных параметра, используемых как нижняя и верхняя границы для генерации случайного числа в пределах этой границы (включая сами граничные значения).
-- Функция random генерирует вещественное число от 0 до 1.
-- Необходимо вычислить разницу между границами и прибавить единицу.
-- На полученное число умножить результат функции random() и прибавить к результату значение нижней границы.
-- Применить функцию floor() к конечному результату, чтобы не "уехать" за границу и получить целое число.
CREATE OR REPLACE FUNCTION random_number(a int, b int) 
RETURNS int AS $$
BEGIN
    RETURN FLOOR (
        random() * (b - a + 1) + a
    );
END;
$$ LANGUAGE plpgsql;

-- 4. Создать функцию, которая возвращает самые низкую и высокую зарплаты среди сотрудников заданного города
CREATE OR REPLACE FUNCTION salary_level(p_city_name varchar, OUT min_salary numeric, OUT max_salary numeric) AS $$
    SELECT
        MIN(salary),
        MAX(salary)
    FROM employees
    WHERE city = p_city_name;
$$
LANGUAGE SQL;

-- 5. Создать функцию, которая корректирует зарплату на заданный процент,  но не корректирует зарплату, если её уровень превышает заданный уровень при этом верхний уровень зарплаты по умолчанию равен 70, а процент коррекции равен 15%.
CREATE OR REPLACE FUNCTION adjust_salary(p_percent numeric DEFAULT 15.0, p_max_level numeric DEFAULT 70.0) 
RETURNS void AS $$
BEGIN
    UPDATE employees
    SET salary = salary * (1 + p_percent / 100.0)
    WHERE salary <= p_max_level;
END;
$$ LANGUAGE plpgsql;


-- 6. Модифицировать функцию, корректирующую зарплату таким образом, чтобы в результате коррекции, она так же выводила бы измененные записи.
CREATE OR REPLACE FUNCTION adjust_salary(p_percent numeric DEFAULT 15.0, p_max_level numeric DEFAULT 70.0) 
RETURNS SETOF employees AS $$
BEGIN
    UPDATE employees
    SET salary = salary * (1 + p_percent / 100.0)
    WHERE salary <= p_max_level;
END;
$$ LANGUAGE plpgsql;

-- 7. Модифицировать предыдущую функцию так, чтобы она возвращала только колонки last_name, first_name, title, salary
CREATE OR REPLACE FUNCTION adjust_salary(p_percent numeric DEFAULT 15.0, p_max_level numeric DEFAULT 70.0) 
RETURNS RETURNS TABLE (
    last_name varchar,
    first_name varchar,
    title varchar,
    salary numeric) AS $$
BEGIN
    UPDATE employees
    SET salary = salary * (1 + p_percent / 100.0)
    WHERE salary <= p_max_level;
END;
$$ LANGUAGE plpgsql;

-- 8. Написать функцию, которая принимает метод доставки и возвращает записи из таблицы orders в которых freight меньше значения, определяемого по следующему алгоритму:
-- - ищем максимум фрахта (freight) среди заказов по заданному методу доставки
-- - корректируем найденный максимум на 30% в сторону понижения
-- - вычисляем среднее значение фрахта среди заказов по заданному методу доставки
-- - вычисляем среднее значение между средним найденным на предыдущем шаге и скорректированным максимумом
-- - возвращаем все заказы в которых значение фрахта меньше найденного на предыдущем шаге среднего
CREATE OR REPLACE FUNCTION get_orders_by_freight_limit(p_ship_via smallint)
RETURNS SETOF orders AS $$
DECLARE
    v_max_freight numeric;
    v_reduced_max numeric;
    v_avg_freight numeric;
    v_final_limit numeric;
BEGIN
    SELECT MAX(freight) INTO v_max_freight
    FROM orders
    WHERE ship_via = p_ship_via;
    v_reduced_max := v_max_freight * 0.70;

    SELECT AVG(freight) INTO v_avg_freight
    FROM orders
    WHERE ship_via = p_ship_via;
    v_final_limit := (v_avg_freight + v_reduced_max) / 2;

    SELECT * FROM orders
    WHERE ship_via = p_ship_via AND freight < v_final_limit;
END;
$$ LANGUAGE plpgsql;

-- 9. Написать функцию, которая принимает:
-- уровень зарплаты, максимальную зарплату (по умолчанию 80) минимальную зарплату (по умолчанию 30), коэффициент роста зарплаты (по умолчанию 20%)
-- Если зарплата выше минимальной, то возвращает false
-- Если зарплата ниже минимальной, то увеличивает зарплату на коэффициент роста и проверяет не станет ли зарплата после повышения превышать максимальную.
-- Если превысит - возвращает false, в противном случае true.
-- Проверить реализацию, передавая следующие параметры
-- (где c - уровень з/п, max - макс. уровень з/п, min - минимальный уровень з/п, r - коэффициент):
-- c = 40, max = 80, min = 30, r = 0.2 - должна вернуть false
-- c = 79, max = 81, min = 80, r = 0.2 - должна вернуть false
-- c = 79, max = 95, min = 80, r = 0.2 - должна вернуть true
CREATE OR REPLACE FUNCTION check_salary_growth(
    p_current_salary numeric,
    p_max_salary = 80.0,
    p_min_salary = 30.0,
    p_growth_rate = 0.2
)
RETURNS boolean AS $$
DECLARE
    v_new_salary numeric;
BEGIN
    IF p_current_salary > p_min_salary THEN
        RETURN false;
    END IF;

    v_new_salary := p_current_salary * (1 + p_growth_rate);

    IF v_new_salary > p_max_salary THEN
        RETURN false;
    ELSE
        RETURN true;
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT check_salary_growth(40, 80, 30, 0.2);

SELECT check_salary_growth(79, 81, 80, 0.2);

SELECT check_salary_growth(79, 95, 80, 0.2);
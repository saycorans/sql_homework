-- Модифицировать функцию should_increase_salary разработанную в секции по функциям таким образом, чтобы запретить (выбрасывая исключения) передачу аргументов так, что:
-- минимальный уровень з/п превышает максимальный
-- ни минимальный, ни максимальный уровень з/п не могут быть меньше нуля
-- коэффициент повышения зарплаты не может быть ниже 5%
-- Протестировать реализацию, передавая следующие значения аргументов
-- (с - уровень "проверяемой" зарплаты, r - коэффициент повышения зарплаты):
-- c = 79, max = 10, min = 80, r = 0.2
-- c = 79, max = 10, min = -1, r = 0.2
-- c = 79, max = 10, min = 10, r = 0.04

create or replace function should_increase_salary(
	cur_salary numeric,
	max_salary numeric DEFAULT 80, 
	min_salary numeric DEFAULT 30,
	increase_rate numeric DEFAULT 0.2
	) returns bool AS $$
declare
	new_salary numeric;
begin
    -- минимальный уровень з/п превышает максимальный
    if min_salary > max_salary then
        raise exception 'Ошибка, введи мин заново';
    end if;

    -- ни минимальный, ни максимальный уровень з/п не могут быть меньше нуля
    if min_salary < 0 or max_salary < 0 then
        raise exception 'Ошибка зарплата должна быть больше 0';
    end if;

    -- коэффициент повышения зарплаты не может быть ниже 5%
    if increase_rate < 0.05 then 
        raise exception 'коэффициент повышения зарплаты не может быть ниже 0.05';
    end if;

	if cur_salary >= max_salary or cur_salary >= min_salary then 		
		return false;
	end if;
	
	if cur_salary < min_salary then
		new_salary = cur_salary + (cur_salary * increase_rate);
	end if;
	
	if new_salary > max_salary then
		return false;
	else
		return true;
	end if;	
end;
$$ language plpgsql;

SELECT * FROM should_increase_salary(79, 10, 80, 0.2)

SELECT * FROM should_increase_salary(79, 10, -1, 0.2)

SELECT * FROM should_increase_salary(79, 10, 10, 0.04)
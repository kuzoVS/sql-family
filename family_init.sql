
-- Схемы
CREATE SCHEMA mytabs;
CREATE SCHEMA myviews;

-- Таблица tab1: семьи
CREATE TABLE mytabs.tab1 (
    id SERIAL PRIMARY KEY
);

-- Таблица tab2: члены семьи
CREATE TABLE mytabs.tab2 (
    id SERIAL PRIMARY KEY,
    family_id INT REFERENCES mytabs.tab1(id),
    role TEXT CHECK (role IN ('husband', 'wife', 'child')),
    first_name TEXT,
    middle_name TEXT,
    last_name TEXT,
    birth_year INT,
    gender TEXT CHECK (gender IN ('male', 'female')),
    monthly_income NUMERIC,
    is_twin BOOLEAN
);

-- Данные: 3 семьи, >7 человек
INSERT INTO mytabs.tab1 DEFAULT VALUES; -- id = 1
INSERT INTO mytabs.tab1 DEFAULT VALUES; -- id = 2
INSERT INTO mytabs.tab1 DEFAULT VALUES; -- id = 3

-- Семья 1
INSERT INTO mytabs.tab2 (family_id, role, first_name, middle_name, last_name, birth_year, gender, monthly_income, is_twin)
VALUES
(1, 'husband', 'Иван', 'Иванович', 'Петров', 1980, 'male', 50000, NULL),
(1, 'wife',    'Мария', 'Андреевна', 'Петрова', 1985, 'female', 30000, NULL),
(1, 'child',   'Анна', 'Ивановна', 'Петрова', 2010, 'female', 0, FALSE),
(1, 'child',   'Олег', 'Иванович', 'Петров', 2010, 'male', 0, TRUE),
(1, 'child',   'Илья', 'Иванович', 'Петров', 2010, 'male', 0, TRUE);

-- Семья 2
INSERT INTO mytabs.tab2 (family_id, role, first_name, middle_name, last_name, birth_year, gender, monthly_income, is_twin)
VALUES
(2, 'husband', 'Сергей', 'Петрович', 'Сидоров', 1975, 'male', 0, NULL),
(2, 'wife',    'Ольга', 'Николаевна', 'Сидорова', 1990, 'female', 0, NULL),
(2, 'child',   'Кирилл', 'Сергеевич', 'Сидоров', 2015, 'male', 0, FALSE);

-- Семья 3
INSERT INTO mytabs.tab2 (family_id, role, first_name, middle_name, last_name, birth_year, gender, monthly_income, is_twin)
VALUES
(3, 'husband', 'Дмитрий', 'Алексеевич', 'Кузнецов', 1982, 'male', 40000, NULL),
(3, 'wife',    'Елена', 'Павловна', 'Кузнецова', 1983, 'female', 45000, NULL),
(3, 'child',   'Маша', 'Дмитриевна', 'Кузнецова', 2012, 'female', 0, FALSE);

-- Представления view1–view5

-- 1. Люди с доходом < 20000
CREATE MATERIALIZED VIEW myviews.view1 AS
SELECT * FROM mytabs.tab2
WHERE monthly_income < 20000;

-- 2. Дети младше 12 лет
CREATE MATERIALIZED VIEW myviews.view2 AS
SELECT * FROM mytabs.tab2
WHERE role = 'child' AND (EXTRACT(YEAR FROM CURRENT_DATE) - birth_year) < 12;

-- 3. Неработающие жёны, рождённые после 1988
CREATE MATERIALIZED VIEW myviews.view3 AS
SELECT * FROM mytabs.tab2
WHERE role = 'wife' AND monthly_income = 0 AND birth_year > 1988;

-- 4. Дети, у которых разница в возрасте родителей > 10 лет
CREATE MATERIALIZED VIEW myviews.view4 AS
SELECT c.*
FROM mytabs.tab2 c
JOIN mytabs.tab1 f ON c.family_id = f.id
JOIN mytabs.tab2 h ON h.family_id = f.id AND h.role = 'husband'
JOIN mytabs.tab2 w ON w.family_id = f.id AND w.role = 'wife'
WHERE c.role = 'child' AND ABS(h.birth_year - w.birth_year) > 10;

-- 5. Кол-во семей без близнецов
CREATE MATERIALIZED VIEW myviews.view5 AS
SELECT COUNT(DISTINCT f.id) AS families_without_twins
FROM mytabs.tab1 f
LEFT JOIN mytabs.tab2 m ON f.id = m.family_id AND m.role = 'child' AND m.is_twin = TRUE
WHERE m.id IS NULL;

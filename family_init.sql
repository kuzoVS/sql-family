-- Схемы
DROP SCHEMA IF EXISTS myviews CASCADE;
DROP SCHEMA IF EXISTS mytabs CASCADE;
CREATE SCHEMA mytabs;
CREATE SCHEMA myviews;

-- Таблица tab1: семьи с названиями
CREATE TABLE mytabs.tab1 (
    id SERIAL PRIMARY KEY,
    family_name TEXT NOT NULL
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

-- Вставка 7 семей с названиями
INSERT INTO mytabs.tab1 (family_name) VALUES
('Петровы'),
('Сидоровы'),
('Кузнецовы'),
('Ивановы'),
('Смирновы'),
('Фроловы'),
('Егоровы');

-- Вставка членов семьи (по 3 человека в каждую)
INSERT INTO mytabs.tab2 (family_id, role, first_name, middle_name, last_name, birth_year, gender, monthly_income, is_twin) VALUES
-- Петровы
(1, 'husband', 'Иван', 'Иванович', 'Петров', 1980, 'male', 50000, NULL),
(1, 'wife', 'Мария', 'Андреевна', 'Петрова', 1985, 'female', 30000, NULL),
(1, 'child', 'Анна', 'Ивановна', 'Петрова', 2010, 'female', 0, FALSE),

-- Сидоровы
(2, 'husband', 'Сергей', 'Петрович', 'Сидоров', 1975, 'male', 0, NULL),
(2, 'wife', 'Ольга', 'Николаевна', 'Сидорова', 1990, 'female', 0, NULL),
(2, 'child', 'Кирилл', 'Сергеевич', 'Сидоров', 2015, 'male', 0, FALSE),

-- Кузнецовы
(3, 'husband', 'Дмитрий', 'Алексеевич', 'Кузнецов', 1982, 'male', 40000, NULL),
(3, 'wife', 'Елена', 'Павловна', 'Кузнецова', 1983, 'female', 45000, NULL),
(3, 'child', 'Маша', 'Дмитриевна', 'Кузнецова', 2012, 'female', 0, FALSE),

-- Ивановы
(4, 'husband', 'Алексей', 'Николаевич', 'Иванов', 1970, 'male', 0, NULL),
(4, 'wife', 'Татьяна', 'Викторовна', 'Иванова', 1992, 'female', 0, NULL),
(4, 'child', 'Виктор', 'Алексеевич', 'Иванов', 2020, 'male', 0, TRUE),

-- Смирновы
(5, 'husband', 'Роман', 'Игоревич', 'Смирнов', 1979, 'male', 12000, NULL),
(5, 'wife', 'Инна', 'Олеговна', 'Смирнова', 1988, 'female', 15000, NULL),
(5, 'child', 'Олеся', 'Романовна', 'Смирнова', 2014, 'female', 0, FALSE),

-- Фроловы
(6, 'husband', 'Владимир', 'Сергеевич', 'Фролов', 1965, 'male', 6000, NULL),
(6, 'wife', 'Анастасия', 'Львовна', 'Фролова', 1970, 'female', 0, NULL),
(6, 'child', 'Лена', 'Владимировна', 'Фролова', 2008, 'female', 0, TRUE),

-- Егоровы
(7, 'husband', 'Олег', 'Валерьевич', 'Егоров', 1991, 'male', 0, NULL),
(7, 'wife', 'Ирина', 'Юрьевна', 'Егорова', 1993, 'female', 0, NULL),
(7, 'child', 'Максим', 'Олегович', 'Егоров', 2016, 'male', 0, FALSE);

-- Представления

CREATE MATERIALIZED VIEW myviews.view1 AS
SELECT * FROM mytabs.tab2
WHERE monthly_income < 20000;

CREATE MATERIALIZED VIEW myviews.view2 AS
SELECT * FROM mytabs.tab2
WHERE role = 'child' AND (EXTRACT(YEAR FROM CURRENT_DATE) - birth_year) < 12;

CREATE MATERIALIZED VIEW myviews.view3 AS
SELECT * FROM mytabs.tab2
WHERE role = 'wife' AND monthly_income = 0 AND birth_year > 1988;

CREATE MATERIALIZED VIEW myviews.view4 AS
SELECT c.*
FROM mytabs.tab2 c
JOIN mytabs.tab1 f ON c.family_id = f.id
JOIN mytabs.tab2 h ON h.family_id = f.id AND h.role = 'husband'
JOIN mytabs.tab2 w ON w.family_id = f.id AND w.role = 'wife'
WHERE c.role = 'child' AND ABS(h.birth_year - w.birth_year) > 10;

CREATE MATERIALIZED VIEW myviews.view5 AS
SELECT COUNT(DISTINCT f.id) AS families_without_twins
FROM mytabs.tab1 f
LEFT JOIN mytabs.tab2 m ON f.id = m.family_id AND m.role = 'child' AND m.is_twin = TRUE
WHERE m.id IS NULL;

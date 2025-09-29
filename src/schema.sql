-- Создание таблицы статусов продаж
CREATE TABLE IF NOT EXISTS sale_status (
    id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

COMMENT ON TABLE sale_status IS 'Справочник статусов продаж автомобилей';
COMMENT ON COLUMN sale_status.id IS 'Уникальный идентификатор статуса';
COMMENT ON COLUMN sale_status.status_name IS 'Наименование статуса';

-- Создание таблицы брендов автомобилей
CREATE TABLE IF NOT EXISTS car_brand (
    id SERIAL PRIMARY KEY,
    brand_name VARCHAR(50) NOT NULL UNIQUE,
    country VARCHAR(50)
);

COMMENT ON TABLE car_brand IS 'Справочник брендов автомобилей';
COMMENT ON COLUMN car_brand.brand_name IS 'Название бренда';
COMMENT ON COLUMN car_brand.country IS 'Страна производитель';

-- Создание таблицы автомобилей
CREATE TABLE IF NOT EXISTS car (
    id SERIAL PRIMARY KEY,
    brand_id INTEGER NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL CHECK (year >= 1900 AND year <= EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    color VARCHAR(50),
    price DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    mileage INTEGER CHECK (mileage >= 0),
    vin VARCHAR(17) UNIQUE,
    engine_volume DECIMAL(3,1) CHECK (engine_volume > 0),
    transmission VARCHAR(20) CHECK (transmission IN ('Автомат', 'Механика', 'Робот', 'Вариатор')),
    fuel_type VARCHAR(20) CHECK (fuel_type IN ('Бензин', 'Дизель', 'Электричество', 'Гибрид')),
    is_available BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id) REFERENCES car_brand(id) ON DELETE RESTRICT
);

COMMENT ON TABLE car IS 'Таблица автомобилей';
COMMENT ON COLUMN car.id IS 'Уникальный идентификатор автомобиля';
COMMENT ON COLUMN car.brand_id IS 'Ссылка на бренд (внешний ключ)';
COMMENT ON COLUMN car.model IS 'Модель автомобиля';
COMMENT ON COLUMN car.year IS 'Год выпуска (1900-текущий+1)';
COMMENT ON COLUMN car.color IS 'Цвет автомобиля';
COMMENT ON COLUMN car.price IS 'Стоимость автомобиля (>= 0)';
COMMENT ON COLUMN car.mileage IS 'Пробег (км)';
COMMENT ON COLUMN car.vin IS 'VIN код (уникальный)';
COMMENT ON COLUMN car.engine_volume IS 'Объем двигателя (л)';
COMMENT ON COLUMN car.transmission IS 'Тип коробки передач';
COMMENT ON COLUMN car.fuel_type IS 'Тип топлива';
COMMENT ON COLUMN car.is_available IS 'Доступен для продажи';

-- Создание таблицы клиентов
CREATE TABLE IF NOT EXISTS customer (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    passport_series VARCHAR(4),
    passport_number VARCHAR(6),
    address TEXT
);

COMMENT ON TABLE customer IS 'Таблица клиентов автосалона';
COMMENT ON COLUMN customer.id IS 'Уникальный идентификатор клиента';
COMMENT ON COLUMN customer.first_name IS 'Имя клиента';
COMMENT ON COLUMN customer.last_name IS 'Фамилия клиента';
COMMENT ON COLUMN customer.phone IS 'Телефон клиента';
COMMENT ON COLUMN customer.email IS 'Email клиента (уникальный)';
COMMENT ON COLUMN customer.passport_series IS 'Серия паспорта';
COMMENT ON COLUMN customer.passport_number IS 'Номер паспорта';

-- Создание таблицы продаж
CREATE TABLE IF NOT EXISTS sale (
    id SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sale_price DECIMAL(12,2) NOT NULL CHECK (sale_price >= 0),
    manager_name VARCHAR(100) NOT NULL,
    status_id INTEGER NOT NULL,
    payment_method VARCHAR(20) CHECK (payment_method IN ('Наличные', 'Кредит', 'Рассрочка', 'Безналичные')),
    contract_number VARCHAR(50) UNIQUE,
    FOREIGN KEY (car_id) REFERENCES car(id) ON DELETE RESTRICT,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE,
    FOREIGN KEY (status_id) REFERENCES sale_status(id) ON DELETE RESTRICT
);

COMMENT ON TABLE sale IS 'Таблица продаж автомобилей';
COMMENT ON COLUMN sale.id IS 'Уникальный идентификатор продажи';
COMMENT ON COLUMN sale.car_id IS 'Ссылка на автомобиль (внешний ключ)';
COMMENT ON COLUMN sale.customer_id IS 'Ссылка на клиента (внешний ключ)';
COMMENT ON COLUMN sale.sale_date IS 'Дата и время продажи';
COMMENT ON COLUMN sale.sale_price IS 'Цена продажи (>= 0)';
COMMENT ON COLUMN sale.manager_name IS 'Имя менеджера по продажам';
COMMENT ON COLUMN sale.status_id IS 'Статус продажи (внешний ключ)';
COMMENT ON COLUMN sale.payment_method IS 'Способ оплаты';
COMMENT ON COLUMN sale.contract_number IS 'Номер договора (уникальный)';

-- Создание таблицы тест-драйвов
CREATE TABLE IF NOT EXISTS test_drive (
    id SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    drive_date TIMESTAMP NOT NULL,
    duration_minutes INTEGER CHECK (duration_minutes BETWEEN 15 AND 120),
    manager_notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (car_id) REFERENCES car(id) ON DELETE RESTRICT,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE
);

COMMENT ON TABLE test_drive IS 'Таблица записи на тест-драйвы';
COMMENT ON COLUMN test_drive.drive_date IS 'Дата и время тест-драйва';
COMMENT ON COLUMN test_drive.duration_minutes IS 'Продолжительность (15-120 минут)';
COMMENT ON COLUMN test_drive.manager_notes IS 'Заметки менеджера';

-- Создание индексов
CREATE INDEX IF NOT EXISTS idx_car_brand_id ON car(brand_id);
CREATE INDEX IF NOT EXISTS idx_car_price ON car(price);
CREATE INDEX IF NOT EXISTS idx_car_year ON car(year);
CREATE INDEX IF NOT EXISTS idx_car_available ON car(is_available) WHERE is_available = true;

CREATE INDEX IF NOT EXISTS idx_sale_car_id ON sale(car_id);
CREATE INDEX IF NOT EXISTS idx_sale_customer_id ON sale(customer_id);
CREATE INDEX IF NOT EXISTS idx_sale_date ON sale(sale_date);
CREATE INDEX IF NOT EXISTS idx_sale_status_id ON sale(status_id);

CREATE INDEX IF NOT EXISTS idx_test_drive_car_id ON test_drive(car_id);
CREATE INDEX IF NOT EXISTS idx_test_drive_customer_id ON test_drive(customer_id);
CREATE INDEX IF NOT EXISTS idx_test_drive_date ON test_drive(drive_date);

-- Заполнение справочника статусов
INSERT INTO sale_status (status_name) VALUES
    ('Забронирован'),
    ('Ожидает оплаты'),
    ('Оплачен'),
    ('Передан клиенту'),
    ('Отменен')
ON CONFLICT (status_name) DO NOTHING;

-- Заполнение брендов
INSERT INTO car_brand (brand_name, country) VALUES
    ('Toyota', 'Япония'),
    ('BMW', 'Германия'),
    ('Mercedes-Benz', 'Германия'),
    ('Audi', 'Германия'),
    ('Hyundai', 'Корея'),
    ('Kia', 'Корея'),
    ('Lada', 'Россия'),
    ('Ford', 'США'),
    ('Volkswagen', 'Германия'),
    ('Skoda', 'Чехия'),
    ('Lexus', 'Япония'),
    ('Porsche', 'Германия')
ON CONFLICT (brand_name) DO NOTHING;

-- Заполнение автомобилей
INSERT INTO car (brand_id, model, year, color, price, mileage, vin, engine_volume, transmission, fuel_type, is_available) VALUES
    ((SELECT id FROM car_brand WHERE brand_name = 'Toyota'), 'Camry', 2023, 'Черный', 2500000.00, 0, '1HGCM82633A123456', 2.5, 'Автомат', 'Бензин', true),
    ((SELECT id FROM car_brand WHERE brand_name = 'BMW'), 'X5', 2022, 'Белый', 5500000.00, 15000, '5UXKR0C58K0L12345', 3.0, 'Автомат', 'Бензин', true),
    ((SELECT id FROM car_brand WHERE brand_name = 'Mercedes-Benz'), 'E-Class', 2023, 'Серый', 4800000.00, 0, 'W1K1770841A123456', 2.0, 'Автомат', 'Дизель', true),
    ((SELECT id FROM car_brand WHERE brand_name = 'Audi'), 'A6', 2022, 'Синий', 4200000.00, 25000, 'WAUZZFYFXNA123456', 2.0, 'Автомат', 'Бензин', false),
    ((SELECT id FROM car_brand WHERE brand_name = 'Hyundai'), 'Solaris', 2023, 'Красный', 1200000.00, 0, 'Z94CB41BAER123456', 1.6, 'Механика', 'Бензин', true),
    ((SELECT id FROM car_brand WHERE brand_name = 'Kia'), 'Rio', 2023, 'Серебристый', 1150000.00, 0, 'Z94CB41BAER123457', 1.6, 'Автомат', 'Бензин', true),
    ((SELECT id FROM car_brand WHERE brand_name = 'Lada'), 'Vesta', 2023, 'Оранжевый', 900000.00, 0, 'XTA217030K1234567', 1.6, 'Механика', 'Бензин', true),
    ((SELECT id FROM car_brand WHERE brand_name = 'Ford'), 'Focus', 2022, 'Зеленый', 1500000.00, 18000, 'WF0FXXGCDPJ123456', 1.5, 'Автомат', 'Бензин', true),
    ((SELECT id FROM car_brand WHERE brand_name = 'Volkswagen'), 'Tiguan', 2023, 'Черный', 2800000.00, 0, 'WVGZZZ5NZKW123456', 2.0, 'Автомат', 'Бензин', true),
    ((SELECT id FROM car_brand WHERE brand_name = 'Lexus'), 'RX', 2023, 'Белый', 6200000.00, 0, '2T2BZMCA5KC123456', 3.5, 'Автомат', 'Гибрид', true),
    ((SELECT id FROM car_brand WHERE brand_name = 'Porsche'), 'Cayenne', 2022, 'Желтый', 8500000.00, 12000, 'WP1AA2A59NL123456', 3.0, 'Автомат', 'Бензин', false)
ON CONFLICT (id) DO NOTHING;

-- Заполнение клиентов
INSERT INTO customer (first_name, last_name, phone, email, passport_series, passport_number, address) VALUES
    ('Иван', 'Петров', '+79161234567', 'ivan.petrov@mail.ru', '4510', '123456', 'Москва, ул. Ленина, д. 10'),
    ('Мария', 'Сидорова', '+79162345678', 'maria.sidorova@mail.ru', '4511', '234567', 'Москва, ул. Пушкина, д. 25'),
    ('Алексей', 'Козлов', '+79163456789', 'alexey.kozlov@mail.ru', '4512', '345678', 'Москва, пр. Мира, д. 15'),
    ('Елена', 'Николаева', '+79164567890', 'elena.nikolaeva@mail.ru', '4513', '456789', 'Москва, ул. Гагарина, д. 8'),
    ('Дмитрий', 'Васильев', '+79165678901', 'dmitry.vasilev@mail.ru', '4514', '567890', 'Москва, ул. Садовая, д. 12'),
    ('Ольга', 'Павлова', '+79166789012', 'olga.pavlova@mail.ru', '4515', '678901', 'Москва, ул. Центральная, д. 5'),
    ('Сергей', 'Федоров', '+79167890123', 'sergey.fedorov@mail.ru', '4516', '789012', 'Москва, ул. Лесная, д. 20'),
    ('Анна', 'Морозова', '+79168901234', 'anna.morozova@mail.ru', '4517', '890123', 'Москва, ул. Школьная, д. 3'),
    ('Павел', 'Зайцев', '+79169012345', 'pavel.zaytsev@mail.ru', '4518', '901234', 'Москва, ул. Парковая, д. 7'),
    ('Ирина', 'Семенова', '+79160123456', 'irina.semenova@mail.ru', '4519', '012345', 'Москва, ул. Заречная, д. 14')
ON CONFLICT (id) DO NOTHING;

-- Заполнение продаж
INSERT INTO sale (car_id, customer_id, sale_date, sale_price, manager_name, status_id, payment_method, contract_number) VALUES
    (4, 1, '2024-01-15 10:30:00', 4100000.00, 'Сергей Иванов', 4, 'Кредит', 'ДГ-2024-001'),
    (11, 2, '2024-01-16 11:15:00', 8400000.00, 'Анна Петрова', 4, 'Безналичные', 'ДГ-2024-002'),
    (1, 3, '2024-01-20 14:20:00', 2500000.00, 'Сергей Иванов', 3, 'Рассрочка', 'ДГ-2024-003'),
    (2, 4, '2024-01-22 09:45:00', 5500000.00, 'Анна Петрова', 2, 'Наличные', 'ДГ-2024-004'),
    (3, 5, '2024-01-25 16:30:00', 4800000.00, 'Дмитрий Сидоров', 1, 'Кредит', 'ДГ-2024-005')
ON CONFLICT (id) DO NOTHING;

-- Заполнение тест-драйвов
INSERT INTO test_drive (car_id, customer_id, drive_date, duration_minutes, manager_notes) VALUES
    (5, 6, '2024-02-01 10:00:00', 30, 'Клиенту понравилась плавность хода'),
    (6, 7, '2024-02-01 11:30:00', 45, 'Интересуется условиями кредита'),
    (7, 8, '2024-02-02 14:00:00', 30, 'Сравнивает с конкурентами'),
    (8, 9, '2024-02-02 16:00:00', 60, 'Очень доволен динамикой'),
    (9, 10, '2024-02-03 12:00:00', 45, 'Планирует покупку через месяц')
ON CONFLICT (id) DO NOTHING;
-- Создание таблицы статусов продаж
CREATE TABLE IF NOT EXISTS sale_status (
    id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

-- Создание таблицы брендов автомобилей
CREATE TABLE IF NOT EXISTS car_brand (
    id SERIAL PRIMARY KEY,
    brand_name VARCHAR(50) NOT NULL UNIQUE,
    country VARCHAR(50)
);

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
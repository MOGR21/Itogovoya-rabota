-- 1. Список всех проданных автомобилей за последний месяц с информацией о клиентах
SELECT
    s.sale_date,
    cb.brand_name,
    c.model,
    c.year,
    c.color,
    s.sale_price,
    cust.first_name || ' ' || cust.last_name as customer_name,
    s.manager_name,
    ss.status_name
FROM sale s
JOIN car c ON s.car_id = c.id
JOIN car_brand cb ON c.brand_id = cb.id
JOIN customer cust ON s.customer_id = cust.id
JOIN sale_status ss ON s.status_id = ss.id
WHERE s.sale_date >= CURRENT_DATE - INTERVAL '1 month'
ORDER BY s.sale_date DESC;

-- 2. Топ-5 самых продаваемых брендов
SELECT
    cb.brand_name,
    COUNT(s.id) as sales_count,
    SUM(s.sale_price) as total_revenue
FROM car_brand cb
JOIN car c ON cb.id = c.brand_id
JOIN sale s ON c.id = s.car_id
GROUP BY cb.id, cb.brand_name
ORDER BY sales_count DESC
LIMIT 5;

-- 3. Доступные автомобили по цене от меньшей к большей
SELECT
    cb.brand_name,
    c.model,
    c.year,
    c.color,
    c.price,
    c.mileage,
    c.transmission,
    c.fuel_type
FROM car c
JOIN car_brand cb ON c.brand_id = cb.id
WHERE c.is_available = true
ORDER BY c.price ASC;

-- 4. Клиенты, купившие больше одного автомобиля
SELECT
    cust.first_name || ' ' || cust.last_name as customer_name,
    cust.phone,
    cust.email,
    COUNT(s.id) as cars_purchased,
    SUM(s.sale_price) as total_spent
FROM customer cust
JOIN sale s ON cust.id = s.customer_id
GROUP BY cust.id, customer_name, cust.phone, cust.email
HAVING COUNT(s.id) > 1
ORDER BY cars_purchased DESC;

-- 5. Ежемесячная статистика продаж
SELECT
    DATE_TRUNC('month', sale_date) as month,
    COUNT(*) as sales_count,
    SUM(sale_price) as total_revenue,
    AVG(sale_price) as average_price
FROM sale
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY month DESC;

-- 6. Обновление статуса автомобиля при продаже
UPDATE car
SET is_available = false
WHERE id = 1;

-- 7. Обновление цены автомобиля (скидка 5% на все автомобили старше 2022 года)
UPDATE car
SET price = price * 0.95
WHERE year < 2023 AND is_available = true;

-- 8. Обновление пробега после тест-драйва
UPDATE car
SET mileage = mileage + 50
WHERE id IN (
    SELECT car_id FROM test_drive
    WHERE drive_date >= CURRENT_DATE - INTERVAL '1 day'
);

-- 9. Удаление отмененных продаж старше 1 года
DELETE FROM sale
WHERE status_id = (SELECT id FROM sale_status WHERE status_name = 'Отменен')
AND sale_date < CURRENT_DATE - INTERVAL '1 year';

-- 10. Удаление записей о тест-драйвах старше 2 лет
DELETE FROM test_drive
WHERE drive_date < CURRENT_DATE - INTERVAL '2 years';

-- 11. Автомобили с пробегом менее 1000 км (новые)
SELECT
    cb.brand_name,
    c.model,
    c.year,
    c.color,
    c.price,
    c.mileage
FROM car c
JOIN car_brand cb ON c.brand_id = cb.id
WHERE c.mileage < 1000 AND c.is_available = true
ORDER BY c.price DESC;

-- 12. Статистика по менеджерам по продажам
SELECT
    manager_name,
    COUNT(*) as sales_count,
    SUM(sale_price) as total_revenue,
    AVG(sale_price) as average_sale
FROM sale
GROUP BY manager_name
ORDER BY total_revenue DESC;
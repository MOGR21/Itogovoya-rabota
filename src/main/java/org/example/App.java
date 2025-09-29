package org.example;

import java.sql.*;
import java.util.Properties;
import java.io.FileInputStream;
import java.io.IOException;

public class App {
    private Connection connection;

    public static void main(String[] args) {
        App app = new App();
        try {
            app.run();
        } catch (Exception e) {
            System.err.println("Ошибка при выполнении приложения: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void run() {
        try {
            Properties props = loadProperties();
            connectToDatabase(props);
            demonstrateCRUDOperations();
        } catch (SQLException | IOException e) {
            System.err.println("Ошибка: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeConnection();
        }
    }

    private Properties loadProperties() throws IOException {
        Properties props = new Properties();
        try (FileInputStream in = new FileInputStream("src/main/resources/application.properties")) {
            props.load(in);
        }
        return props;
    }

    private void connectToDatabase(Properties props) throws SQLException {
        String url = props.getProperty("db.url");
        String username = props.getProperty("db.username");
        String password = props.getProperty("db.password");

        connection = DriverManager.getConnection(url, username, password);
        System.out.println("✅ Успешное подключение к базе данных автосалона");
    }

    private void demonstrateCRUDOperations() throws SQLException {
        connection.setAutoCommit(false);

        try {
            System.out.println("\n=== АВТОСАЛОН - ДЕМОНСТРАЦИЯ CRUD ОПЕРАЦИЙ ===\n");

            // 1. Добавление нового автомобиля и клиента
            insertNewCarAndCustomer();

            // 2. Создание записи на тест-драйв
            createTestDrive();

            // 3. Просмотр доступных автомобилей
            viewAvailableCars();

            // 4. Регистрация продажи автомобиля
            registerCarSale();

            // 5. Обновление информации об автомобиле
            updateCarInformation();

            // 6. Удаление тестовых записей
            deleteTestRecords();

            connection.commit();
            System.out.println("\n✅ Все операции автосалона успешно выполнены!");

        } catch (SQLException e) {
            connection.rollback();
            System.err.println("❌ Ошибка при выполнении операций. Транзакция откачена.");
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    private void insertNewCarAndCustomer() throws SQLException {
        System.out.println("1. ДОБАВЛЕНИЕ НОВОГО АВТОМОБИЛЯ И КЛИЕНТА:");

        // Добавление нового автомобиля
        String insertCarSQL = """
            INSERT INTO car (brand_id, model, year, color, price, mileage, vin, 
                           engine_volume, transmission, fuel_type, is_available) 
            VALUES (
                (SELECT id FROM car_brand WHERE brand_name = ?),
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
            )
        """;

        try (PreparedStatement pstmt = connection.prepareStatement(insertCarSQL)) {
            pstmt.setString(1, "Toyota");
            pstmt.setString(2, "RAV4");
            pstmt.setInt(3, 2024);
            pstmt.setString(4, "Серый");
            pstmt.setDouble(5, 3200000.00);
            pstmt.setInt(6, 0);
            pstmt.setString(7, "2T3ZF4DV5NW123456");
            pstmt.setDouble(8, 2.5);
            pstmt.setString(9, "Автомат");
            pstmt.setString(10, "Бензин");
            pstmt.setBoolean(11, true);

            int rowsAffected = pstmt.executeUpdate();
            System.out.println("   ✅ Добавлен новый автомобиль Toyota RAV4: " + rowsAffected + " строк(а)");
        }

        // Добавление нового клиента
        String insertCustomerSQL = """
            INSERT INTO customer (first_name, last_name, phone, email, 
                                passport_series, passport_number, address) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;

        try (PreparedStatement pstmt = connection.prepareStatement(insertCustomerSQL)) {
            pstmt.setString(1, "Андрей");
            pstmt.setString(2, "Волков");
            pstmt.setString(3, "+79165554433");
            pstmt.setString(4, "andrey.volkov@mail.ru");
            pstmt.setString(5, "4520");
            pstmt.setString(6, "112233");
            pstmt.setString(7, "Москва, ул. Солнечная, д. 45");

            int rowsAffected = pstmt.executeUpdate();
            System.out.println("   ✅ Добавлен новый клиент Андрей Волков: " + rowsAffected + " строк(а)");
        }
    }

    private void createTestDrive() throws SQLException {
        System.out.println("\n2. ЗАПИСЬ НА ТЕСТ-ДРАЙВ:");

        String insertTestDriveSQL = """
            INSERT INTO test_drive (car_id, customer_id, drive_date, duration_minutes, manager_notes) 
            VALUES (
                (SELECT id FROM car WHERE model = ? AND is_available = true),
                (SELECT id FROM customer WHERE email = ?),
                ?,
                ?,
                ?
            )
        """;

        try (PreparedStatement pstmt = connection.prepareStatement(insertTestDriveSQL)) {
            pstmt.setString(1, "RAV4");
            pstmt.setString(2, "andrey.volkov@mail.ru");
            pstmt.setTimestamp(3, Timestamp.valueOf("2024-02-10 15:30:00"));
            pstmt.setInt(4, 45);
            pstmt.setString(5, "Новый клиент, интересуется кроссоверами");

            int rowsAffected = pstmt.executeUpdate();
            System.out.println("   ✅ Создана запись на тест-драйв: " + rowsAffected + " строк(а)");
        }
    }

    private void viewAvailableCars() throws SQLException {
        System.out.println("\n3. ДОСТУПНЫЕ АВТОМОБИЛИ В НАЛИЧИИ:");

        String selectCarsSQL = """
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
            ORDER BY cb.brand_name, c.price
            LIMIT 8
        """;

        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(selectCarsSQL)) {

            System.out.println("   ╔══════════╦════════════╦══════╦══════════╦══════════════╦══════════╦═════════════╗");
            System.out.println("   ║ Бренд    ║ Модель     ║ Год  ║ Цвет     ║ Цена         ║ Пробег   ║ КПП         ║");
            System.out.println("   ╠══════════╬════════════╬══════╬══════════╬══════════════╬══════════╬═════════════╣");

            while (rs.next()) {
                String brand = rs.getString("brand_name");
                String model = rs.getString("model");
                int year = rs.getInt("year");
                String color = rs.getString("color");
                double price = rs.getDouble("price");
                int mileage = rs.getInt("mileage");
                String transmission = rs.getString("transmission");

                // Форматирование для таблицы
                if (brand.length() > 8) brand = brand.substring(0, 7) + ".";
                if (model.length() > 10) model = model.substring(0, 9) + ".";
                if (color.length() > 8) color = color.substring(0, 7) + ".";

                System.out.printf("   ║ %-8s ║ %-10s ║ %-4d ║ %-8s ║ %-10.2f ║ %-8d ║ %-11s ║%n",
                        brand, model, year, color, price/1000000, mileage, transmission);
            }
            System.out.println("   ╚══════════╩════════════╩══════╩══════════╩══════════════╩══════════╩═════════════╝");
            System.out.println("   * Цены указаны в млн руб.");
        }
    }

    private void registerCarSale() throws SQLException {
        System.out.println("\n4. РЕГИСТРАЦИЯ ПРОДАЖИ АВТОМОБИЛЯ:");

        String insertSaleSQL = """
            INSERT INTO sale (car_id, customer_id, sale_price, manager_name, 
                            status_id, payment_method, contract_number) 
            VALUES (
                (SELECT id FROM car WHERE model = ? AND is_available = true),
                (SELECT id FROM customer WHERE email = ?),
                ?,
                ?,
                (SELECT id FROM sale_status WHERE status_name = 'Оплачен'),
                ?,
                ?
            )
        """;

        try (PreparedStatement pstmt = connection.prepareStatement(insertSaleSQL)) {
            pstmt.setString(1, "Camry");
            pstmt.setString(2, "andrey.volkov@mail.ru");
            pstmt.setDouble(3, 2450000.00);
            pstmt.setString(4, "Сергей Иванов");
            pstmt.setString(5, "Кредит");
            pstmt.setString(6, "ДГ-2024-006");

            int rowsAffected = pstmt.executeUpdate();
            System.out.println("   ✅ Зарегистрирована продажа Toyota Camry: " + rowsAffected + " строк(а)");

            // Обновляем статус автомобиля
            String updateCarSQL = "UPDATE car SET is_available = false WHERE model = ? AND is_available = true";
            try (PreparedStatement updateStmt = connection.prepareStatement(updateCarSQL)) {
                updateStmt.setString(1, "Camry");
                updateStmt.executeUpdate();
                System.out.println("   ✅ Статус автомобиля обновлен: продан");
            }
        }
    }

    private void updateCarInformation() throws SQLException {
        System.out.println("\n5. ОБНОВЛЕНИЕ ИНФОРМАЦИИ ОБ АВТОМОБИЛЕ:");

        // Применяем скидку на автомобили с пробегом
        String updatePriceSQL = """
            UPDATE car 
            SET price = price * 0.92 
            WHERE mileage > 10000 AND is_available = true
        """;

        try (Statement stmt = connection.createStatement()) {
            int rowsAffected = stmt.executeUpdate(updatePriceSQL);
            System.out.println("   ✅ Применена скидка 8% для " + rowsAffected + " автомобилей с пробегом");
        }

        // Обновление пробега после тест-драйвов
        String updateMileageSQL = """
            UPDATE car 
            SET mileage = mileage + 30 
            WHERE id IN (
                SELECT car_id FROM test_drive 
                WHERE drive_date >= CURRENT_DATE - INTERVAL '3 days'
            )
        """;

        try (Statement stmt = connection.createStatement()) {
            int rowsAffected = stmt.executeUpdate(updateMileageSQL);
            System.out.println("   ✅ Обновлен пробег для " + rowsAffected + " автомобилей после тест-драйвов");
        }
    }

    private void deleteTestRecords() throws SQLException {
        System.out.println("\n6. УДАЛЕНИЕ ТЕСТОВЫХ ЗАПИСЕЙ:");

        // Удаление тестовой продажи
        String deleteSaleSQL = "DELETE FROM sale WHERE contract_number = ?";
        try (PreparedStatement pstmt = connection.prepareStatement(deleteSaleSQL)) {
            pstmt.setString(1, "ДГ-2024-006");
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("   ✅ Удалено продаж: " + rowsAffected + " строк(а)");
        }

        // Удаление тестового тест-драйва
        String deleteTestDriveSQL = "DELETE FROM test_drive WHERE manager_notes LIKE ?";
        try (PreparedStatement pstmt = connection.prepareStatement(deleteTestDriveSQL)) {
            pstmt.setString(1, "%Новый клиент%");
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("   ✅ Удалено тест-драйвов: " + rowsAffected + " строк(а)");
        }

        // Удаление тестового клиента
        String deleteCustomerSQL = "DELETE FROM customer WHERE email = ?";
        try (PreparedStatement pstmt = connection.prepareStatement(deleteCustomerSQL)) {
            pstmt.setString(1, "andrey.volkov@mail.ru");
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("   ✅ Удалено клиентов: " + rowsAffected + " строк(а)");
        }

        // Удаление тестового автомобиля
        String deleteCarSQL = "DELETE FROM car WHERE vin = ?";
        try (PreparedStatement pstmt = connection.prepareStatement(deleteCarSQL)) {
            pstmt.setString(1, "2T3ZF4DV5NW123456");
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("   ✅ Удалено автомобилей: " + rowsAffected + " строк(а)");
        }
    }

    private void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("\n🔌 Подключение к базе данных автосалона закрыто");
            } catch (SQLException e) {
                System.err.println("Ошибка при закрытии подключения: " + e.getMessage());
            }
        }
    }
}

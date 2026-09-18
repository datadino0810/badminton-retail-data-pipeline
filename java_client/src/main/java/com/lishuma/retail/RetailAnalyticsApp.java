package com.lishuma.retail;

import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public final class RetailAnalyticsApp {
    private RetailAnalyticsApp() {
    }

    public static void main(String[] args) {
        if (args.length < 2) {
            printUsage();
            return;
        }

        String databaseUrl = "jdbc:sqlite:" + Path.of(args[0]).toAbsolutePath();
        String report = args[1];

        try (Connection connection = DriverManager.getConnection(databaseUrl)) {
            connection.createStatement().execute("PRAGMA foreign_keys = ON");
            switch (report) {
                case "inventory" -> showInventoryAlerts(connection);
                case "top-products" -> requireArguments(args, 4, () -> showTopProducts(connection, args[2], args[3]));
                case "average-price" -> requireArguments(args, 3, () -> showAverageRacquetPrice(connection, args[2]));
                case "revenue" -> showRevenueByGroup(connection);
                case "no-sales" -> showProductsWithNoSales(connection);
                case "supplier-restock" -> showSupplierRestockList(connection);
                default -> printUsage();
            }
        } catch (SQLException error) {
            System.err.println("Database query failed: " + error.getMessage());
            System.exit(1);
        }
    }

    private static void showInventoryAlerts(Connection connection) throws SQLException {
        String sql = """
                SELECT product_code, product_name, city, quantity_on_hand, reorder_level, stock_status
                FROM inventory_status
                WHERE stock_status IN ('Low stock', 'Out of stock')
                ORDER BY quantity_on_hand, product_name
                """;

        try (Statement statement = connection.createStatement();
             ResultSet rows = statement.executeQuery(sql)) {
            System.out.printf("%-8s %-30s %-14s %8s %8s %-12s%n",
                    "Code", "Product", "City", "On hand", "Reorder", "Status");
            while (rows.next()) {
                System.out.printf("%-8s %-30s %-14s %8d %8d %-12s%n",
                        rows.getString("product_code"),
                        rows.getString("product_name"),
                        rows.getString("city"),
                        rows.getInt("quantity_on_hand"),
                        rows.getInt("reorder_level"),
                        rows.getString("stock_status"));
            }
        }
    }

    private static void showTopProducts(Connection connection, String startDate, String endDate)
            throws SQLException {
        String sql = """
                SELECT p.product_name,
                       SUM(si.quantity_sold) AS units_sold,
                       SUM(si.quantity_sold * si.unit_price_cents) / 100.0 AS revenue
                FROM sale_item AS si
                JOIN sale AS s ON s.sale_id = si.sale_id
                JOIN product AS p ON p.product_code = si.product_code
                WHERE s.sale_date BETWEEN ? AND ?
                GROUP BY p.product_code, p.product_name
                ORDER BY units_sold DESC, revenue DESC
                LIMIT 5
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, startDate);
            statement.setString(2, endDate);
            try (ResultSet rows = statement.executeQuery()) {
                System.out.printf("%-30s %10s %12s%n", "Product", "Units", "Revenue");
                while (rows.next()) {
                    System.out.printf("%-30s %10d %12.2f%n",
                            rows.getString("product_name"),
                            rows.getInt("units_sold"),
                            rows.getDouble("revenue"));
                }
            }
        }
    }

    private static void showAverageRacquetPrice(Connection connection, String brandName)
            throws SQLException {
        String sql = """
                SELECT b.brand_name, AVG(p.retail_price_cents) / 100.0 AS average_price
                FROM product AS p
                JOIN brand AS b ON b.brand_id = p.brand_id
                JOIN category AS c ON c.category_id = p.category_id
                WHERE c.category_name = 'Racquet' AND b.brand_name = ?
                GROUP BY b.brand_id, b.brand_name
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, brandName);
            try (ResultSet rows = statement.executeQuery()) {
                if (rows.next()) {
                    System.out.printf("Average %s racquet price: %.2f%n",
                            rows.getString("brand_name"),
                            rows.getDouble("average_price"));
                } else {
                    System.out.println("No racquets were found for that brand.");
                }
            }
        }
    }

    private static void showRevenueByGroup(Connection connection) throws SQLException {
        String sql = """
                SELECT CASE
                           WHEN c.category_name = 'Apparel' THEN 'Apparel'
                           WHEN c.category_name IN ('Racquet', 'Shuttlecock') THEN 'Equipment'
                           ELSE 'Other'
                       END AS revenue_group,
                       SUM(si.quantity_sold * si.unit_price_cents) / 100.0 AS revenue
                FROM sale_item AS si
                JOIN product AS p ON p.product_code = si.product_code
                JOIN category AS c ON c.category_id = p.category_id
                GROUP BY revenue_group
                ORDER BY revenue DESC
                """;

        try (Statement statement = connection.createStatement();
             ResultSet rows = statement.executeQuery(sql)) {
            System.out.printf("%-12s %12s%n", "Group", "Revenue");
            while (rows.next()) {
                System.out.printf("%-12s %12.2f%n",
                        rows.getString("revenue_group"),
                        rows.getDouble("revenue"));
            }
        }
    }

    private static void showProductsWithNoSales(Connection connection) throws SQLException {
        String sql = """
                SELECT p.product_code, p.product_name
                FROM product AS p
                LEFT JOIN sale_item AS si ON si.product_code = p.product_code
                WHERE si.product_code IS NULL
                ORDER BY p.product_name
                """;

        try (Statement statement = connection.createStatement();
             ResultSet rows = statement.executeQuery(sql)) {
            while (rows.next()) {
                System.out.printf("%s  %s%n",
                        rows.getString("product_code"),
                        rows.getString("product_name"));
            }
        }
    }

    private static void showSupplierRestockList(Connection connection) throws SQLException {
        String sql = """
                SELECT s.supplier_name, p.product_name, l.city,
                       i.quantity_on_hand, i.reorder_level
                FROM inventory AS i
                JOIN product AS p ON p.product_code = i.product_code
                JOIN supplier AS s ON s.supplier_id = p.supplier_id
                JOIN store_location AS l ON l.location_id = i.location_id
                WHERE i.quantity_on_hand <= i.reorder_level
                ORDER BY s.supplier_name, p.product_name
                """;

        try (Statement statement = connection.createStatement();
             ResultSet rows = statement.executeQuery(sql)) {
            System.out.printf("%-30s %-30s %-14s %8s %8s%n",
                    "Supplier", "Product", "City", "On hand", "Reorder");
            while (rows.next()) {
                System.out.printf("%-30s %-30s %-14s %8d %8d%n",
                        rows.getString("supplier_name"),
                        rows.getString("product_name"),
                        rows.getString("city"),
                        rows.getInt("quantity_on_hand"),
                        rows.getInt("reorder_level"));
            }
        }
    }

    private static void requireArguments(String[] args, int expected, SqlAction action) throws SQLException {
        if (args.length < expected) {
            printUsage();
            return;
        }
        action.run();
    }

    private static void printUsage() {
        System.out.println("Usage: RetailAnalyticsApp <database> <report> [parameters]");
        System.out.println("Reports:");
        System.out.println("  inventory");
        System.out.println("  top-products <start date> <end date>");
        System.out.println("  average-price <brand name>");
        System.out.println("  revenue");
        System.out.println("  no-sales");
        System.out.println("  supplier-restock");
    }

    @FunctionalInterface
    private interface SqlAction {
        void run() throws SQLException;
    }
}

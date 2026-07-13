package com.pcs.support;

import java.net.URI;
import java.net.URISyntaxException;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Set;

final class LocalMariaDbTestDatabase {

    static final String DATABASE_NAME = "test_pcs_integration";
    private static final String DEFAULT_JDBC_URL = "jdbc:mariadb://localhost:3306/" + DATABASE_NAME;
    private static final Set<String> ALLOWED_HOSTS = Set.of("localhost", "127.0.0.1", "::1");

    private static final String JDBC_URL = setting("pcs.test.db.url", "PCS_TEST_DB_URL", DEFAULT_JDBC_URL);
    private static final String USERNAME = setting("pcs.test.db.username", "DB_USER", "localuser");
    private static final String PASSWORD = setting("pcs.test.db.password", "DB_PASSWORD", "pcs123#");

    private static boolean initialized;

    private LocalMariaDbTestDatabase() {
    }

    static synchronized void initialize() {
        if (initialized) {
            return;
        }

        URI uri = validateAndParse(JDBC_URL);
        String serverUrl = serverUrl(uri);

        try (var connection = DriverManager.getConnection(serverUrl, USERNAME, PASSWORD);
             var statement = connection.createStatement()) {
            statement.executeUpdate(
                    "CREATE DATABASE IF NOT EXISTS `" + DATABASE_NAME
                            + "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            );
        } catch (SQLException exception) {
            throw new IllegalStateException("Unable to create the isolated MariaDB integration test database.", exception);
        }

        try (var connection = DriverManager.getConnection(JDBC_URL, USERNAME, PASSWORD);
             var statement = connection.createStatement();
             var resultSet = statement.executeQuery("SELECT DATABASE()")) {
            if (!resultSet.next() || !DATABASE_NAME.equals(resultSet.getString(1))) {
                throw new IllegalStateException("Connected database does not match the isolated integration test database.");
            }
        } catch (SQLException exception) {
            throw new IllegalStateException("Unable to connect to the isolated MariaDB integration test database.", exception);
        }

        initialized = true;
    }

    static URI validateAndParse(String jdbcUrl) {
        if (jdbcUrl == null || !jdbcUrl.startsWith("jdbc:mariadb://")) {
            throw new IllegalStateException("Integration tests require a MariaDB JDBC URL.");
        }

        try {
            URI uri = new URI(jdbcUrl.substring("jdbc:".length()));
            if (!"mariadb".equalsIgnoreCase(uri.getScheme()) || !ALLOWED_HOSTS.contains(uri.getHost())) {
                throw new IllegalStateException("Integration tests may connect only to local MariaDB.");
            }

            String path = uri.getPath();
            String databaseName = path == null || path.length() < 2 ? "" : path.substring(1);
            if (!DATABASE_NAME.equals(databaseName)) {
                throw new IllegalStateException(
                        "Integration tests may use only " + DATABASE_NAME + "; requested: " + databaseName
                );
            }
            return uri;
        } catch (URISyntaxException exception) {
            throw new IllegalStateException("Invalid MariaDB integration test JDBC URL.", exception);
        }
    }

    static String jdbcUrl() {
        return JDBC_URL;
    }

    static String username() {
        return USERNAME;
    }

    static String password() {
        return PASSWORD;
    }

    private static String serverUrl(URI uri) {
        String url = "jdbc:mariadb://" + uri.getRawAuthority() + "/";
        return uri.getRawQuery() == null ? url : url + "?" + uri.getRawQuery();
    }

    private static String setting(String systemProperty, String environmentVariable, String fallback) {
        String propertyValue = System.getProperty(systemProperty);
        if (propertyValue != null && !propertyValue.isBlank()) {
            return propertyValue;
        }
        String environmentValue = System.getenv(environmentVariable);
        return environmentValue == null || environmentValue.isBlank() ? fallback : environmentValue;
    }
}

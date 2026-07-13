package com.pcs.support;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.MariaDBContainer;
import org.testcontainers.DockerClientFactory;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
public abstract class MariaDbIntegrationTest {

    private static final String MODE_PROPERTY = "pcs.test.db.mode";
    private static final String MODE_ENVIRONMENT_VARIABLE = "PCS_TEST_DB_MODE";
    private static final MariaDBContainer<?> MARIADB = new MariaDBContainer<>("mariadb:10.11")
            .withDatabaseName("pcs_test")
            .withUsername("pcs")
            .withPassword("pcs");
    private static DatabaseConnection databaseConnection;

    @DynamicPropertySource
    static void registerDataSourceProperties(DynamicPropertyRegistry registry) {
        DatabaseConnection connection = initializeDatabase();
        registry.add("spring.datasource.url", connection::jdbcUrl);
        registry.add("spring.datasource.username", connection::username);
        registry.add("spring.datasource.password", connection::password);
        registry.add("spring.datasource.driver-class-name", connection::driverClassName);
        registry.add("spring.datasource.hikari.maximum-pool-size", () -> "2");
        registry.add("pcs.jwt.allow-default-secret", () -> "true");
    }

    private static synchronized DatabaseConnection initializeDatabase() {
        if (databaseConnection != null) {
            return databaseConnection;
        }

        DatabaseMode mode = DatabaseMode.fromSetting(readMode());
        if (mode == DatabaseMode.CONTAINER
                || mode == DatabaseMode.AUTO && DockerClientFactory.instance().isDockerAvailable()) {
            MARIADB.start();
            databaseConnection = new DatabaseConnection(
                    MARIADB.getJdbcUrl(),
                    MARIADB.getUsername(),
                    MARIADB.getPassword(),
                    MARIADB.getDriverClassName()
            );
            return databaseConnection;
        }

        LocalMariaDbTestDatabase.initialize();
        databaseConnection = new DatabaseConnection(
                LocalMariaDbTestDatabase.jdbcUrl(),
                LocalMariaDbTestDatabase.username(),
                LocalMariaDbTestDatabase.password(),
                "org.mariadb.jdbc.Driver"
        );
        return databaseConnection;
    }

    private static String readMode() {
        String systemProperty = System.getProperty(MODE_PROPERTY);
        if (systemProperty != null && !systemProperty.isBlank()) {
            return systemProperty;
        }
        String environmentVariable = System.getenv(MODE_ENVIRONMENT_VARIABLE);
        return environmentVariable == null || environmentVariable.isBlank() ? "auto" : environmentVariable;
    }

    private enum DatabaseMode {
        AUTO,
        LOCAL,
        CONTAINER;

        private static DatabaseMode fromSetting(String value) {
            try {
                return valueOf(value.trim().toUpperCase());
            } catch (IllegalArgumentException exception) {
                throw new IllegalStateException(
                        MODE_PROPERTY + " must be one of: auto, local, container; requested: " + value,
                        exception
                );
            }
        }
    }

    private record DatabaseConnection(
            String jdbcUrl,
            String username,
            String password,
            String driverClassName
    ) {
    }
}

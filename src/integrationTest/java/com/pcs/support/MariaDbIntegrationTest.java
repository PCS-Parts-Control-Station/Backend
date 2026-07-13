package com.pcs.support;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
public abstract class MariaDbIntegrationTest {

    @DynamicPropertySource
    static void registerDataSourceProperties(DynamicPropertyRegistry registry) {
        LocalMariaDbTestDatabase.initialize();
        registry.add("spring.datasource.url", LocalMariaDbTestDatabase::jdbcUrl);
        registry.add("spring.datasource.username", LocalMariaDbTestDatabase::username);
        registry.add("spring.datasource.password", LocalMariaDbTestDatabase::password);
        registry.add("spring.datasource.driver-class-name", () -> "org.mariadb.jdbc.Driver");
        registry.add("spring.datasource.hikari.maximum-pool-size", () -> "2");
        registry.add("pcs.jwt.allow-default-secret", () -> "true");
    }
}

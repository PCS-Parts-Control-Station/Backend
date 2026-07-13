package com.pcs.support;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;

class LocalMariaDbTestDatabaseTest {

    @Test
    void acceptsOnlyLocalDedicatedTestDatabase() {
        var uri = LocalMariaDbTestDatabase.validateAndParse(
                "jdbc:mariadb://localhost:3306/test_pcs_integration"
        );

        assertThat(uri.getHost()).isEqualTo("localhost");
        assertThat(uri.getPath()).isEqualTo("/test_pcs_integration");
    }

    @Test
    void rejectsDevelopmentDatabase() {
        assertThatThrownBy(() -> LocalMariaDbTestDatabase.validateAndParse(
                "jdbc:mariadb://localhost:3306/pcs_db"
        ))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("test_pcs_integration");
    }

    @Test
    void rejectsRemoteDatabase() {
        assertThatThrownBy(() -> LocalMariaDbTestDatabase.validateAndParse(
                "jdbc:mariadb://db.example.com:3306/test_pcs_integration"
                ))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("local MariaDB");
    }
}

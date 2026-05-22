USE pcs_db;

ALTER TABLE tb_member
    ADD COLUMN IF NOT EXISTS password_changed_at DATETIME(6) NULL AFTER temp_password_expires_at,
    ADD COLUMN IF NOT EXISTS login_failed_count INT NOT NULL DEFAULT 0 AFTER last_login_at,
    ADD COLUMN IF NOT EXISTS locked_until_at DATETIME(6) NULL AFTER login_failed_count,
    ADD COLUMN IF NOT EXISTS last_login_ip VARCHAR(45) NULL AFTER locked_until_at,
    ADD COLUMN IF NOT EXISTS last_login_user_agent VARCHAR(500) NULL AFTER last_login_ip;

SET @chk_member_owner_slot_exists = (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'tb_member'
      AND CONSTRAINT_NAME = 'chk_member_owner_slot'
);

SET @chk_member_owner_slot_sql = IF(
    @chk_member_owner_slot_exists = 0,
    'ALTER TABLE tb_member ADD CONSTRAINT chk_member_owner_slot CHECK ((role = ''OWNER'' AND owner_slot = 1) OR (role <> ''OWNER'' AND owner_slot IS NULL))',
    'SELECT 1'
);

PREPARE chk_member_owner_slot_stmt FROM @chk_member_owner_slot_sql;
EXECUTE chk_member_owner_slot_stmt;
DEALLOCATE PREPARE chk_member_owner_slot_stmt;

CREATE TABLE IF NOT EXISTS tb_auth_refresh_token (
    token_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    member_id BIGINT NOT NULL,
    refresh_token_hash CHAR(64) NOT NULL,
    token_family_id VARCHAR(36) NOT NULL,
    expires_at DATETIME(6) NOT NULL,
    last_used_at DATETIME(6) NULL,
    revoked_at DATETIME(6) NULL,
    revoked_reason ENUM('LOGOUT', 'ROTATED', 'REUSE_DETECTED', 'ADMIN_REVOKED') NULL,
    replaced_by_token_id BIGINT NULL,
    created_ip VARCHAR(45) NULL,
    created_user_agent VARCHAR(500) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (token_id),
    CONSTRAINT uk_auth_refresh_token_hash UNIQUE (refresh_token_hash),
    INDEX idx_auth_refresh_member_active (company_id, member_id, revoked_at, expires_at),
    INDEX idx_auth_refresh_family (company_id, member_id, token_family_id),
    INDEX idx_auth_refresh_replaced_by (replaced_by_token_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tb_auth_login_history (
    history_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NULL,
    member_id BIGINT NULL,
    company_code_snapshot VARCHAR(50) NULL,
    login_id_snapshot VARCHAR(50) NOT NULL,
    login_result ENUM('SUCCESS', 'FAIL', 'LOCKED', 'INACTIVE', 'TEMP_PASSWORD_EXPIRED') NOT NULL,
    failure_reason VARCHAR(100) NULL,
    login_ip VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (history_id),
    INDEX idx_auth_login_history_company_date (company_id, created_at),
    INDEX idx_auth_login_history_member_date (company_id, member_id, created_at),
    INDEX idx_auth_login_history_login_id_date (login_id_snapshot, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

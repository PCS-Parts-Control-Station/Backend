DROP TABLE IF EXISTS tb_auth_login_history;
DROP TABLE IF EXISTS tb_auth_refresh_token;
DROP TABLE IF EXISTS tb_company_staff_permission_disabled;
DROP TABLE IF EXISTS tb_trade_partner;
DROP TABLE IF EXISTS tb_member;
DROP TABLE IF EXISTS tb_company;

CREATE TABLE tb_company (
    company_id BIGINT NOT NULL AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    company_code VARCHAR(50) NOT NULL,
    representative_email VARCHAR(255) NULL,
    representative_phone VARCHAR(30) NULL,
    business_registration_no VARCHAR(20) NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (company_id),
    CONSTRAINT uk_company_code UNIQUE (company_code),
    CONSTRAINT uk_company_business_registration_no UNIQUE (business_registration_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_member (
    member_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    login_id VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role ENUM('OWNER', 'ADMIN', 'STAFF') NOT NULL,
    owner_slot TINYINT NULL,
    password_status ENUM('TEMPORARY', 'ACTIVE') NOT NULL,
    temp_password_expires_at DATETIME(6) NULL,
    password_changed_at DATETIME(6) NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at DATETIME(6) NULL,
    login_failed_count INT NOT NULL DEFAULT 0,
    locked_until_at DATETIME(6) NULL,
    last_login_ip VARCHAR(45) NULL,
    last_login_user_agent VARCHAR(500) NULL,
    created_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (member_id),
    CONSTRAINT uk_member_company_login UNIQUE (company_id, login_id),
    CONSTRAINT uk_member_company_owner UNIQUE (company_id, owner_slot),
    CONSTRAINT chk_member_owner_slot CHECK (
        (role = 'OWNER' AND owner_slot = 1)
        OR (role <> 'OWNER' AND owner_slot IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_company_staff_permission_disabled (
    disabled_permission_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    permission_code ENUM(
        'STAFF_PARTNER_MANAGE',
        'STAFF_PART_CREATE',
        'STAFF_CATEGORY_MANAGE',
        'STAFF_INBOUND',
        'STAFF_INSPECTION',
        'STAFF_OUTBOUND'
    ) NOT NULL,
    disabled_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (disabled_permission_id),
    CONSTRAINT uk_company_staff_permission_disabled UNIQUE (company_id, permission_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_auth_refresh_token (
    token_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    member_id BIGINT NOT NULL,
    refresh_token_hash CHAR(64) NOT NULL,
    token_family_id VARCHAR(36) NOT NULL,
    expires_at DATETIME(6) NOT NULL,
    revoked_at DATETIME(6) NULL,
    revoked_reason ENUM('ROTATED', 'LOGOUT', 'EXPIRED', 'REUSE_DETECTED', 'ADMIN_REVOKED') NULL,
    replaced_by_token_id BIGINT NULL,
    created_ip VARCHAR(45) NULL,
    created_user_agent VARCHAR(500) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (token_id),
    CONSTRAINT uk_auth_refresh_token_hash UNIQUE (refresh_token_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_auth_login_history (
    login_history_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NULL,
    member_id BIGINT NULL,
    company_code_snapshot VARCHAR(50) NOT NULL,
    login_id_snapshot VARCHAR(50) NOT NULL,
    login_result ENUM('SUCCESS', 'FAIL', 'INACTIVE', 'LOCKED', 'TEMP_PASSWORD_EXPIRED') NOT NULL,
    failure_reason VARCHAR(100) NULL,
    login_ip VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (login_history_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_trade_partner (
    partner_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    partner_name VARCHAR(150) NOT NULL,
    partner_type ENUM('PC_CAFE', 'PERSON', 'COMPANY', 'ETC') NOT NULL,
    partner_role ENUM('SUPPLIER', 'CUSTOMER', 'BOTH') NOT NULL,
    phone VARCHAR(50) NULL,
    email VARCHAR(150) NULL,
    address VARCHAR(500) NULL,
    memo VARCHAR(1000) NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    last_transaction_at DATETIME(6) NULL,
    PRIMARY KEY (partner_id),
    CONSTRAINT uk_trade_partner_company_name UNIQUE (company_id, partner_name),
    CONSTRAINT uk_trade_partner_company_partner_id UNIQUE (company_id, partner_id),
    INDEX idx_trade_partner_company_role (company_id, partner_role, active),
    INDEX idx_trade_partner_company_type (company_id, partner_type, active),
    INDEX idx_trade_partner_company_created_by (company_id, created_by),
    INDEX idx_trade_partner_company_last_transaction (company_id, last_transaction_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO tb_company (
    company_id,
    company_name,
    company_code,
    representative_email,
    representative_phone,
    business_registration_no,
    active
) VALUES
    (1, 'ACME Parts', 'acme', 'acme@example.com', '02-1000-1000', '111-11-11111', TRUE),
    (2, 'Other Parts', 'other', 'other@example.com', '02-2000-2000', '222-22-22222', TRUE),
    (3, 'Inactive Parts', 'inactive', NULL, NULL, '333-33-33333', FALSE);

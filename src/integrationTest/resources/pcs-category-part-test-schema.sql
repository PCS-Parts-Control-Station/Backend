DROP TABLE IF EXISTS tb_inspection;
DROP TABLE IF EXISTS tb_stock_movement_unit;
DROP TABLE IF EXISTS tb_stock_movement;
DROP TABLE IF EXISTS tb_stock_document;
DROP TABLE IF EXISTS tb_pc_part_unit;
DROP TABLE IF EXISTS tb_part_spec_value;
DROP TABLE IF EXISTS tb_part_stock;
DROP TABLE IF EXISTS tb_pc_part;
DROP TABLE IF EXISTS tb_part_spec_option;
DROP TABLE IF EXISTS tb_part_spec_definition;
DROP TABLE IF EXISTS tb_part_category;
DROP TABLE IF EXISTS tb_member;
DROP TABLE IF EXISTS tb_company;

CREATE TABLE tb_company (
    company_id BIGINT NOT NULL AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    company_code VARCHAR(50) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (company_id),
    CONSTRAINT uk_company_code UNIQUE (company_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_member (
    member_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    login_id VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role ENUM('OWNER', 'ADMIN', 'STAFF') NOT NULL,
    owner_slot TINYINT NULL,
    password_status ENUM('TEMPORARY', 'ACTIVE') NOT NULL DEFAULT 'ACTIVE',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (member_id),
    CONSTRAINT uk_member_company_login UNIQUE (company_id, login_id),
    CONSTRAINT uk_member_company_member_id UNIQUE (company_id, member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_part_category (
    category_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    created_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (category_id),
    CONSTRAINT uk_part_category_company_name UNIQUE (company_id, category_name),
    CONSTRAINT uk_part_category_company_category_id UNIQUE (company_id, category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_part_spec_definition (
    spec_definition_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    spec_key VARCHAR(80) NOT NULL,
    spec_name VARCHAR(100) NOT NULL,
    input_type ENUM('TEXT', 'NUMBER', 'SELECT', 'BOOLEAN') NOT NULL,
    unit VARCHAR(30) NULL,
    required BOOLEAN NOT NULL DEFAULT FALSE,
    searchable BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (spec_definition_id),
    CONSTRAINT uk_part_spec_definition_company_category_key UNIQUE (company_id, category_id, spec_key),
    CONSTRAINT uk_part_spec_definition_company_definition_id UNIQUE (company_id, spec_definition_id),
    CONSTRAINT chk_part_spec_definition_sort_order CHECK (sort_order >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_part_spec_option (
    option_id BIGINT NOT NULL AUTO_INCREMENT,
    spec_definition_id BIGINT NOT NULL,
    option_label VARCHAR(100) NOT NULL,
    option_value VARCHAR(100) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (option_id),
    CONSTRAINT uk_part_spec_option_definition_value UNIQUE (spec_definition_id, option_value),
    CONSTRAINT chk_part_spec_option_sort_order CHECK (sort_order >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_pc_part (
    part_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    created_by BIGINT NULL,
    part_name VARCHAR(150) NOT NULL,
    model_name VARCHAR(150) NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    part_code VARCHAR(80) NOT NULL,
    safe_quantity INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (part_id),
    CONSTRAINT uk_pc_part_company_code UNIQUE (company_id, part_code),
    CONSTRAINT uk_pc_part_company_part_id UNIQUE (company_id, part_id),
    CONSTRAINT chk_pc_part_safe_quantity CHECK (safe_quantity >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_part_stock (
    stock_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    part_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (stock_id),
    CONSTRAINT uk_part_stock_company_part UNIQUE (company_id, part_id),
    CONSTRAINT chk_part_stock_quantity CHECK (quantity >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_pc_part_unit (
    unit_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    part_id BIGINT NOT NULL,
    internal_serial_no VARCHAR(80) NOT NULL,
    manufacturer_serial_no VARCHAR(120) NULL,
    unit_status ENUM('IN_STOCK', 'OUTBOUND', 'DISPOSED', 'CANCELED') NOT NULL DEFAULT 'IN_STOCK',
    grade ENUM('NONE', 'A', 'B', 'C', 'DEFECTIVE') NOT NULL DEFAULT 'NONE',
    inspection_status ENUM('WAITING', 'COMPLETED') NOT NULL DEFAULT 'WAITING',
    sales_status ENUM('HOLD', 'AVAILABLE', 'UNAVAILABLE') NOT NULL DEFAULT 'HOLD',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (unit_id),
    CONSTRAINT uk_pc_part_unit_internal_serial UNIQUE (company_id, internal_serial_no),
    CONSTRAINT uk_pc_part_unit_manufacturer_serial UNIQUE (company_id, manufacturer_serial_no),
    CONSTRAINT uk_pc_part_unit_company_unit_id UNIQUE (company_id, unit_id),
    CONSTRAINT uk_pc_part_unit_company_part_unit_id UNIQUE (company_id, part_id, unit_id),
    INDEX idx_pc_part_unit_company_part (company_id, part_id),
    INDEX idx_pc_part_unit_company_status (company_id, unit_status, active),
    INDEX idx_pc_part_unit_work_status (company_id, inspection_status, sales_status, grade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_stock_document (
    document_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    partner_id BIGINT NULL,
    document_no VARCHAR(80) NOT NULL,
    document_type ENUM('INBOUND', 'OUTBOUND') NOT NULL,
    document_status ENUM('COMPLETED', 'CANCELED') NOT NULL DEFAULT 'COMPLETED',
    reason VARCHAR(500) NULL,
    processed_by BIGINT NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (document_id),
    CONSTRAINT uk_stock_document_document_no UNIQUE (document_no),
    CONSTRAINT uk_stock_document_company_document_id UNIQUE (company_id, document_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_stock_movement (
    movement_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    document_id BIGINT NOT NULL,
    part_id BIGINT NOT NULL,
    movement_type ENUM('INBOUND', 'OUTBOUND', 'INBOUND_CANCEL', 'OUTBOUND_CANCEL') NOT NULL,
    movement_status ENUM('COMPLETED', 'CANCELED') NOT NULL DEFAULT 'COMPLETED',
    canceled_movement_id BIGINT NULL,
    quantity INT NOT NULL,
    before_quantity INT NOT NULL,
    after_quantity INT NOT NULL,
    reason VARCHAR(500) NULL,
    processed_by BIGINT NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (movement_id),
    CONSTRAINT uk_stock_movement_company_movement_id UNIQUE (company_id, movement_id),
    CONSTRAINT chk_stock_movement_quantity CHECK (quantity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_stock_movement_unit (
    movement_unit_id BIGINT NOT NULL AUTO_INCREMENT,
    movement_id BIGINT NOT NULL,
    unit_id BIGINT NOT NULL,
    before_unit_status ENUM('IN_STOCK', 'OUTBOUND', 'DISPOSED', 'CANCELED') NULL,
    after_unit_status ENUM('IN_STOCK', 'OUTBOUND', 'DISPOSED', 'CANCELED') NOT NULL,
    PRIMARY KEY (movement_unit_id),
    CONSTRAINT uk_stock_movement_unit UNIQUE (movement_id, unit_id),
    INDEX idx_stock_movement_unit_unit (unit_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_inspection (
    inspection_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    unit_id BIGINT NOT NULL,
    template_id BIGINT NULL,
    inspected_by BIGINT NOT NULL,
    inspection_type ENUM('INITIAL', 'CORRECTION', 'REINSPECTION') NOT NULL DEFAULT 'INITIAL',
    original_inspection_id BIGINT NULL,
    sales_status ENUM('HOLD', 'AVAILABLE', 'UNAVAILABLE') NOT NULL,
    result ENUM('PASS', 'FAIL') NOT NULL,
    grade ENUM('A', 'B', 'C', 'DEFECTIVE') NOT NULL,
    memo VARCHAR(1000) NULL,
    inspected_at DATETIME(6) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (inspection_id),
    CONSTRAINT uk_inspection_company_inspection_id UNIQUE (company_id, inspection_id),
    INDEX idx_inspection_company_unit_date (company_id, unit_id, inspected_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_part_spec_value (
    spec_value_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    part_id BIGINT NOT NULL,
    spec_definition_id BIGINT NOT NULL,
    value_text VARCHAR(1000) NULL,
    value_number DECIMAL(15, 4) NULL,
    value_boolean BOOLEAN NULL,
    selected_option_id BIGINT NULL,
    selected_option_label_snapshot VARCHAR(100) NULL,
    selected_option_value_snapshot VARCHAR(100) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (spec_value_id),
    CONSTRAINT uk_part_spec_value_part_definition UNIQUE (part_id, spec_definition_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO tb_company (company_id, company_name, company_code, active)
VALUES
    (1, 'ACME Parts', 'acme', TRUE),
    (2, 'Other Parts', 'other', TRUE),
    (3, 'Inactive Parts', 'inactive', FALSE);

INSERT INTO tb_member (member_id, company_id, login_id, password_hash, name, role, owner_slot, active)
VALUES
    (7, 1, 'admin', '{noop}password', 'Admin', 'OWNER', 1, TRUE),
    (8, 2, 'other-admin', '{noop}password', 'Other Admin', 'OWNER', 1, TRUE);

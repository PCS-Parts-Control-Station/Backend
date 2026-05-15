CREATE DATABASE IF NOT EXISTS pcs_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE pcs_db;

-- FK columns are logical references only.
-- This schema intentionally does not create physical FOREIGN KEY constraints.
-- Relationship integrity must be validated in the Service layer and harness tests.

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS tb_inspection_item_result;
DROP TABLE IF EXISTS tb_inspection_template_item_option;
DROP TABLE IF EXISTS tb_part_status_history;
DROP TABLE IF EXISTS tb_inspection;
DROP TABLE IF EXISTS tb_inspection_template_item;
DROP TABLE IF EXISTS tb_inspection_template;
DROP TABLE IF EXISTS tb_stock_movement_unit;
DROP TABLE IF EXISTS tb_stock_movement;
DROP TABLE IF EXISTS tb_stock_document;
DROP TABLE IF EXISTS tb_part_stock;
DROP TABLE IF EXISTS tb_pc_part_unit;
DROP TABLE IF EXISTS tb_pc_part;
DROP TABLE IF EXISTS tb_part_category;
DROP TABLE IF EXISTS tb_trade_partner;
DROP TABLE IF EXISTS tb_member;
DROP TABLE IF EXISTS tb_company;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE tb_company (
    company_id BIGINT NOT NULL AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    company_code VARCHAR(50) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (company_id),
    CONSTRAINT uk_company_code UNIQUE (company_code),
    INDEX idx_company_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_member (
    member_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    login_id VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role ENUM('OWNER', 'ADMIN', 'STAFF') NOT NULL,
    owner_slot TINYINT NULL,
    password_status ENUM('TEMPORARY', 'ACTIVE') NOT NULL DEFAULT 'TEMPORARY',
    temp_password_expires_at DATETIME(6) NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at DATETIME(6) NULL,
    created_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (member_id),
    CONSTRAINT uk_member_company_login UNIQUE (company_id, login_id),
    CONSTRAINT uk_member_company_owner UNIQUE (company_id, owner_slot),
    CONSTRAINT uk_member_company_member_id UNIQUE (company_id, member_id),
    CONSTRAINT chk_member_owner_slot CHECK (
        (role = 'OWNER' AND owner_slot = 1)
        OR (role <> 'OWNER' AND owner_slot IS NULL)
    ),
    INDEX idx_member_company_created_by (company_id, created_by),
    INDEX idx_member_company_role (company_id, role),
    INDEX idx_member_company_active (company_id, active)
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
    PRIMARY KEY (partner_id),
    CONSTRAINT uk_trade_partner_company_name UNIQUE (company_id, partner_name),
    CONSTRAINT uk_trade_partner_company_partner_id UNIQUE (company_id, partner_id),
    INDEX idx_trade_partner_company_role (company_id, partner_role, active),
    INDEX idx_trade_partner_company_type (company_id, partner_type, active),
    INDEX idx_trade_partner_company_created_by (company_id, created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_part_category (
    category_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (category_id),
    CONSTRAINT uk_part_category_company_name UNIQUE (company_id, category_name),
    CONSTRAINT uk_part_category_company_category_id UNIQUE (company_id, category_id),
    INDEX idx_part_category_company_created_by (company_id, created_by),
    INDEX idx_part_category_company_active (company_id, active)
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
    estimated_price DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    safe_quantity INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (part_id),
    CONSTRAINT uk_pc_part_company_code UNIQUE (company_id, part_code),
    CONSTRAINT uk_pc_part_company_part_id UNIQUE (company_id, part_id),
    CONSTRAINT chk_pc_part_price CHECK (estimated_price >= 0),
    CONSTRAINT chk_pc_part_safe_quantity CHECK (safe_quantity >= 0),
    INDEX idx_pc_part_company_category (company_id, category_id),
    INDEX idx_pc_part_company_created_by (company_id, created_by),
    INDEX idx_pc_part_company_manufacturer (company_id, manufacturer),
    INDEX idx_pc_part_company_active (company_id, active)
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
    INDEX idx_pc_part_unit_company_created_by (company_id, created_by),
    INDEX idx_pc_part_unit_company_status (company_id, unit_status, active),
    INDEX idx_pc_part_unit_work_status (company_id, inspection_status, sales_status, grade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_part_stock (
    stock_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    part_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (stock_id),
    CONSTRAINT uk_part_stock_company_part UNIQUE (company_id, part_id),
    CONSTRAINT chk_part_stock_quantity CHECK (quantity >= 0),
    INDEX idx_part_stock_company_quantity (company_id, quantity)
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
    CONSTRAINT uk_stock_document_company_document_no UNIQUE (company_id, document_no),
    CONSTRAINT uk_stock_document_company_document_id UNIQUE (company_id, document_id),
    INDEX idx_stock_document_company_partner (company_id, partner_id),
    INDEX idx_stock_document_company_processed_by (company_id, processed_by),
    INDEX idx_stock_document_type_status_created (company_id, document_type, document_status, created_at)
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
    CONSTRAINT chk_stock_movement_quantity CHECK (quantity > 0),
    CONSTRAINT chk_stock_movement_before_after CHECK (
        before_quantity >= 0
        AND after_quantity >= 0
        AND (
            (movement_type IN ('INBOUND', 'OUTBOUND_CANCEL') AND after_quantity = before_quantity + quantity)
            OR (movement_type IN ('OUTBOUND', 'INBOUND_CANCEL') AND after_quantity = before_quantity - quantity)
        )
    ),
    INDEX idx_stock_movement_company_document (company_id, document_id),
    INDEX idx_stock_movement_company_part (company_id, part_id),
    INDEX idx_stock_movement_company_canceled (company_id, canceled_movement_id),
    INDEX idx_stock_movement_company_processed_by (company_id, processed_by),
    INDEX idx_stock_movement_type_status_created (company_id, movement_type, movement_status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_stock_movement_unit (
    movement_unit_id BIGINT NOT NULL AUTO_INCREMENT,
    movement_id BIGINT NOT NULL,
    unit_id BIGINT NOT NULL,
    before_unit_status ENUM('IN_STOCK', 'OUTBOUND', 'DISPOSED', 'CANCELED') NULL,
    after_unit_status ENUM('IN_STOCK', 'OUTBOUND', 'DISPOSED', 'CANCELED') NOT NULL,
    PRIMARY KEY (movement_unit_id),
    CONSTRAINT uk_stock_movement_unit UNIQUE (movement_id, unit_id),
    INDEX idx_stock_movement_unit_movement (movement_id),
    INDEX idx_stock_movement_unit_unit (unit_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_inspection_template (
    template_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    template_name VARCHAR(150) NOT NULL,
    version INT NOT NULL DEFAULT 1,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (template_id),
    CONSTRAINT uk_inspection_template_company_template_id UNIQUE (company_id, template_id),
    CONSTRAINT uk_inspection_template_version UNIQUE (company_id, category_id, template_name, version),
    CONSTRAINT chk_inspection_template_version CHECK (version > 0),
    INDEX idx_inspection_template_company_created_by (company_id, created_by),
    INDEX idx_inspection_template_company_category (company_id, category_id, active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_inspection_template_item (
    item_id BIGINT NOT NULL AUTO_INCREMENT,
    template_id BIGINT NOT NULL,
    item_group ENUM('BASIC', 'DETAIL') NOT NULL,
    item_name VARCHAR(150) NOT NULL,
    input_type ENUM('CHECK', 'NUMBER', 'TEXT', 'SELECT') NOT NULL,
    required BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INT NOT NULL DEFAULT 0,
    grade_impact ENUM('HIGH', 'MEDIUM', 'LOW') NOT NULL DEFAULT 'LOW',
    fail_policy ENUM('NONE', 'GRADE_DOWN', 'MARK_DEFECTIVE', 'BLOCK_SALE') NOT NULL DEFAULT 'NONE',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (item_id),
    CONSTRAINT uk_inspection_template_item_id UNIQUE (template_id, item_id),
    CONSTRAINT chk_inspection_template_item_sort_order CHECK (sort_order >= 0),
    INDEX idx_inspection_template_item_template_sort (template_id, active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_inspection_template_item_option (
    option_id BIGINT NOT NULL AUTO_INCREMENT,
    item_id BIGINT NOT NULL,
    option_label VARCHAR(150) NOT NULL,
    option_value VARCHAR(150) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (option_id),
    CONSTRAINT uk_inspection_template_item_option_value UNIQUE (item_id, option_value),
    CONSTRAINT chk_inspection_template_item_option_sort_order CHECK (sort_order >= 0),
    INDEX idx_inspection_template_item_option_item_sort (item_id, active, sort_order)
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
    CONSTRAINT chk_inspection_original CHECK (
        (inspection_type = 'INITIAL' AND original_inspection_id IS NULL)
        OR (inspection_type IN ('CORRECTION', 'REINSPECTION') AND original_inspection_id IS NOT NULL)
    ),
    INDEX idx_inspection_company_unit_date (company_id, unit_id, inspected_at),
    INDEX idx_inspection_company_template (company_id, template_id),
    INDEX idx_inspection_company_inspected_by (company_id, inspected_by),
    INDEX idx_inspection_company_original (company_id, original_inspection_id),
    INDEX idx_inspection_type_date (company_id, inspection_type, inspected_at),
    INDEX idx_inspection_result_date (company_id, result, inspected_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_part_status_history (
    history_id BIGINT NOT NULL AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    unit_id BIGINT NOT NULL,
    changed_by BIGINT NOT NULL,
    from_inspection_status ENUM('WAITING', 'COMPLETED') NULL,
    to_inspection_status ENUM('WAITING', 'COMPLETED') NULL,
    from_grade ENUM('NONE', 'A', 'B', 'C', 'DEFECTIVE') NULL,
    to_grade ENUM('NONE', 'A', 'B', 'C', 'DEFECTIVE') NULL,
    from_sales_status ENUM('HOLD', 'AVAILABLE', 'UNAVAILABLE') NULL,
    to_sales_status ENUM('HOLD', 'AVAILABLE', 'UNAVAILABLE') NULL,
    reason VARCHAR(500) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (history_id),
    INDEX idx_part_status_history_company_unit_date (company_id, unit_id, created_at),
    INDEX idx_part_status_history_company_changed_by (company_id, changed_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_inspection_item_result (
    item_result_id BIGINT NOT NULL AUTO_INCREMENT,
    inspection_id BIGINT NOT NULL,
    item_id BIGINT NULL,
    item_name_snapshot VARCHAR(150) NOT NULL,
    result ENUM('PASS', 'FAIL', 'WARN', 'NA') NOT NULL,
    value_text VARCHAR(1000) NULL,
    value_number DECIMAL(15, 4) NULL,
    selected_option_id BIGINT NULL,
    selected_option_label_snapshot VARCHAR(150) NULL,
    selected_option_value_snapshot VARCHAR(150) NULL,
    memo VARCHAR(1000) NULL,
    PRIMARY KEY (item_result_id),
    INDEX idx_inspection_item_result_inspection (inspection_id),
    INDEX idx_inspection_item_result_item (item_id),
    INDEX idx_inspection_item_result_selected_option (selected_option_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

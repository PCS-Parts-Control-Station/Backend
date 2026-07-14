DROP TABLE IF EXISTS tb_inspection_item_result;
DROP TABLE IF EXISTS tb_inspection_template_item_option;
DROP TABLE IF EXISTS tb_inspection_template_item;
DROP TABLE IF EXISTS tb_inspection_template;
DROP TABLE IF EXISTS tb_part_status_history;
DROP TABLE IF EXISTS tb_trade_partner;

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
    last_transaction_at DATETIME(6) NULL,
    created_by BIGINT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (partner_id),
    CONSTRAINT uk_trade_partner_company_name UNIQUE (company_id, partner_name),
    CONSTRAINT uk_trade_partner_company_partner_id UNIQUE (company_id, partner_id)
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
    CONSTRAINT chk_inspection_template_version CHECK (version > 0)
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
    CONSTRAINT uk_inspection_template_item_name UNIQUE (template_id, item_name),
    CONSTRAINT chk_inspection_template_item_sort_order CHECK (sort_order >= 0)
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
    CONSTRAINT uk_inspection_template_item_option_label UNIQUE (item_id, option_label),
    CONSTRAINT chk_inspection_template_item_option_sort_order CHECK (sort_order >= 0)
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
    PRIMARY KEY (item_result_id)
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
    PRIMARY KEY (history_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO tb_trade_partner (
    partner_id, company_id, partner_name, partner_type, partner_role, active, created_by
) VALUES
    (101, 1, 'ACME Supplier', 'COMPANY', 'SUPPLIER', TRUE, 7),
    (102, 1, 'ACME Customer', 'COMPANY', 'CUSTOMER', TRUE, 7),
    (201, 2, 'Other Supplier', 'COMPANY', 'SUPPLIER', TRUE, 8);

DROP TABLE IF EXISTS tb_part_spec_value;
DROP TABLE IF EXISTS tb_part_stock;
DROP TABLE IF EXISTS tb_pc_part;
DROP TABLE IF EXISTS tb_part_spec_option;
DROP TABLE IF EXISTS tb_part_spec_definition;
DROP TABLE IF EXISTS tb_part_category;
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

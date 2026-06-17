USE pcs_db;

CREATE TABLE IF NOT EXISTS tb_company_staff_permission_disabled (
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
    disabled_by BIGINT NOT NULL,
    disabled_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (disabled_permission_id),
    CONSTRAINT uk_company_staff_permission_disabled UNIQUE (company_id, permission_code),
    INDEX idx_company_staff_permission_disabled_company (company_id),
    INDEX idx_company_staff_permission_disabled_by (company_id, disabled_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

USE pcs_db;

ALTER TABLE tb_company
    ADD COLUMN IF NOT EXISTS representative_email VARCHAR(255) NULL AFTER company_code,
    ADD COLUMN IF NOT EXISTS representative_phone VARCHAR(30) NULL AFTER representative_email,
    ADD COLUMN IF NOT EXISTS business_registration_no VARCHAR(20) NULL AFTER representative_phone;

CREATE UNIQUE INDEX IF NOT EXISTS uk_company_business_registration_no
    ON tb_company (business_registration_no);

ALTER TABLE tb_member
    ADD COLUMN IF NOT EXISTS owner_slot TINYINT NULL AFTER role;

UPDATE tb_member
SET owner_slot = 1
WHERE role = 'OWNER'
  AND owner_slot IS NULL;

UPDATE tb_member
SET owner_slot = NULL
WHERE role <> 'OWNER'
  AND owner_slot IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uk_member_company_owner
    ON tb_member (company_id, owner_slot);

SET @chk_member_owner_slot_exists = (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'tb_member'
      AND CONSTRAINT_NAME = 'chk_member_owner_slot'
);

SET @drop_chk_member_owner_slot_sql = IF(
    @chk_member_owner_slot_exists > 0,
    'ALTER TABLE tb_member DROP CONSTRAINT chk_member_owner_slot',
    'SELECT 1'
);

PREPARE drop_chk_member_owner_slot_stmt FROM @drop_chk_member_owner_slot_sql;
EXECUTE drop_chk_member_owner_slot_stmt;
DEALLOCATE PREPARE drop_chk_member_owner_slot_stmt;

ALTER TABLE tb_member
    ADD CONSTRAINT chk_member_owner_slot
    CHECK (
        (role = 'OWNER' AND owner_slot IS NOT NULL AND owner_slot = 1)
        OR (role <> 'OWNER' AND owner_slot IS NULL)
    );

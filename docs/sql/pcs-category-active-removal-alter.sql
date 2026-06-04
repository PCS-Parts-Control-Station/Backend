-- Category active removal migration.
-- Run this after backing up local data if the database already has tb_part_category.

ALTER TABLE tb_part_category
    DROP INDEX idx_part_category_company_active;

ALTER TABLE tb_part_category
    DROP COLUMN active;

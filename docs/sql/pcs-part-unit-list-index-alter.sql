USE pcs_db;

-- Do not run this file again when the indexes already exist in the target DB.
ALTER TABLE tb_pc_part_unit
    ADD INDEX idx_pc_part_unit_list_default (company_id, active, updated_at DESC, unit_id DESC),
    ADD INDEX idx_pc_part_unit_list_inspection (company_id, active, inspection_status, updated_at DESC, unit_id DESC),
    ADD INDEX idx_pc_part_unit_list_unit_status (company_id, active, unit_status, updated_at DESC, unit_id DESC);

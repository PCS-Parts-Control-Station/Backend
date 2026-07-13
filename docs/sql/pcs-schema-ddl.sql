-- PCS schema DDL.
-- Regenerated from C:\Users\harry\Downloads\sql.sql on 2026-07-12.
-- Data rows, REPLACE statements, and generation procedures are intentionally excluded.
-- Do not run this directly against a production database without review.

CREATE DATABASE IF NOT EXISTS `pcs_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `pcs_db`;

DROP TABLE IF EXISTS `tb_trade_partner`;
DROP TABLE IF EXISTS `tb_stock_movement_unit`;
DROP TABLE IF EXISTS `tb_stock_movement`;
DROP TABLE IF EXISTS `tb_stock_document`;
DROP TABLE IF EXISTS `tb_pc_part_unit`;
DROP TABLE IF EXISTS `tb_pc_part`;
DROP TABLE IF EXISTS `tb_part_stock`;
DROP TABLE IF EXISTS `tb_part_status_history`;
DROP TABLE IF EXISTS `tb_part_spec_value`;
DROP TABLE IF EXISTS `tb_part_spec_option`;
DROP TABLE IF EXISTS `tb_part_spec_definition`;
DROP TABLE IF EXISTS `tb_part_category`;
DROP TABLE IF EXISTS `tb_member`;
DROP TABLE IF EXISTS `tb_inspection_template_item_option`;
DROP TABLE IF EXISTS `tb_inspection_template_item`;
DROP TABLE IF EXISTS `tb_inspection_template`;
DROP TABLE IF EXISTS `tb_inspection_item_result`;
DROP TABLE IF EXISTS `tb_inspection`;
DROP TABLE IF EXISTS `tb_company_staff_permission_disabled`;
DROP TABLE IF EXISTS `tb_company`;
DROP TABLE IF EXISTS `tb_auth_refresh_token`;
DROP TABLE IF EXISTS `tb_auth_login_history`;

-- pcs_db.tb_auth_login_history definition
CREATE TABLE IF NOT EXISTS `tb_auth_login_history` (
  `history_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) DEFAULT NULL,
  `member_id` bigint(20) DEFAULT NULL,
  `company_code_snapshot` varchar(50) DEFAULT NULL,
  `login_id_snapshot` varchar(50) NOT NULL,
  `login_result` enum('SUCCESS','FAIL','LOCKED','INACTIVE','TEMP_PASSWORD_EXPIRED') NOT NULL,
  `failure_reason` varchar(100) DEFAULT NULL,
  `login_ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`history_id`),
  KEY `idx_auth_login_history_company_date` (`company_id`,`created_at`),
  KEY `idx_auth_login_history_member_date` (`company_id`,`member_id`,`created_at`),
  KEY `idx_auth_login_history_login_id_date` (`login_id_snapshot`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_auth_refresh_token definition
CREATE TABLE IF NOT EXISTS `tb_auth_refresh_token` (
  `token_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `member_id` bigint(20) NOT NULL,
  `refresh_token_hash` char(64) NOT NULL COMMENT 'refresh token SHA-256 해시',
  `token_family_id` varchar(36) NOT NULL COMMENT '토큰 회전 추적용 UUID',
  `expires_at` datetime(6) NOT NULL,
  `last_used_at` datetime(6) DEFAULT NULL,
  `revoked_at` datetime(6) DEFAULT NULL,
  `revoked_reason` enum('LOGOUT','ROTATED','EXPIRED','REUSE_DETECTED','ADMIN_REVOKED') DEFAULT NULL,
  `replaced_by_token_id` bigint(20) DEFAULT NULL,
  `created_ip` varchar(45) DEFAULT NULL,
  `created_user_agent` varchar(500) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`token_id`),
  UNIQUE KEY `uk_auth_refresh_token_hash` (`refresh_token_hash`),
  KEY `idx_auth_refresh_member_active` (`company_id`,`member_id`,`revoked_at`,`expires_at`),
  KEY `idx_auth_refresh_family` (`company_id`,`member_id`,`token_family_id`),
  KEY `idx_auth_refresh_replaced_by` (`replaced_by_token_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_company definition
CREATE TABLE IF NOT EXISTS `tb_company` (
  `company_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_name` varchar(100) NOT NULL,
  `company_code` varchar(50) NOT NULL,
  `representative_email` varchar(255) DEFAULT NULL COMMENT '대표 이메일',
  `representative_phone` varchar(30) DEFAULT NULL COMMENT '대표 연락처',
  `business_registration_no` varchar(20) DEFAULT NULL COMMENT '사업자등록번호',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`company_id`),
  UNIQUE KEY `uk_company_code` (`company_code`),
  UNIQUE KEY `uk_company_business_registration_no` (`business_registration_no`),
  KEY `idx_company_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_company_staff_permission_disabled definition
CREATE TABLE IF NOT EXISTS `tb_company_staff_permission_disabled` (
  `disabled_permission_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `permission_code` enum('STAFF_PARTNER_MANAGE','STAFF_PART_CREATE','STAFF_CATEGORY_MANAGE','STAFF_INBOUND','STAFF_INSPECTION','STAFF_OUTBOUND') NOT NULL,
  `disabled_by` bigint(20) NOT NULL,
  `disabled_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`disabled_permission_id`),
  UNIQUE KEY `uk_company_staff_permission_disabled` (`company_id`,`permission_code`),
  KEY `idx_company_staff_permission_disabled_company` (`company_id`),
  KEY `idx_company_staff_permission_disabled_by` (`company_id`,`disabled_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_inspection definition
CREATE TABLE IF NOT EXISTS `tb_inspection` (
  `inspection_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `unit_id` bigint(20) NOT NULL,
  `template_id` bigint(20) DEFAULT NULL,
  `inspected_by` bigint(20) NOT NULL,
  `inspection_type` enum('INITIAL','CORRECTION','REINSPECTION') NOT NULL DEFAULT 'INITIAL',
  `original_inspection_id` bigint(20) DEFAULT NULL,
  `sales_status` enum('HOLD','AVAILABLE','UNAVAILABLE') NOT NULL,
  `result` enum('PASS','FAIL') NOT NULL,
  `grade` enum('A','B','C','DEFECTIVE') NOT NULL,
  `memo` varchar(1000) DEFAULT NULL,
  `inspected_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`inspection_id`),
  UNIQUE KEY `uk_inspection_company_inspection_id` (`company_id`,`inspection_id`),
  KEY `idx_inspection_company_unit_date` (`company_id`,`unit_id`,`inspected_at` DESC,`inspection_id` DESC),
  KEY `idx_inspection_company_date` (`company_id`,`inspected_at` DESC,`inspection_id` DESC),
  KEY `idx_inspection_company_template` (`company_id`,`template_id`),
  KEY `idx_inspection_company_inspected_by` (`company_id`,`inspected_by`),
  KEY `idx_inspection_company_original` (`company_id`,`original_inspection_id`),
  KEY `idx_inspection_type_date` (`company_id`,`inspection_type`,`inspected_at`),
  KEY `idx_inspection_result_date` (`company_id`,`result`,`inspected_at`),
  CONSTRAINT `chk_inspection_original` CHECK (`inspection_type` = 'INITIAL' and `original_inspection_id` is null or `inspection_type` in ('CORRECTION','REINSPECTION') and `original_inspection_id` is not null)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_inspection_item_result definition
CREATE TABLE IF NOT EXISTS `tb_inspection_item_result` (
  `item_result_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `inspection_id` bigint(20) NOT NULL,
  `item_id` bigint(20) DEFAULT NULL,
  `item_name_snapshot` varchar(150) NOT NULL,
  `result` enum('PASS','FAIL','WARN','NA') NOT NULL,
  `value_text` varchar(1000) DEFAULT NULL,
  `value_number` decimal(15,4) DEFAULT NULL,
  `selected_option_id` bigint(20) DEFAULT NULL,
  `selected_option_label_snapshot` varchar(150) DEFAULT NULL,
  `selected_option_value_snapshot` varchar(150) DEFAULT NULL,
  `memo` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`item_result_id`),
  KEY `idx_inspection_item_result_inspection` (`inspection_id`),
  KEY `idx_inspection_item_result_item` (`item_id`),
  KEY `idx_inspection_item_result_selected_option` (`selected_option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_inspection_template definition
CREATE TABLE IF NOT EXISTS `tb_inspection_template` (
  `template_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `template_name` varchar(150) NOT NULL,
  `version` int(11) NOT NULL DEFAULT 1,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint(20) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`template_id`),
  UNIQUE KEY `uk_inspection_template_company_template_id` (`company_id`,`template_id`),
  UNIQUE KEY `uk_inspection_template_version` (`company_id`,`category_id`,`template_name`,`version`),
  KEY `idx_inspection_template_company_created_by` (`company_id`,`created_by`),
  KEY `idx_inspection_template_company_category` (`company_id`,`category_id`,`active`),
  KEY `idx_inspection_template_company_list` (`company_id`,`updated_at` DESC,`template_id` DESC),
  CONSTRAINT `chk_inspection_template_version` CHECK (`version` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_inspection_template_item definition
CREATE TABLE IF NOT EXISTS `tb_inspection_template_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `template_id` bigint(20) NOT NULL,
  `item_group` enum('BASIC','DETAIL') NOT NULL,
  `item_name` varchar(150) NOT NULL,
  `input_type` enum('CHECK','NUMBER','TEXT','SELECT') NOT NULL,
  `required` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `grade_impact` enum('HIGH','MEDIUM','LOW') NOT NULL DEFAULT 'LOW',
  `fail_policy` enum('NONE','GRADE_DOWN','MARK_DEFECTIVE','BLOCK_SALE') NOT NULL DEFAULT 'NONE',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `uk_inspection_template_item_id` (`template_id`,`item_id`),
  KEY `idx_inspection_template_item_template_sort` (`template_id`,`active`,`sort_order`),
  CONSTRAINT `chk_inspection_template_item_sort_order` CHECK (`sort_order` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_inspection_template_item_option definition
CREATE TABLE IF NOT EXISTS `tb_inspection_template_item_option` (
  `option_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `item_id` bigint(20) NOT NULL,
  `option_label` varchar(150) NOT NULL,
  `option_value` varchar(150) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `uk_inspection_template_item_option_value` (`item_id`,`option_value`),
  KEY `idx_inspection_template_item_option_item_sort` (`item_id`,`active`,`sort_order`),
  CONSTRAINT `chk_inspection_template_item_option_sort_order` CHECK (`sort_order` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_member definition
CREATE TABLE IF NOT EXISTS `tb_member` (
  `member_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `login_id` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `name` varchar(100) NOT NULL,
  `role` enum('OWNER','ADMIN','STAFF') NOT NULL,
  `owner_slot` tinyint(4) DEFAULT NULL,
  `password_status` enum('TEMPORARY','ACTIVE') NOT NULL DEFAULT 'TEMPORARY',
  `temp_password_expires_at` datetime(6) DEFAULT NULL,
  `password_changed_at` datetime(6) DEFAULT NULL COMMENT '비밀번호 마지막 변경일',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` datetime(6) DEFAULT NULL,
  `login_failed_count` int(11) NOT NULL DEFAULT 0 COMMENT '로그인 실패 횟수',
  `locked_until_at` datetime(6) DEFAULT NULL COMMENT '로그인 잠금 해제 시각',
  `last_login_ip` varchar(45) DEFAULT NULL COMMENT '최근 로그인 IP',
  `last_login_user_agent` varchar(500) DEFAULT NULL COMMENT '최근 로그인 User-Agent',
  `created_by` bigint(20) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `uk_member_company_login` (`company_id`,`login_id`),
  UNIQUE KEY `uk_member_company_member_id` (`company_id`,`member_id`),
  UNIQUE KEY `uk_member_company_owner` (`company_id`,`owner_slot`),
  KEY `idx_member_company_created_by` (`company_id`,`created_by`),
  KEY `idx_member_company_role` (`company_id`,`role`),
  KEY `idx_member_company_active` (`company_id`,`active`),
  KEY `idx_member_company_list` (`company_id`,`updated_at` DESC,`member_id` DESC),
  KEY `idx_member_company_created` (`company_id`,`created_at`,`member_id`),
  CONSTRAINT `chk_member_owner_slot` CHECK (`role` = 'OWNER' and `owner_slot` is not null and `owner_slot` = 1 or `role` <> 'OWNER' and `owner_slot` is null)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_part_category definition
CREATE TABLE IF NOT EXISTS `tb_part_category` (
  `category_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uk_part_category_company_name` (`company_id`,`category_name`),
  UNIQUE KEY `uk_part_category_company_category_id` (`company_id`,`category_id`),
  KEY `idx_part_category_company_created_by` (`company_id`,`created_by`),
  KEY `idx_part_category_company_list` (`company_id`,`updated_at` DESC,`category_id` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_part_spec_definition definition
CREATE TABLE IF NOT EXISTS `tb_part_spec_definition` (
  `spec_definition_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `spec_key` varchar(80) NOT NULL,
  `spec_name` varchar(100) NOT NULL,
  `input_type` enum('TEXT','NUMBER','SELECT','BOOLEAN') NOT NULL,
  `unit` varchar(30) DEFAULT NULL,
  `required` tinyint(1) NOT NULL DEFAULT 0,
  `searchable` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint(20) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`spec_definition_id`),
  UNIQUE KEY `uk_part_spec_definition_company_spec_id` (`company_id`,`spec_definition_id`),
  UNIQUE KEY `uk_part_spec_definition_company_category_key` (`company_id`,`category_id`,`spec_key`),
  KEY `idx_part_spec_definition_category_sort` (`company_id`,`category_id`,`active`,`sort_order`),
  KEY `idx_part_spec_definition_created_by` (`company_id`,`created_by`),
  CONSTRAINT `chk_part_spec_definition_sort_order` CHECK (`sort_order` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_part_spec_option definition
CREATE TABLE IF NOT EXISTS `tb_part_spec_option` (
  `option_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `spec_definition_id` bigint(20) NOT NULL,
  `option_label` varchar(100) NOT NULL,
  `option_value` varchar(100) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `uk_part_spec_option_definition_value` (`spec_definition_id`,`option_value`),
  KEY `idx_part_spec_option_definition_sort` (`spec_definition_id`,`active`,`sort_order`),
  CONSTRAINT `chk_part_spec_option_sort_order` CHECK (`sort_order` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_part_spec_value definition
CREATE TABLE IF NOT EXISTS `tb_part_spec_value` (
  `spec_value_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `part_id` bigint(20) NOT NULL,
  `spec_definition_id` bigint(20) NOT NULL,
  `value_text` varchar(1000) DEFAULT NULL,
  `value_number` decimal(15,4) DEFAULT NULL,
  `value_boolean` tinyint(1) DEFAULT NULL,
  `selected_option_id` bigint(20) DEFAULT NULL,
  `selected_option_label_snapshot` varchar(100) DEFAULT NULL,
  `selected_option_value_snapshot` varchar(100) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`spec_value_id`),
  UNIQUE KEY `uk_part_spec_value_part_definition` (`part_id`,`spec_definition_id`),
  KEY `idx_part_spec_value_company_part` (`company_id`,`part_id`),
  KEY `idx_part_spec_value_definition` (`spec_definition_id`),
  KEY `idx_part_spec_value_number` (`company_id`,`spec_definition_id`,`value_number`),
  KEY `idx_part_spec_value_text` (`company_id`,`spec_definition_id`,`value_text`(100)),
  KEY `idx_part_spec_value_option` (`selected_option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_part_status_history definition
CREATE TABLE IF NOT EXISTS `tb_part_status_history` (
  `history_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `unit_id` bigint(20) NOT NULL,
  `changed_by` bigint(20) NOT NULL,
  `from_inspection_status` enum('WAITING','COMPLETED') DEFAULT NULL,
  `to_inspection_status` enum('WAITING','COMPLETED') DEFAULT NULL,
  `from_grade` enum('NONE','A','B','C','DEFECTIVE') DEFAULT NULL,
  `to_grade` enum('NONE','A','B','C','DEFECTIVE') DEFAULT NULL,
  `from_sales_status` enum('HOLD','AVAILABLE','UNAVAILABLE') DEFAULT NULL,
  `to_sales_status` enum('HOLD','AVAILABLE','UNAVAILABLE') DEFAULT NULL,
  `reason` varchar(500) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`history_id`),
  KEY `idx_part_status_history_company_unit_date` (`company_id`,`unit_id`,`created_at`),
  KEY `idx_part_status_history_company_changed_by` (`company_id`,`changed_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_part_stock definition
CREATE TABLE IF NOT EXISTS `tb_part_stock` (
  `stock_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `part_id` bigint(20) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`stock_id`),
  UNIQUE KEY `uk_part_stock_company_part` (`company_id`,`part_id`),
  KEY `idx_part_stock_company_quantity` (`company_id`,`quantity`),
  CONSTRAINT `chk_part_stock_quantity` CHECK (`quantity` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_pc_part definition
CREATE TABLE IF NOT EXISTS `tb_pc_part` (
  `part_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `part_name` varchar(150) NOT NULL,
  `model_name` varchar(150) NOT NULL,
  `manufacturer` varchar(100) NOT NULL,
  `part_code` varchar(80) NOT NULL,
  `safe_quantity` int(11) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`part_id`),
  UNIQUE KEY `uk_pc_part_company_code` (`company_id`,`part_code`),
  UNIQUE KEY `uk_pc_part_company_part_id` (`company_id`,`part_id`),
  KEY `idx_pc_part_company_category` (`company_id`,`category_id`),
  KEY `idx_pc_part_company_created_by` (`company_id`,`created_by`),
  KEY `idx_pc_part_company_manufacturer` (`company_id`,`manufacturer`),
  KEY `idx_pc_part_company_active` (`company_id`,`active`),
  CONSTRAINT `chk_pc_part_safe_quantity` CHECK (`safe_quantity` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_pc_part_unit definition
CREATE TABLE IF NOT EXISTS `tb_pc_part_unit` (
  `unit_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `part_id` bigint(20) NOT NULL,
  `internal_serial_no` varchar(80) NOT NULL,
  `manufacturer_serial_no` varchar(120) DEFAULT NULL,
  `unit_status` enum('IN_STOCK','OUTBOUND','DISPOSED','CANCELED') NOT NULL DEFAULT 'IN_STOCK',
  `grade` enum('NONE','A','B','C','DEFECTIVE') NOT NULL DEFAULT 'NONE',
  `inspection_status` enum('WAITING','COMPLETED') NOT NULL DEFAULT 'WAITING',
  `sales_status` enum('HOLD','AVAILABLE','UNAVAILABLE') NOT NULL DEFAULT 'HOLD',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint(20) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`unit_id`),
  UNIQUE KEY `uk_pc_part_unit_internal_serial` (`company_id`,`internal_serial_no`),
  UNIQUE KEY `uk_pc_part_unit_company_unit_id` (`company_id`,`unit_id`),
  UNIQUE KEY `uk_pc_part_unit_company_part_unit_id` (`company_id`,`part_id`,`unit_id`),
  UNIQUE KEY `uk_pc_part_unit_manufacturer_serial` (`company_id`,`manufacturer_serial_no`),
  KEY `idx_pc_part_unit_company_part` (`company_id`,`part_id`),
  KEY `idx_pc_part_unit_company_created_by` (`company_id`,`created_by`),
  KEY `idx_pc_part_unit_company_status` (`company_id`,`unit_status`,`active`),
  KEY `idx_pc_part_unit_work_status` (`company_id`,`inspection_status`,`sales_status`,`grade`),
  KEY `idx_pc_part_unit_list_default` (`company_id`,`active`,`updated_at` DESC,`unit_id` DESC),
  KEY `idx_pc_part_unit_list_inspection` (`company_id`,`active`,`inspection_status`,`updated_at` DESC,`unit_id` DESC),
  KEY `idx_pc_part_unit_list_unit_status` (`company_id`,`active`,`unit_status`,`updated_at` DESC,`unit_id` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_stock_document definition
CREATE TABLE IF NOT EXISTS `tb_stock_document` (
  `document_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `partner_id` bigint(20) DEFAULT NULL,
  `document_no` varchar(80) NOT NULL,
  `document_type` enum('INBOUND','OUTBOUND') NOT NULL,
  `document_status` enum('COMPLETED','CANCELED') NOT NULL DEFAULT 'COMPLETED',
  `reason` varchar(500) DEFAULT NULL,
  `processed_by` bigint(20) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`document_id`),
  UNIQUE KEY `uk_stock_document_company_document_no` (`company_id`,`document_no`),
  UNIQUE KEY `uk_stock_document_company_document_id` (`company_id`,`document_id`),
  UNIQUE KEY `uk_stock_document_document_no` (`document_no`),
  KEY `idx_stock_document_company_partner` (`company_id`,`partner_id`),
  KEY `idx_stock_document_company_processed_by` (`company_id`,`processed_by`),
  KEY `idx_stock_document_type_status_created` (`company_id`,`document_type`,`document_status`,`created_at`),
  KEY `idx_stock_document_company_created` (`company_id`,`created_at`,`document_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_stock_movement definition
CREATE TABLE IF NOT EXISTS `tb_stock_movement` (
  `movement_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `document_id` bigint(20) NOT NULL,
  `part_id` bigint(20) NOT NULL,
  `movement_type` enum('INBOUND','OUTBOUND','INBOUND_CANCEL','OUTBOUND_CANCEL') NOT NULL,
  `movement_status` enum('COMPLETED','CANCELED') NOT NULL DEFAULT 'COMPLETED',
  `canceled_movement_id` bigint(20) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `before_quantity` int(11) NOT NULL,
  `after_quantity` int(11) NOT NULL,
  `reason` varchar(500) DEFAULT NULL,
  `processed_by` bigint(20) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`movement_id`),
  UNIQUE KEY `uk_stock_movement_company_movement_id` (`company_id`,`movement_id`),
  KEY `idx_stock_movement_company_document` (`company_id`,`document_id`),
  KEY `idx_stock_movement_company_part` (`company_id`,`part_id`),
  KEY `idx_stock_movement_company_canceled` (`company_id`,`canceled_movement_id`),
  KEY `idx_stock_movement_company_processed_by` (`company_id`,`processed_by`),
  KEY `idx_stock_movement_type_status_created` (`company_id`,`movement_type`,`movement_status`,`created_at`),
  KEY `idx_stock_movement_company_document_current` (`company_id`,`document_id`,`canceled_movement_id`,`movement_id`),
  CONSTRAINT `chk_stock_movement_quantity` CHECK (`quantity` > 0),
  CONSTRAINT `chk_stock_movement_before_after` CHECK (`before_quantity` >= 0 and `after_quantity` >= 0 and (`movement_type` in ('INBOUND','OUTBOUND_CANCEL') and `after_quantity` = `before_quantity` + `quantity` or `movement_type` in ('OUTBOUND','INBOUND_CANCEL') and `after_quantity` = `before_quantity` - `quantity`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_stock_movement_unit definition
CREATE TABLE IF NOT EXISTS `tb_stock_movement_unit` (
  `movement_unit_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `movement_id` bigint(20) NOT NULL,
  `unit_id` bigint(20) NOT NULL,
  `before_unit_status` enum('IN_STOCK','OUTBOUND','DISPOSED','CANCELED') DEFAULT NULL,
  `after_unit_status` enum('IN_STOCK','OUTBOUND','DISPOSED','CANCELED') NOT NULL,
  PRIMARY KEY (`movement_unit_id`),
  UNIQUE KEY `uk_stock_movement_unit` (`movement_id`,`unit_id`),
  KEY `idx_stock_movement_unit_movement` (`movement_id`),
  KEY `idx_stock_movement_unit_unit` (`unit_id`,`movement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- pcs_db.tb_trade_partner definition
CREATE TABLE IF NOT EXISTS `tb_trade_partner` (
  `partner_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `partner_name` varchar(150) NOT NULL,
  `partner_type` enum('PC_CAFE','PERSON','COMPANY','ETC') NOT NULL,
  `partner_role` enum('SUPPLIER','CUSTOMER','BOTH') NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `address` varchar(500) DEFAULT NULL,
  `memo` varchar(1000) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `last_transaction_at` datetime(6) DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`partner_id`),
  UNIQUE KEY `uk_trade_partner_company_name` (`company_id`,`partner_name`),
  UNIQUE KEY `uk_trade_partner_company_partner_id` (`company_id`,`partner_id`),
  KEY `idx_trade_partner_company_role` (`company_id`,`partner_role`,`active`),
  KEY `idx_trade_partner_company_type` (`company_id`,`partner_type`,`active`),
  KEY `idx_trade_partner_company_created_by` (`company_id`,`created_by`),
  KEY `idx_trade_partner_company_last_transaction` (`company_id`,`last_transaction_at`),
  KEY `idx_trade_partner_company_list` (`company_id`,`updated_at` DESC,`partner_id` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


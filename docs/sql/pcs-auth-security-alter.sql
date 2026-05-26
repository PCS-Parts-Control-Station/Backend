USE pcs_db;

-- 1. 로그인 보안용 컬럼
ALTER TABLE tb_member
    ADD COLUMN IF NOT EXISTS password_changed_at datetime(6) DEFAULT NULL COMMENT '비밀번호 마지막 변경일' AFTER temp_password_expires_at,
    ADD COLUMN IF NOT EXISTS login_failed_count int NOT NULL DEFAULT 0 COMMENT '로그인 실패 횟수' AFTER last_login_at,
    ADD COLUMN IF NOT EXISTS locked_until_at datetime(6) DEFAULT NULL COMMENT '로그인 잠금 해제 시각' AFTER login_failed_count,
    ADD COLUMN IF NOT EXISTS last_login_ip varchar(45) DEFAULT NULL COMMENT '최근 로그인 IP' AFTER locked_until_at,
    ADD COLUMN IF NOT EXISTS last_login_user_agent varchar(500) DEFAULT NULL COMMENT '최근 로그인 User-Agent' AFTER last_login_ip;

-- 2. 리프레시 토큰 테이블
-- refresh token 원문은 저장하지 말고 SHA-256 같은 해시값만 저장
CREATE TABLE IF NOT EXISTS tb_auth_refresh_token (
    token_id bigint(20) NOT NULL AUTO_INCREMENT,
    company_id bigint(20) NOT NULL,
    member_id bigint(20) NOT NULL,

    refresh_token_hash char(64) NOT NULL COMMENT 'refresh token SHA-256 해시',
    token_family_id varchar(36) NOT NULL COMMENT '토큰 회전 추적용 UUID',

    expires_at datetime(6) NOT NULL,
    last_used_at datetime(6) DEFAULT NULL,
    revoked_at datetime(6) DEFAULT NULL,
    revoked_reason enum('LOGOUT','ROTATED','EXPIRED','REUSE_DETECTED','ADMIN_REVOKED') DEFAULT NULL,
    replaced_by_token_id bigint(20) DEFAULT NULL,

    created_ip varchar(45) DEFAULT NULL,
    created_user_agent varchar(500) DEFAULT NULL,
    created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),

    PRIMARY KEY (token_id),
    UNIQUE KEY uk_auth_refresh_token_hash (refresh_token_hash),
    KEY idx_auth_refresh_member_active (company_id, member_id, revoked_at, expires_at),
    KEY idx_auth_refresh_family (company_id, member_id, token_family_id),
    KEY idx_auth_refresh_replaced_by (replaced_by_token_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE tb_auth_refresh_token
    MODIFY revoked_reason enum('LOGOUT','ROTATED','EXPIRED','REUSE_DETECTED','ADMIN_REVOKED') DEFAULT NULL;

-- 3. 로그인 이력 테이블
CREATE TABLE IF NOT EXISTS tb_auth_login_history (
    history_id bigint(20) NOT NULL AUTO_INCREMENT,
    company_id bigint(20) DEFAULT NULL,
    member_id bigint(20) DEFAULT NULL,

    company_code_snapshot varchar(50) DEFAULT NULL,
    login_id_snapshot varchar(50) NOT NULL,

    login_result enum('SUCCESS','FAIL','LOCKED','INACTIVE','TEMP_PASSWORD_EXPIRED') NOT NULL,
    failure_reason varchar(100) DEFAULT NULL,

    login_ip varchar(45) DEFAULT NULL,
    user_agent varchar(500) DEFAULT NULL,
    created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),

    PRIMARY KEY (history_id),
    KEY idx_auth_login_history_company_date (company_id, created_at),
    KEY idx_auth_login_history_member_date (company_id, member_id, created_at),
    KEY idx_auth_login_history_login_id_date (login_id_snapshot, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

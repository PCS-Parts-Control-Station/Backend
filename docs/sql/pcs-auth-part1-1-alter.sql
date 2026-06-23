USE pcs_db;

-- 파트1-1 배포 전환 스크립트
-- 1. 업체/IP 단위 로그인 실패 제한 조회를 위한 인덱스
ALTER TABLE tb_auth_login_history
    ADD INDEX IF NOT EXISTS idx_auth_login_history_company_ip_date
        (company_code_snapshot, login_ip, created_at);

START TRANSACTION;

-- 2. 이전 형식 Access Token으로 세션을 연장하지 못하도록 기존 refresh token을 전부 폐기한다.
UPDATE tb_auth_refresh_token
SET revoked_at = CURRENT_TIMESTAMP(6),
    revoked_reason = 'ADMIN_REVOKED'
WHERE revoked_at IS NULL;

-- 3. 로그인 ID를 초기 비밀번호로 사용하던 기존 임시 계정은 관리자 재발급을 강제한다.
UPDATE tb_member
SET temp_password_expires_at = CURRENT_TIMESTAMP(6)
WHERE password_status = 'TEMPORARY'
  AND (temp_password_expires_at IS NULL OR temp_password_expires_at > CURRENT_TIMESTAMP(6));

COMMIT;

package com.pcs.domain.auth.type;

public enum RefreshTokenRevokedReason {
    LOGOUT,
    ROTATED,
    REUSE_DETECTED,
    ADMIN_REVOKED
}

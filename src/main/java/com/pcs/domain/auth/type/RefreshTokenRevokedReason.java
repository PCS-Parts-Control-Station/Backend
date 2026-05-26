package com.pcs.domain.auth.type;

public enum RefreshTokenRevokedReason {
    LOGOUT,
    ROTATED,
    EXPIRED,
    REUSE_DETECTED,
    ADMIN_REVOKED
}

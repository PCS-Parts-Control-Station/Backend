package com.pcs.global.security;

import com.pcs.domain.member.type.MemberRole;

public final class PcsRoleGroups {

    public static final String OWNER = MemberRole.OWNER.name();
    public static final String ADMIN = MemberRole.ADMIN.name();
    public static final String STAFF = MemberRole.STAFF.name();

    public static final String[] WORKSPACE_USERS = {
            OWNER,
            ADMIN,
            STAFF
    };

    public static final String[] USER_MANAGERS = {
            OWNER,
            ADMIN
    };

    private PcsRoleGroups() {
    }
}

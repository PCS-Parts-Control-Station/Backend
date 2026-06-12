package com.pcs.domain.member.type;

import java.util.Arrays;
import java.util.List;

public enum StaffPermission {
    STAFF_PARTNER_MANAGE("거래처 관리"),
    STAFF_PART_CREATE("품목 관리"),
    STAFF_CATEGORY_MANAGE("품목 분류"),
    STAFF_INBOUND("입고"),
    STAFF_INSPECTION("검수"),
    STAFF_OUTBOUND("출고");

    private final String label;

    StaffPermission(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    public static List<StaffPermission> all() {
        return Arrays.asList(values());
    }
}

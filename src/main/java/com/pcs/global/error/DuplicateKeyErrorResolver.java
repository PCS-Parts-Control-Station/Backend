package com.pcs.global.error;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.dao.DuplicateKeyException;

public final class DuplicateKeyErrorResolver {

    private static final Map<String, ErrorCode> CONSTRAINT_ERROR_CODES = constraintErrorCodes();

    private DuplicateKeyErrorResolver() {
    }

    public static ErrorCode resolve(DuplicateKeyException exception) {
        if (exception == null || exception.getMostSpecificCause() == null) {
            return ErrorCode.INTERNAL_SERVER_ERROR;
        }
        String message = exception.getMostSpecificCause().getMessage();
        if (message == null) {
            return ErrorCode.INTERNAL_SERVER_ERROR;
        }
        return CONSTRAINT_ERROR_CODES.entrySet().stream()
                .filter(entry -> message.contains(entry.getKey()))
                .map(Map.Entry::getValue)
                .findFirst()
                .orElse(ErrorCode.INTERNAL_SERVER_ERROR);
    }

    private static Map<String, ErrorCode> constraintErrorCodes() {
        Map<String, ErrorCode> mappings = new LinkedHashMap<>();
        mappings.put("uk_company_code", ErrorCode.COMPANY_CODE_DUPLICATED);
        mappings.put(
                "uk_company_business_registration_no",
                ErrorCode.COMPANY_BUSINESS_REGISTRATION_NO_DUPLICATED
        );
        mappings.put("uk_member_company_login", ErrorCode.MEMBER_LOGIN_ID_DUPLICATED);
        mappings.put("uk_part_category_company_name", ErrorCode.CATEGORY_NAME_DUPLICATED);
        mappings.put("uk_pc_part_company_code", ErrorCode.PART_CODE_DUPLICATED);
        mappings.put("uk_trade_partner_company_name", ErrorCode.PARTNER_NAME_DUPLICATED);
        mappings.put("uk_stock_document_document_no", ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED);
        mappings.put("uk_stock_document_company_document_no", ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED);
        mappings.put("uk_pc_part_unit_internal_serial", ErrorCode.PART_UNIT_SERIAL_DUPLICATED);
        mappings.put("uk_pc_part_unit_manufacturer_serial", ErrorCode.PART_UNIT_SERIAL_DUPLICATED);
        mappings.put("uk_inspection_template_version", ErrorCode.INSPECTION_TEMPLATE_DUPLICATED);
        mappings.put("uk_inspection_template_item_name", ErrorCode.INSPECTION_TEMPLATE_ITEM_DUPLICATED);
        mappings.put(
                "uk_inspection_template_item_option_value",
                ErrorCode.INSPECTION_TEMPLATE_OPTION_DUPLICATED
        );
        mappings.put(
                "uk_inspection_template_item_option_label",
                ErrorCode.INSPECTION_TEMPLATE_OPTION_DUPLICATED
        );
        return Map.copyOf(mappings);
    }
}

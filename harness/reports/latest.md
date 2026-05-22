# PCS Harness Report

- Mode: bootstrap
- Feature: auth
- RunDb: True
- DbFeature: none
- GeneratedAt: 2026-05-22 14:44:48
- FAIL: 0
- WARN: 0
- INFO: 82

## FAIL

- none

## WARN

- none

## INFO

1. [GITIGNORE_REQUIRED_RULES] .gitignore contains required rules.
2. [JAVA_17_REQUIRED] Java 17 or later is available.
3. [JS_SYNTAX] JS syntax check passed.
4. [AUTH_FEATURE] Auth feature checks completed.
5. [DB_CONNECTED] Connected to database: pcs_db
6. [DB_TABLE_TB_COMPANY] tb_company exists.
7. [DB_TABLE_TB_MEMBER] tb_member exists.
8. [DB_TABLE_TB_AUTH_REFRESH_TOKEN] tb_auth_refresh_token exists.
9. [DB_TABLE_TB_AUTH_LOGIN_HISTORY] tb_auth_login_history exists.
10. [DB_TABLE_TB_TRADE_PARTNER] tb_trade_partner exists.
11. [DB_TABLE_TB_PART_CATEGORY] tb_part_category exists.
12. [DB_TABLE_TB_PC_PART] tb_pc_part exists.
13. [DB_TABLE_TB_PC_PART_UNIT] tb_pc_part_unit exists.
14. [DB_TABLE_TB_PART_STOCK] tb_part_stock exists.
15. [DB_TABLE_TB_STOCK_DOCUMENT] tb_stock_document exists.
16. [DB_TABLE_TB_STOCK_MOVEMENT] tb_stock_movement exists.
17. [DB_TABLE_TB_STOCK_MOVEMENT_UNIT] tb_stock_movement_unit exists.
18. [DB_TABLE_TB_INSPECTION_TEMPLATE] tb_inspection_template exists.
19. [DB_TABLE_TB_INSPECTION_TEMPLATE_ITEM] tb_inspection_template_item exists.
20. [DB_TABLE_TB_INSPECTION_TEMPLATE_ITEM_OPTION] tb_inspection_template_item_option exists.
21. [DB_TABLE_TB_INSPECTION] tb_inspection exists.
22. [DB_TABLE_TB_PART_STATUS_HISTORY] tb_part_status_history exists.
23. [DB_TABLE_TB_INSPECTION_ITEM_RESULT] tb_inspection_item_result exists.
24. [DB_COLUMN_TB_MEMBER_COMPANY_ID] tb_member.company_id exists.
25. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_COMPANY_ID] tb_auth_refresh_token.company_id exists.
26. [DB_COLUMN_TB_AUTH_LOGIN_HISTORY_COMPANY_ID] tb_auth_login_history.company_id exists.
27. [DB_COLUMN_TB_TRADE_PARTNER_COMPANY_ID] tb_trade_partner.company_id exists.
28. [DB_COLUMN_TB_PART_CATEGORY_COMPANY_ID] tb_part_category.company_id exists.
29. [DB_COLUMN_TB_PC_PART_COMPANY_ID] tb_pc_part.company_id exists.
30. [DB_COLUMN_TB_PC_PART_UNIT_COMPANY_ID] tb_pc_part_unit.company_id exists.
31. [DB_COLUMN_TB_PART_STOCK_COMPANY_ID] tb_part_stock.company_id exists.
32. [DB_COLUMN_TB_STOCK_DOCUMENT_COMPANY_ID] tb_stock_document.company_id exists.
33. [DB_COLUMN_TB_STOCK_MOVEMENT_COMPANY_ID] tb_stock_movement.company_id exists.
34. [DB_COLUMN_TB_INSPECTION_TEMPLATE_COMPANY_ID] tb_inspection_template.company_id exists.
35. [DB_COLUMN_TB_INSPECTION_COMPANY_ID] tb_inspection.company_id exists.
36. [DB_COLUMN_TB_PART_STATUS_HISTORY_COMPANY_ID] tb_part_status_history.company_id exists.
37. [DB_COLUMN_TB_COMPANY_COMPANY_CODE] tb_company.company_code exists.
38. [DB_COLUMN_TB_COMPANY_REPRESENTATIVE_EMAIL] tb_company.representative_email exists.
39. [DB_COLUMN_TB_COMPANY_REPRESENTATIVE_PHONE] tb_company.representative_phone exists.
40. [DB_COLUMN_TB_COMPANY_BUSINESS_REGISTRATION_NO] tb_company.business_registration_no exists.
41. [DB_COLUMN_TB_MEMBER_OWNER_SLOT] tb_member.owner_slot exists.
42. [DB_COLUMN_TB_MEMBER_PASSWORD_HASH] tb_member.password_hash exists.
43. [DB_COLUMN_TB_MEMBER_PASSWORD_STATUS] tb_member.password_status exists.
44. [DB_COLUMN_TB_MEMBER_LOGIN_FAILED_COUNT] tb_member.login_failed_count exists.
45. [DB_COLUMN_TB_MEMBER_LOCKED_UNTIL_AT] tb_member.locked_until_at exists.
46. [DB_COLUMN_TB_MEMBER_LAST_LOGIN_IP] tb_member.last_login_ip exists.
47. [DB_COLUMN_TB_MEMBER_LAST_LOGIN_USER_AGENT] tb_member.last_login_user_agent exists.
48. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_REFRESH_TOKEN_HASH] tb_auth_refresh_token.refresh_token_hash exists.
49. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_TOKEN_FAMILY_ID] tb_auth_refresh_token.token_family_id exists.
50. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_EXPIRES_AT] tb_auth_refresh_token.expires_at exists.
51. [DB_COLUMN_TB_AUTH_LOGIN_HISTORY_LOGIN_RESULT] tb_auth_login_history.login_result exists.
52. [DB_CONSTRAINT_UK_COMPANY_CODE] tb_company.uk_company_code exists.
53. [DB_CONSTRAINT_UK_COMPANY_BUSINESS_REGISTRATION_NO] tb_company.uk_company_business_registration_no exists.
54. [DB_CONSTRAINT_UK_MEMBER_COMPANY_LOGIN] tb_member.uk_member_company_login exists.
55. [DB_CONSTRAINT_UK_MEMBER_COMPANY_OWNER] tb_member.uk_member_company_owner exists.
56. [DB_CONSTRAINT_CHK_MEMBER_OWNER_SLOT] tb_member.chk_member_owner_slot exists.
57. [DB_CONSTRAINT_UK_AUTH_REFRESH_TOKEN_HASH] tb_auth_refresh_token.uk_auth_refresh_token_hash exists.
58. [CHECKDB_SCHEMA] Common DB preflight checks completed.
59. [DB_COLUMN_TB_MEMBER_LAST_LOGIN_AT] tb_member.last_login_at exists.
60. [DB_COLUMN_TB_MEMBER_LOGIN_FAILED_COUNT] tb_member.login_failed_count exists.
61. [DB_COLUMN_TB_MEMBER_LOCKED_UNTIL_AT] tb_member.locked_until_at exists.
62. [DB_COLUMN_TB_MEMBER_LAST_LOGIN_IP] tb_member.last_login_ip exists.
63. [DB_COLUMN_TB_MEMBER_LAST_LOGIN_USER_AGENT] tb_member.last_login_user_agent exists.
64. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_COMPANY_ID] tb_auth_refresh_token.company_id exists.
65. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_MEMBER_ID] tb_auth_refresh_token.member_id exists.
66. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_REFRESH_TOKEN_HASH] tb_auth_refresh_token.refresh_token_hash exists.
67. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_TOKEN_FAMILY_ID] tb_auth_refresh_token.token_family_id exists.
68. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_EXPIRES_AT] tb_auth_refresh_token.expires_at exists.
69. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_REVOKED_AT] tb_auth_refresh_token.revoked_at exists.
70. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_REVOKED_REASON] tb_auth_refresh_token.revoked_reason exists.
71. [DB_COLUMN_TB_AUTH_REFRESH_TOKEN_REPLACED_BY_TOKEN_ID] tb_auth_refresh_token.replaced_by_token_id exists.
72. [DB_COLUMN_TB_AUTH_LOGIN_HISTORY_COMPANY_CODE_SNAPSHOT] tb_auth_login_history.company_code_snapshot exists.
73. [DB_COLUMN_TB_AUTH_LOGIN_HISTORY_LOGIN_ID_SNAPSHOT] tb_auth_login_history.login_id_snapshot exists.
74. [DB_COLUMN_TB_AUTH_LOGIN_HISTORY_LOGIN_RESULT] tb_auth_login_history.login_result exists.
75. [DB_CONSTRAINT_UK_AUTH_REFRESH_TOKEN_HASH] tb_auth_refresh_token.uk_auth_refresh_token_hash exists.
76. [AUTH_MEMBER_LOGIN_STATE] Member login state columns can be updated.
77. [AUTH_REFRESH_TOKEN_SAVED] Refresh token hash row is saved.
78. [DB_CHECK_OUTPUT] [ WARN] (main) Error: 1062-23000: Duplicate entry 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' for key 'uk_auth_refresh_token_hash'
79. [AUTH_REFRESH_TOKEN_HASH_UNIQUE] Expected SQL failure occurred: 1062
80. [AUTH_LOGIN_HISTORY_SAVED] Login history row is saved.
81. [AUTH_DB_ROLLBACK_SCOPE] Auth DB scenario was executed inside a rollback transaction.
82. [COMPILE_JAVA] compileJava passed.


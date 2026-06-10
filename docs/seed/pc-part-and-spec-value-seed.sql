SET NAMES utf8mb4;
USE pcs_db;

-- Generated from docs/seed/pc-part-seed-candidates.csv
-- company_id 1 기준 seed입니다. estimated_price는 시장가 변동 때문에 0으로 둡니다.
-- 일부 필수 사양 중 CSV에 없는 값은 seed 표시용 추정 기본값을 사용했습니다.

-- Execute this file as a whole. Running selected fragments can fail because session variables are reused.

SET @company_id := 1;
SET @created_by := NULL;

START TRANSACTION;

-- 1. 필요한 SELECT 사양 선택지 보강
INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'NVIDIA GeForce RTX 4080 SUPER', 'NVIDIA_RTX_4080_SUPER', 25, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'NVIDIA GeForce RTX 4070 SUPER', 'NVIDIA_RTX_4070_SUPER', 35, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'NVIDIA GeForce RTX 4060', 'NVIDIA_RTX_4060', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'NVIDIA GeForce RTX 3060', 'NVIDIA_RTX_3060', 50, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'NVIDIA GeForce RTX 3050', 'NVIDIA_RTX_3050', 55, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AMD Radeon RX 7900 XTX', 'AMD_RX_7900_XTX', 80, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AMD Radeon RX 7900 GRE', 'AMD_RX_7900_GRE', 85, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AMD Radeon RX 7800 XT', 'AMD_RX_7800_XT', 90, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AMD Radeon RX 7600', 'AMD_RX_7600', 100, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'GDDR6', 'GDDR6', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'GDDR6X', 'GDDR6X', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '수직 지지대', 'VERTICAL', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'support_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '나사 고정', 'SCREW_FIXED', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'support_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '직선형', 'STRAIGHT', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'angle';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'PCIe 4.0', 'PCIE_4_0', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'pcie_version';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'Intel B760', 'INTEL_B760', 100, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AMD B650E', 'AMD_B650E', 100, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AMD B650', 'AMD_B650', 100, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AMD A520', 'AMD_A520', 100, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'Intel Z790', 'INTEL_Z790', 100, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AMD X670E', 'AMD_X670E', 100, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AMD B850', 'AMD_B850', 100, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'LGA 1700', 'LGA1700', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AM5', 'AM5', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AM4', 'AM4', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'ATX', 'ATX', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'Micro-ATX', 'MICRO_ATX', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'DDR4', 'DDR4', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'DDR5', 'DDR5', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'Bluetooth 5.0', 'BT_5_0', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'bluetooth_version';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'Bluetooth 5.x', 'BT_5_X', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'bluetooth_version';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'PCIe x1', 'PCIE_X1', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'Wi-Fi 5', 'WIFI_5', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'Wi-Fi 6', 'WIFI_6', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'Wi-Fi 6E', 'WIFI_6E', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '5.1채널', '5_1CH', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'channel_support';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '7.1채널', '7_1CH', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'channel_support';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'PCIe x1', 'PCIE_X1', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'PCIe x4', 'PCIE_X4', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'USB 3.0', 'USB_3_0', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'USB-C', 'USB_C', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '1080p 60Hz', '1080P_60', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '4K 60Hz', '4K_60', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '1080p 60fps', '1080P_60FPS', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '4K 30fps', '4K_30FPS', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '4K 60fps', '4K_60FPS', 50, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'SATA 케이블', 'SATA_CABLE', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '전원 연장 케이블', 'POWER_EXTENSION', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'USB 케이블', 'USB_CABLE', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '디스플레이 케이블', 'DISPLAY_CABLE', 50, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '미니타워', 'MINI_TOWER', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '미들타워', 'MID_TOWER', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '3핀 DC', '3PIN_DC', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '4핀 PWM', '4PIN_PWM', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '80PLUS Standard', '80PLUS_STANDARD', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '80PLUS Gold', '80PLUS_GOLD', 50, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'ATX', 'ATX', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '일반 케이블', 'NON_MODULAR', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '풀 모듈러', 'FULL_MODULAR', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '팬 허브', 'FAN_HUB', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'PWM+ARGB 허브', 'PWM_ARGB_HUB', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'SATA 전원', 'SATA_POWER', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'power_connector';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'LGA 1700', 'LGA1700', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'LGA 1851', 'LGA1851', 15, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AM5', 'AM5', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'AM4', 'AM4', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '공랭', 'AIR', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '일체형 수랭', 'AIO_LIQUID', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '3.5인치', '3_5_INCH', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'SATA3', 'SATA3', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '확인 불가', 'UNKNOWN', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '5.25인치', '5_25_INCH', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'form_factor';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '외장형', 'EXTERNAL', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'form_factor';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'SATA', 'SATA', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'USB 2.0', 'USB_2_0', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'DVD-RW', 'DVD_RW', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'odd_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'Blu-ray Writer', 'BLU_RAY_WRITER', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'odd_type';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'DDR4', 'DDR4', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'DDR5', 'DDR5', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'M.2 2280', 'M2_2280', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, '2.5인치', '2_5_INCH', 40, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'SATA3', 'SATA3', 10, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'PCIe 3.0 x4 NVMe', 'PCIE_3_X4_NVME', 20, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';

INSERT IGNORE INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active)
SELECT d.spec_definition_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', 30, TRUE
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';

-- 2. 품목 및 품목 사양값 seed
-- CPU / Intel / Core i9-14900K
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Core i9-14900K', 'BX8071514900K', 'Intel', 'CPU-INT-14900K', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-INT-14900K' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 24, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 32, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 125, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / Intel / Core i7-14700K
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Core i7-14700K', 'BX8071514700K', 'Intel', 'CPU-INT-14700K', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-INT-14700K' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 20, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 28, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 125, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / Intel / Core i7-14700F
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Core i7-14700F', 'BX8071514700F', 'Intel', 'CPU-INT-14700F', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-INT-14700F' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 20, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 28, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / Intel / Core i5-14600K
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Core i5-14600K', 'BX8071514600K', 'Intel', 'CPU-INT-14600K', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-INT-14600K' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 14, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 20, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 125, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / Intel / Core i5-14500
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Core i5-14500', 'BX8071514500', 'Intel', 'CPU-INT-14500', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-INT-14500' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 14, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 20, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / Intel / Core i5-14400F
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Core i5-14400F', 'BX8071514400F', 'Intel', 'CPU-INT-14400F', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-INT-14400F' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 10, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / Intel / Core i3-14100
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Core i3-14100', 'BX8071514100', 'Intel', 'CPU-INT-14100', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-INT-14100' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 60, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / Intel / Core Ultra 7 265K
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Core Ultra 7 265K', 'BX80768265K', 'Intel', 'CPU-INT-U7-265K', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-INT-U7-265K' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1851', 'LGA1851', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1851' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 20, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 20, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 125, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / Intel / Core Ultra 5 245K
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Core Ultra 5 245K', 'BX80768245K', 'Intel', 'CPU-INT-U5-245K', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-INT-U5-245K' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1851', 'LGA1851', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1851' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 14, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 14, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 125, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 9 7950X
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 9 7950X', '100-100000514WOF', 'AMD', 'CPU-AMD-7950X', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-7950X' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 32, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 170, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 9 7900X
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 9 7900X', '100-100000589WOF', 'AMD', 'CPU-AMD-7900X', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-7900X' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 24, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 170, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 7 7800X3D
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 7 7800X3D', '100-100000910WOF', 'AMD', 'CPU-AMD-7800X3D', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-7800X3D' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 7 7700
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 7 7700', '100-100000592BOX', 'AMD', 'CPU-AMD-7700', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-7700' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 5 7600
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 5 7600', '100-100001015BOX', 'AMD', 'CPU-AMD-7600', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-7600' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 5 7500F
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 5 7500F', '100-100000597MPK', 'AMD', 'CPU-AMD-7500F', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-7500F' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 7 5700X3D
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 7 5700X3D', '100-100001503WOF', 'AMD', 'CPU-AMD-5700X3D', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-5700X3D' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM4', 'AM4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 105, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 5 5600
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 5 5600', '100-100000927BOX', 'AMD', 'CPU-AMD-5600', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-5600' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM4', 'AM4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 5 5600G
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 5 5600G', '100-100000252BOX', 'AMD', 'CPU-AMD-5600G', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-5600G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM4', 'AM4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 7 9700X
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 7 9700X', '100-100001404WOF', 'AMD', 'CPU-AMD-9700X', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-9700X' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- CPU / AMD / Ryzen 5 9600X
SET @category_id := 1;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ryzen 5 9600X', '100-100001405WOF', 'AMD', 'CPU-AMD-9600X', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CPU-AMD-9600X' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'cores';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'threads';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'has_integrated_graphics';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 65, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 1
  AND d.spec_key = 'tdp';

-- 메인보드 / ASUS / PRIME B760M-K D4
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PRIME B760M-K D4', 'PRIME B760M-K D4', 'ASUS', 'MB-ASUS-B760M-K-D4', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASUS-B760M-K-D4' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Intel B760', 'INTEL_B760', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'INTEL_B760' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / ASUS / TUF GAMING B760M-PLUS WIFI
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'TUF GAMING B760M-PLUS WIFI', 'TUF GAMING B760M-PLUS WIFI', 'ASUS', 'MB-ASUS-B760M-TUF-WIFI', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASUS-B760M-TUF-WIFI' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Intel B760', 'INTEL_B760', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'INTEL_B760' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / ASUS / ROG STRIX B650E-F GAMING WIFI
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'ROG STRIX B650E-F GAMING WIFI', 'ROG STRIX B650E-F GAMING WIFI', 'ASUS', 'MB-ASUS-B650E-F-WIFI', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASUS-B650E-F-WIFI' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD B650E', 'AMD_B650E', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_B650E' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / MSI / PRO B760M-A WIFI DDR4
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PRO B760M-A WIFI DDR4', 'PRO B760M-A WIFI DDR4', 'MSI', 'MB-MSI-B760M-A-WIFI-D4', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-MSI-B760M-A-WIFI-D4' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Intel B760', 'INTEL_B760', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'INTEL_B760' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / MSI / MAG B650M MORTAR WIFI
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'MAG B650M MORTAR WIFI', 'MAG B650M MORTAR WIFI', 'MSI', 'MB-MSI-B650M-MORTAR-WIFI', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-MSI-B650M-MORTAR-WIFI' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD B650', 'AMD_B650', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_B650' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / MSI / B650M PROJECT ZERO
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'B650M PROJECT ZERO', 'B650M PROJECT ZERO', 'MSI', 'MB-MSI-B650M-PROJECT-ZERO', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-MSI-B650M-PROJECT-ZERO' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD B650', 'AMD_B650', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_B650' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / GIGABYTE / B760M AORUS ELITE AX
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'B760M AORUS ELITE AX', 'B760M AORUS ELITE AX', 'GIGABYTE', 'MB-GB-B760M-AORUS-AX', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-GB-B760M-AORUS-AX' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Intel B760', 'INTEL_B760', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'INTEL_B760' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / GIGABYTE / B650 AORUS ELITE AX V2
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'B650 AORUS ELITE AX V2', 'B650 AORUS ELITE AX V2', 'GIGABYTE', 'MB-GB-B650-AORUS-AX-V2', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-GB-B650-AORUS-AX-V2' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD B650', 'AMD_B650', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_B650' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / ASRock / B760M Pro RS/D4
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'B760M Pro RS/D4', 'B760M Pro RS/D4', 'ASRock', 'MB-ASR-B760M-PRO-RS-D4', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASR-B760M-PRO-RS-D4' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Intel B760', 'INTEL_B760', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'INTEL_B760' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / ASRock / B650M Pro RS
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'B650M Pro RS', 'B650M Pro RS', 'ASRock', 'MB-ASR-B650M-PRO-RS', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASR-B650M-PRO-RS' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD B650', 'AMD_B650', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_B650' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / ASRock / A520M-HDV
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'A520M-HDV', 'A520M-HDV', 'ASRock', 'MB-ASR-A520M-HDV', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASR-A520M-HDV' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM4', 'AM4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD A520', 'AMD_A520', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_A520' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / ASUS / PRIME A520M-K
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PRIME A520M-K', 'PRIME A520M-K', 'ASUS', 'MB-ASUS-A520M-K', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASUS-A520M-K' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM4', 'AM4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD A520', 'AMD_A520', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_A520' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / MSI / A520M-A PRO
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'A520M-A PRO', 'A520M-A PRO', 'MSI', 'MB-MSI-A520M-A-PRO', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-MSI-A520M-A-PRO' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM4', 'AM4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD A520', 'AMD_A520', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_A520' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / GIGABYTE / A520M K V2
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'A520M K V2', 'A520M K V2', 'GIGABYTE', 'MB-GB-A520M-K-V2', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-GB-A520M-K-V2' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM4', 'AM4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD A520', 'AMD_A520', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_A520' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Micro-ATX', 'MICRO_ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MICRO_ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / ASUS / PRIME Z790-P WIFI
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PRIME Z790-P WIFI', 'PRIME Z790-P WIFI', 'ASUS', 'MB-ASUS-Z790-P-WIFI', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASUS-Z790-P-WIFI' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Intel Z790', 'INTEL_Z790', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'INTEL_Z790' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / MSI / PRO Z790-A MAX WIFI
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PRO Z790-A MAX WIFI', 'PRO Z790-A MAX WIFI', 'MSI', 'MB-MSI-Z790-A-MAX-WIFI', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-MSI-Z790-A-MAX-WIFI' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Intel Z790', 'INTEL_Z790', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'INTEL_Z790' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / GIGABYTE / Z790 AORUS ELITE AX
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Z790 AORUS ELITE AX', 'Z790 AORUS ELITE AX', 'GIGABYTE', 'MB-GB-Z790-AORUS-AX', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-GB-Z790-AORUS-AX' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'LGA 1700', 'LGA1700', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'LGA1700' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Intel Z790', 'INTEL_Z790', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'INTEL_Z790' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / ASRock / X670E Steel Legend
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'X670E Steel Legend', 'X670E Steel Legend', 'ASRock', 'MB-ASR-X670E-STEEL', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASR-X670E-STEEL' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD X670E', 'AMD_X670E', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_X670E' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / ASUS / PRIME B850-PLUS WIFI
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PRIME B850-PLUS WIFI', 'PRIME B850-PLUS WIFI', 'ASUS', 'MB-ASUS-B850-PLUS-WIFI', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-ASUS-B850-PLUS-WIFI' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD B850', 'AMD_B850', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_B850' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- 메인보드 / MSI / MAG B850 TOMAHAWK WIFI
SET @category_id := 2;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'MAG B850 TOMAHAWK WIFI', 'MAG B850 TOMAHAWK WIFI', 'MSI', 'MB-MSI-B850-TOMAHAWK-WIFI', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'MB-MSI-B850-TOMAHAWK-WIFI' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AM5', 'AM5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AM5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'cpu_socket';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD B850', 'AMD_B850', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_B850' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'ram_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'm2_slots';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 2
  AND d.spec_key = 'has_wifi';

-- RAM / Samsung / DDR5-5600 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR5-5600 16GB', 'M323R2GA3BB0-CWM', 'Samsung', 'RAM-SAM-DDR5-5600-16', 0.00, 8, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-SAM-DDR5-5600-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 5600, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Samsung / DDR5-5600 32GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR5-5600 32GB', 'M323R4GA3BB0-CWM', 'Samsung', 'RAM-SAM-DDR5-5600-32', 0.00, 6, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-SAM-DDR5-5600-32' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 32, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 5600, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Samsung / DDR4-3200 8GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR4-3200 8GB', 'M378A1K43EB2-CWE', 'Samsung', 'RAM-SAM-DDR4-3200-8', 0.00, 10, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-SAM-DDR4-3200-8' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Samsung / DDR4-3200 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR4-3200 16GB', 'M378A2K43EB1-CWE', 'Samsung', 'RAM-SAM-DDR4-3200-16', 0.00, 8, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-SAM-DDR4-3200-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / SK hynix / DDR5-5600 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR5-5600 16GB', 'HMCG78AGBUA084N', 'SK hynix', 'RAM-HYN-DDR5-5600-16', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-HYN-DDR5-5600-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 5600, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / SK hynix / DDR4-3200 8GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR4-3200 8GB', 'HMA81GU6DJR8N-XN', 'SK hynix', 'RAM-HYN-DDR4-3200-8', 0.00, 6, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-HYN-DDR4-3200-8' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Micron Crucial / DDR5-5600 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR5-5600 16GB', 'CT16G56C46U5', 'Micron Crucial', 'RAM-CRU-DDR5-5600-16', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-CRU-DDR5-5600-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 5600, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 46, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Micron Crucial / DDR4-3200 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR4-3200 16GB', 'CT16G4DFRA32A', 'Micron Crucial', 'RAM-CRU-DDR4-3200-16', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-CRU-DDR4-3200-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / TeamGroup / T-Force Delta RGB DDR5-6000 32GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'T-Force Delta RGB DDR5-6000 32GB', 'FF3D532G6000HC38ADC01', 'TeamGroup', 'RAM-TG-DELTA-DDR5-6000-32', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-TG-DELTA-DDR5-6000-32' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 38, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / G.SKILL / Trident Z5 RGB DDR5-6000 32GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Trident Z5 RGB DDR5-6000 32GB', 'F5-6000J3038F16GX2-TZ5RK', 'G.SKILL', 'RAM-GSK-TZ5-DDR5-6000-32', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-GSK-TZ5-DDR5-6000-32' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 30, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / G.SKILL / Ripjaws S5 DDR5-6000 32GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ripjaws S5 DDR5-6000 32GB', 'F5-6000J3238F16GX2-RS5K', 'G.SKILL', 'RAM-GSK-RS5-DDR5-6000-32', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-GSK-RS5-DDR5-6000-32' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 32, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Corsair / Vengeance DDR5-5600 32GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Vengeance DDR5-5600 32GB', 'CMK32GX5M2B5600C36', 'Corsair', 'RAM-COR-VEN-DDR5-5600-32', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-COR-VEN-DDR5-5600-32' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 5600, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 36, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Corsair / Vengeance RGB PRO DDR4-3600 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Vengeance RGB PRO DDR4-3600 16GB', 'CMW16GX4M2D3600C18', 'Corsair', 'RAM-COR-RGBPRO-DDR4-3600-16', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-COR-RGBPRO-DDR4-3600-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3600, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 18, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Kingston / FURY Beast DDR5-6000 32GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'FURY Beast DDR5-6000 32GB', 'KF560C36BBEK2-32', 'Kingston', 'RAM-KIN-FURY-DDR5-6000-32', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-KIN-FURY-DDR5-6000-32' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 36, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Kingston / FURY Beast DDR4-3200 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'FURY Beast DDR4-3200 16GB', 'KF432C16BBK2-16', 'Kingston', 'RAM-KIN-FURY-DDR4-3200-16', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-KIN-FURY-DDR4-3200-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / ADATA XPG / Lancer RGB DDR5-6000 32GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Lancer RGB DDR5-6000 32GB', 'AX5U6000C4016G-DCLARBK', 'ADATA XPG', 'RAM-XPG-LANCER-DDR5-6000-32', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-XPG-LANCER-DDR5-6000-32' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 40, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / GeIL / EVO V DDR5-6000 32GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'EVO V DDR5-6000 32GB', 'GOSG532GB6000C36ADC', 'GeIL', 'RAM-GEIL-EVOV-DDR5-6000-32', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-GEIL-EVOV-DDR5-6000-32' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 36, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'cl_timing';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / Patriot / Viper Steel DDR4-3200 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Viper Steel DDR4-3200 16GB', 'PVS416G320C6K', 'Patriot', 'RAM-PAT-VIPER-DDR4-3200-16', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-PAT-VIPER-DDR4-3200-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / ESSENCORE KLEVV / DDR5-5600 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR5-5600 16GB', 'KD5AGUA80-56G460A', 'ESSENCORE KLEVV', 'RAM-KLEVV-DDR5-5600-16', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-KLEVV-DDR5-5600-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR5', 'DDR5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 5600, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- RAM / ESSENCORE KLEVV / DDR4-3200 16GB
SET @category_id := 3;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DDR4-3200 16GB', 'KD48GU880-32N220A', 'ESSENCORE KLEVV', 'RAM-KLEVV-DDR4-3200-16', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RAM-KLEVV-DDR4-3200-16' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DDR4', 'DDR4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DDR4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'generation';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'module_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'clock_speed';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_xmp_expo';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 3
  AND d.spec_key = 'has_heatsink';

-- 그래픽카드 / ASUS / Dual GeForce RTX 4060 O8G
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Dual GeForce RTX 4060 O8G', 'DUAL-RTX4060-O8G', 'ASUS', 'GPU-ASUS-RTX4060-DUAL-8G', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-ASUS-RTX4060-DUAL-8G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4060', 'NVIDIA_RTX_4060', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4060' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 550, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 220, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / MSI / GeForce RTX 4060 VENTUS 2X BLACK OC 8GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GeForce RTX 4060 VENTUS 2X BLACK OC 8GB', 'RTX 4060 VENTUS 2X BLACK 8G OC', 'MSI', 'GPU-MSI-RTX4060-VENTUS-8G', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-MSI-RTX4060-VENTUS-8G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4060', 'NVIDIA_RTX_4060', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4060' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 550, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 220, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / GIGABYTE / GeForce RTX 4060 WINDFORCE OC 8GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GeForce RTX 4060 WINDFORCE OC 8GB', 'GV-N4060WF2OC-8GD', 'GIGABYTE', 'GPU-GB-RTX4060-WF-8G', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-GB-RTX4060-WF-8G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4060', 'NVIDIA_RTX_4060', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4060' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 550, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 220, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / ZOTAC / GAMING GeForce RTX 4060 Twin Edge OC 8GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GAMING GeForce RTX 4060 Twin Edge OC 8GB', 'ZT-D40600H-10M', 'ZOTAC', 'GPU-ZOTAC-RTX4060-TE-8G', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-ZOTAC-RTX4060-TE-8G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4060', 'NVIDIA_RTX_4060', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4060' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 550, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 220, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / ASUS / TUF Gaming GeForce RTX 4070 SUPER O12G
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'TUF Gaming GeForce RTX 4070 SUPER O12G', 'TUF-RTX4070S-O12G-GAMING', 'ASUS', 'GPU-ASUS-RTX4070S-TUF-12G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-ASUS-RTX4070S-TUF-12G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4070 SUPER', 'NVIDIA_RTX_4070_SUPER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4070_SUPER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6X', 'GDDR6X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 650, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 300, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / MSI / GeForce RTX 4070 SUPER GAMING X SLIM 12GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GeForce RTX 4070 SUPER GAMING X SLIM 12GB', 'RTX 4070 SUPER 12G GAMING X SLIM', 'MSI', 'GPU-MSI-RTX4070S-GXSLIM-12G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-MSI-RTX4070S-GXSLIM-12G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4070 SUPER', 'NVIDIA_RTX_4070_SUPER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4070_SUPER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6X', 'GDDR6X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 650, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 300, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / GIGABYTE / GeForce RTX 4070 SUPER WINDFORCE OC 12GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GeForce RTX 4070 SUPER WINDFORCE OC 12GB', 'GV-N407SWF3OC-12GD', 'GIGABYTE', 'GPU-GB-RTX4070S-WF-12G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-GB-RTX4070S-WF-12G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4070 SUPER', 'NVIDIA_RTX_4070_SUPER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4070_SUPER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6X', 'GDDR6X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 650, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 300, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / ZOTAC / GAMING GeForce RTX 4070 SUPER Twin Edge OC 12GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GAMING GeForce RTX 4070 SUPER Twin Edge OC 12GB', 'ZT-D40720H-10M', 'ZOTAC', 'GPU-ZOTAC-RTX4070S-TE-12G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-ZOTAC-RTX4070S-TE-12G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4070 SUPER', 'NVIDIA_RTX_4070_SUPER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4070_SUPER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6X', 'GDDR6X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 650, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 300, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / ASUS / ProArt GeForce RTX 4080 SUPER OC 16GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'ProArt GeForce RTX 4080 SUPER OC 16GB', 'PROART-RTX4080S-O16G', 'ASUS', 'GPU-ASUS-RTX4080S-PROART-16G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-ASUS-RTX4080S-PROART-16G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4080 SUPER', 'NVIDIA_RTX_4080_SUPER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4080_SUPER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6X', 'GDDR6X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 320, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / MSI / GeForce RTX 4080 SUPER VENTUS 3X OC 16GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GeForce RTX 4080 SUPER VENTUS 3X OC 16GB', 'RTX 4080 SUPER 16G VENTUS 3X OC', 'MSI', 'GPU-MSI-RTX4080S-VENTUS-16G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-MSI-RTX4080S-VENTUS-16G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4080 SUPER', 'NVIDIA_RTX_4080_SUPER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4080_SUPER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6X', 'GDDR6X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 320, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / GIGABYTE / GeForce RTX 4080 SUPER GAMING OC 16GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GeForce RTX 4080 SUPER GAMING OC 16GB', 'GV-N408SGAMING OC-16GD', 'GIGABYTE', 'GPU-GB-RTX4080S-GAMING-16G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-GB-RTX4080S-GAMING-16G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 4080 SUPER', 'NVIDIA_RTX_4080_SUPER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_4080_SUPER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6X', 'GDDR6X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 320, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / SAPPHIRE / PULSE Radeon RX 7600 8GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PULSE Radeon RX 7600 8GB', '11324-01-20G', 'SAPPHIRE', 'GPU-SAP-RX7600-PULSE-8G', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-SAP-RX7600-PULSE-8G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD Radeon RX 7600', 'AMD_RX_7600', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_RX_7600' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 550, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 240, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / ASRock / Radeon RX 7600 Challenger 8GB OC
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Radeon RX 7600 Challenger 8GB OC', 'RX7600 CL 8GO', 'ASRock', 'GPU-ASR-RX7600-CHALLENGER-8G', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-ASR-RX7600-CHALLENGER-8G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD Radeon RX 7600', 'AMD_RX_7600', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_RX_7600' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 550, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 240, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / XFX / SPEEDSTER SWFT 210 Radeon RX 7600 8GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'SPEEDSTER SWFT 210 Radeon RX 7600 8GB', 'RX-76PSWFTFY', 'XFX', 'GPU-XFX-RX7600-SWFT-8G', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-XFX-RX7600-SWFT-8G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD Radeon RX 7600', 'AMD_RX_7600', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_RX_7600' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 550, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 240, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / SAPPHIRE / PULSE Radeon RX 7800 XT 16GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PULSE Radeon RX 7800 XT 16GB', '11330-02-20G', 'SAPPHIRE', 'GPU-SAP-RX7800XT-PULSE-16G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-SAP-RX7800XT-PULSE-16G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD Radeon RX 7800 XT', 'AMD_RX_7800_XT', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_RX_7800_XT' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 700, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 300, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / PowerColor / Hellhound Radeon RX 7800 XT 16GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Hellhound Radeon RX 7800 XT 16GB', 'RX 7800 XT 16G-L/OC', 'PowerColor', 'GPU-PWC-RX7800XT-HELLHOUND-16G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-PWC-RX7800XT-HELLHOUND-16G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD Radeon RX 7800 XT', 'AMD_RX_7800_XT', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_RX_7800_XT' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 700, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 300, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / ASRock / Radeon RX 7900 GRE Challenger 16GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Radeon RX 7900 GRE Challenger 16GB', 'RX7900GRE CL 16GO', 'ASRock', 'GPU-ASR-RX7900GRE-16G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-ASR-RX7900GRE-16G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD Radeon RX 7900 GRE', 'AMD_RX_7900_GRE', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_RX_7900_GRE' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 16, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 700, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 300, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / SAPPHIRE / NITRO+ Radeon RX 7900 XTX 24GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NITRO+ Radeon RX 7900 XTX 24GB', '11322-01-40G', 'SAPPHIRE', 'GPU-SAP-RX7900XTX-NITRO-24G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-SAP-RX7900XTX-NITRO-24G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'AMD Radeon RX 7900 XTX', 'AMD_RX_7900_XTX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AMD_RX_7900_XTX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 24, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 800, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 320, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / GALAX / GeForce RTX 3050 EX 6GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GeForce RTX 3050 EX 6GB', 'RTX3050 EX WHITE 6GB', 'GALAX', 'GPU-GALAX-RTX3050-EX-6G', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-GALAX-RTX3050-EX-6G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 3050', 'NVIDIA_RTX_3050', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_3050' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 300, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 180, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- 그래픽카드 / INNO3D / GeForce RTX 3060 TWIN X2 12GB
SET @category_id := 4;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GeForce RTX 3060 TWIN X2 12GB', 'N30602-12D6-119032AH', 'INNO3D', 'GPU-INNO3D-RTX3060-TWIN-12G', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'GPU-INNO3D-RTX3060-TWIN-12G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'NVIDIA GeForce RTX 3060', 'NVIDIA_RTX_3060', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NVIDIA_RTX_3060' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'chipset';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 12, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'GDDR6', 'GDDR6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'GDDR6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'vram_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 550, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'recommended_psu';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 220, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 4
  AND d.spec_key = 'thickness_slots';

-- SSD / Samsung / 990 PRO 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, '990 PRO 1TB', 'MZ-V9P1T0BW', 'Samsung', 'SSD-SAM-990PRO-1T', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-SAM-990PRO-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Samsung / 990 EVO 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, '990 EVO 1TB', 'MZ-V9E1T0BW', 'Samsung', 'SSD-SAM-990EVO-1T', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-SAM-990EVO-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Samsung / 980 PRO 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, '980 PRO 1TB', 'MZ-V8P1T0BW', 'Samsung', 'SSD-SAM-980PRO-1T', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-SAM-980PRO-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Samsung / 870 EVO 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, '870 EVO 1TB', 'MZ-77E1T0BW', 'Samsung', 'SSD-SAM-870EVO-1T', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-SAM-870EVO-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '2.5인치', '2_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '2_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / SK hynix / Platinum P41 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Platinum P41 1TB', 'SHPP41-1000GM-2', 'SK hynix', 'SSD-HYN-P41-1T', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-HYN-P41-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / SK hynix / Gold P31 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Gold P31 1TB', 'SHGP31-1000GM-2', 'SK hynix', 'SSD-HYN-P31-1T', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-HYN-P31-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 3.0 x4 NVMe', 'PCIE_3_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_3_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Western Digital / WD_BLACK SN850X 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD_BLACK SN850X 1TB', 'WDS100T2X0E', 'Western Digital', 'SSD-WD-SN850X-1T', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-WD-SN850X-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Western Digital / WD Blue SN580 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD Blue SN580 1TB', 'WDS100T3B0E', 'Western Digital', 'SSD-WD-SN580-1T', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-WD-SN580-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Western Digital / WD Blue SA510 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD Blue SA510 1TB', 'WDS100T3B0A', 'Western Digital', 'SSD-WD-SA510-1T', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-WD-SA510-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '2.5인치', '2_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '2_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Micron Crucial / P3 Plus 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'P3 Plus 1TB', 'CT1000P3PSSD8', 'Micron Crucial', 'SSD-CRU-P3PLUS-1T', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-CRU-P3PLUS-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Micron Crucial / P5 Plus 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'P5 Plus 1TB', 'CT1000P5PSSD8', 'Micron Crucial', 'SSD-CRU-P5PLUS-1T', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-CRU-P5PLUS-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Micron Crucial / MX500 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'MX500 1TB', 'CT1000MX500SSD1', 'Micron Crucial', 'SSD-CRU-MX500-1T', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-CRU-MX500-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '2.5인치', '2_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '2_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Seagate / FireCuda 530 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'FireCuda 530 1TB', 'ZP1000GM3A013', 'Seagate', 'SSD-SEA-FC530-1T', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-SEA-FC530-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Solidigm / P44 Pro 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'P44 Pro 1TB', 'SSDPFKKW010X7X1', 'Solidigm', 'SSD-SOL-P44PRO-1T', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-SOL-P44PRO-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Kingston / NV2 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NV2 1TB', 'SNV2S/1000G', 'Kingston', 'SSD-KIN-NV2-1T', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-KIN-NV2-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Kingston / KC3000 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'KC3000 1TB', 'SKC3000S/1024G', 'Kingston', 'SSD-KIN-KC3000-1T', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-KIN-KC3000-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / ADATA XPG / S70 Blade 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'S70 Blade 1TB', 'AGAMMIXS70B-1T-CS', 'ADATA XPG', 'SSD-XPG-S70B-1T', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-XPG-S70B-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / TeamGroup / MP44L 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'MP44L 1TB', 'TM8FPK001T0C101', 'TeamGroup', 'SSD-TG-MP44L-1T', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-TG-MP44L-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Lexar / NM790 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NM790 1TB', 'LNM790X001T-RNNNG', 'Lexar', 'SSD-LEX-NM790-1T', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-LEX-NM790-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0 x4 NVMe', 'PCIE_4_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- SSD / Kioxia / Exceria G2 1TB
SET @category_id := 5;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Exceria G2 1TB', 'LRC20Z001TG8', 'Kioxia', 'SSD-KIO-G2-1T', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SSD-KIO-G2-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'M.2 2280', 'M2_2280', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'M2_2280' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 3.0 x4 NVMe', 'PCIE_3_X4_NVME', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_3_X4_NVME' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 5
  AND d.spec_key = 'has_dram';

-- HDD / Seagate / BarraCuda 2TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'BarraCuda 2TB', 'ST2000DM008', 'Seagate', 'HDD-SEA-BC-2T', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-SEA-BC-2T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 7200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'rpm';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Seagate / BarraCuda 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'BarraCuda 4TB', 'ST4000DM004', 'Seagate', 'HDD-SEA-BC-4T', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-SEA-BC-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 5400, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'rpm';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Seagate / IronWolf 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'IronWolf 4TB', 'ST4000VN006', 'Seagate', 'HDD-SEA-IW-4T', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-SEA-IW-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Seagate / IronWolf 8TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'IronWolf 8TB', 'ST8000VN004', 'Seagate', 'HDD-SEA-IW-8T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-SEA-IW-8T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Seagate / SkyHawk 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'SkyHawk 4TB', 'ST4000VX016', 'Seagate', 'HDD-SEA-SH-4T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-SEA-SH-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Seagate / Exos X18 18TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Exos X18 18TB', 'ST18000NM000J', 'Seagate', 'HDD-SEA-EXOS18-18T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-SEA-EXOS18-18T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 18000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Western Digital / WD Blue 1TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD Blue 1TB', 'WD10EZEX', 'Western Digital', 'HDD-WD-BLUE-1T', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-WD-BLUE-1T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 1000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 7200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'rpm';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Western Digital / WD Blue 2TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD Blue 2TB', 'WD20EZBX', 'Western Digital', 'HDD-WD-BLUE-2T', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-WD-BLUE-2T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Western Digital / WD Blue 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD Blue 4TB', 'WD40EZAX', 'Western Digital', 'HDD-WD-BLUE-4T', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-WD-BLUE-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Western Digital / WD Red Plus 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD Red Plus 4TB', 'WD40EFPX', 'Western Digital', 'HDD-WD-REDPLUS-4T', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-WD-REDPLUS-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Western Digital / WD Red Plus 8TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD Red Plus 8TB', 'WD80EFPX', 'Western Digital', 'HDD-WD-REDPLUS-8T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-WD-REDPLUS-8T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Western Digital / WD Purple 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD Purple 4TB', 'WD43PURZ', 'Western Digital', 'HDD-WD-PURPLE-4T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-WD-PURPLE-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Western Digital / WD Gold 10TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD Gold 10TB', 'WD102KRYZ', 'Western Digital', 'HDD-WD-GOLD-10T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-WD-GOLD-10T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 10000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Toshiba / P300 2TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'P300 2TB', 'HDWD120', 'Toshiba', 'HDD-TOS-P300-2T', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-TOS-P300-2T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 7200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'rpm';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Toshiba / P300 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'P300 4TB', 'HDWD240', 'Toshiba', 'HDD-TOS-P300-4T', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-TOS-P300-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Toshiba / N300 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'N300 4TB', 'HDWG440', 'Toshiba', 'HDD-TOS-N300-4T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-TOS-N300-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Toshiba / N300 8TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'N300 8TB', 'HDWG480', 'Toshiba', 'HDD-TOS-N300-8T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-TOS-N300-8T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Toshiba / S300 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'S300 4TB', 'HDWT840', 'Toshiba', 'HDD-TOS-S300-4T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-TOS-S300-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / HGST / Ultrastar 7K6000 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ultrastar 7K6000 4TB', 'HUH728040ALE600', 'HGST', 'HDD-HGST-7K6000-4T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-HGST-7K6000-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- HDD / Western Digital / WD_BLACK 4TB
SET @category_id := 6;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'WD_BLACK 4TB', 'WD4005FZBX', 'Western Digital', 'HDD-WD-BLACK-4T', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HDD-WD-BLACK-4T' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3.5인치', '3_5_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3_5_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA3', 'SATA3', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA3' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 4000, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'capacity';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '확인 불가', 'UNKNOWN', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'UNKNOWN' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 6
  AND d.spec_key = 'recording_type';

-- 파워 / Micronics / Classic II 600W 80PLUS 230V EU
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Classic II 600W 80PLUS 230V EU', 'Classic II 600W', 'Micronics', 'PSU-MIC-CLASSIC2-600', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-MIC-CLASSIC2-600' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 600, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Standard', '80PLUS_STANDARD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_STANDARD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일반 케이블', 'NON_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NON_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Micronics / Classic II 700W 80PLUS 230V EU
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Classic II 700W 80PLUS 230V EU', 'Classic II 700W', 'Micronics', 'PSU-MIC-CLASSIC2-700', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-MIC-CLASSIC2-700' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 700, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Standard', '80PLUS_STANDARD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_STANDARD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일반 케이블', 'NON_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NON_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Micronics / Classic II 750W 80PLUS GOLD 230V EU
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Classic II 750W 80PLUS GOLD 230V EU', 'Classic II 750W GOLD', 'Micronics', 'PSU-MIC-CLASSIC2-750G', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-MIC-CLASSIC2-750G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일반 케이블', 'NON_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NON_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / FSP / HYDRO G PRO 750W 80PLUS Gold
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'HYDRO G PRO 750W 80PLUS Gold', 'HG2-750', 'FSP', 'PSU-FSP-HGPRO-750', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-FSP-HGPRO-750' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / FSP / HYDRO G PRO 850W 80PLUS Gold
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'HYDRO G PRO 850W 80PLUS Gold', 'HG2-850', 'FSP', 'PSU-FSP-HGPRO-850', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-FSP-HGPRO-850' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 850, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Seasonic / FOCUS GX-750 ATX 3.0
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'FOCUS GX-750 ATX 3.0', 'FOCUS GX-750', 'Seasonic', 'PSU-SEA-FOCUS-GX750', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-SEA-FOCUS-GX750' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Seasonic / FOCUS GX-850 ATX 3.0
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'FOCUS GX-850 ATX 3.0', 'FOCUS GX-850', 'Seasonic', 'PSU-SEA-FOCUS-GX850', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-SEA-FOCUS-GX850' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 850, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / SuperFlower / Leadex III Gold 750W
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Leadex III Gold 750W', 'SF-750F14HG', 'SuperFlower', 'PSU-SF-LEADEX3-750', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-SF-LEADEX3-750' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / SuperFlower / Leadex VII Gold 850W ATX 3.0
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Leadex VII Gold 850W ATX 3.0', 'SF-850F14XG', 'SuperFlower', 'PSU-SF-LEADEX7-850', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-SF-LEADEX7-850' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 850, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Corsair / RM750e 80PLUS Gold
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'RM750e 80PLUS Gold', 'CP-9020262', 'Corsair', 'PSU-COR-RM750E', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-COR-RM750E' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Corsair / RM850e 80PLUS Gold
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'RM850e 80PLUS Gold', 'CP-9020263', 'Corsair', 'PSU-COR-RM850E', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-COR-RM850E' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 850, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Antec / NeoECO 850W 80PLUS Gold
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NeoECO 850W 80PLUS Gold', 'NeoECO 850W GOLD', 'Antec', 'PSU-ANT-NEOECO-850', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-ANT-NEOECO-850' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 850, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일반 케이블', 'NON_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NON_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Cooler Master / MWE GOLD 750 V2
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'MWE GOLD 750 V2', 'MPE-7501-ACAAG', 'Cooler Master', 'PSU-CM-MWEGOLD-750V2', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-CM-MWEGOLD-750V2' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일반 케이블', 'NON_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NON_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Thermaltake / Toughpower GF A3 850W
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Toughpower GF A3 850W', 'PS-TPD-0850FNFAGU-L', 'Thermaltake', 'PSU-TT-GFA3-850', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-TT-GFA3-850' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 850, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / MSI / MAG A750GL PCIE5
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'MAG A750GL PCIE5', 'MAG A750GL PCIE5', 'MSI', 'PSU-MSI-A750GL', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-MSI-A750GL' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / MSI / MAG A850GL PCIE5
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'MAG A850GL PCIE5', 'MAG A850GL PCIE5', 'MSI', 'PSU-MSI-A850GL', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-MSI-A850GL' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 850, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / darkFlash / UPMOST 850W 80PLUS Gold
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'UPMOST 850W 80PLUS Gold', 'UPMOST 850G', 'darkFlash', 'PSU-DF-UPMOST-850G', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-DF-UPMOST-850G' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 850, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일반 케이블', 'NON_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NON_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / EVGA / SuperNOVA 750 G6
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'SuperNOVA 750 G6', '220-G6-0750-X1', 'EVGA', 'PSU-EVGA-G6-750', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-EVGA-G6-750' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / be quiet! / Pure Power 12 M 750W
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Pure Power 12 M 750W', 'BN504', 'be quiet!', 'PSU-BQ-PP12M-750', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-BQ-PP12M-750' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 750, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '풀 모듈러', 'FULL_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FULL_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 파워 / Enermax / REVOLUTION D.F. 850W
SET @category_id := 7;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'REVOLUTION D.F. 850W', 'ERF850EWT', 'Enermax', 'PSU-ENR-RDF-850', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'PSU-ENR-RDF-850' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 850, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'rated_output';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'ATX', 'ATX', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'ATX' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '80PLUS Gold', '80PLUS_GOLD', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '80PLUS_GOLD' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'efficiency_rating';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일반 케이블', 'NON_MODULAR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'NON_MODULAR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 7
  AND d.spec_key = 'modularity';

-- 케이스 / darkFlash / DK1000 MESH
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DK1000 MESH', 'DK1000 MESH', 'darkFlash', 'CASE-DF-DK1000-MESH', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-DF-DK1000-MESH' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / darkFlash / DLX21 RGB MESH
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DLX21 RGB MESH', 'DLX21 RGB MESH', 'darkFlash', 'CASE-DF-DLX21-RGB', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-DF-DLX21-RGB' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / 3RSYS / L600 Quiet
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'L600 Quiet', 'L600 Quiet', '3RSYS', 'CASE-3R-L600-Q', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-3R-L600-Q' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / 3RSYS / S406 Quiet GI
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'S406 Quiet GI', 'S406 Quiet GI', '3RSYS', 'CASE-3R-S406-QGI', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-3R-S406-QGI' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / Micronics / Master M60 Mesh
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Master M60 Mesh', 'Master M60 Mesh', 'Micronics', 'CASE-MIC-M60-MESH', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-MIC-M60-MESH' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / ABKO / NCORE G30 트루포스
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NCORE G30 트루포스', 'G30 TRUEFORCE', 'ABKO', 'CASE-ABKO-G30', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-ABKO-G30' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / DAVEN / D6 MESH 강화유리
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'D6 MESH 강화유리', 'D6 MESH', 'DAVEN', 'CASE-DAVEN-D6-MESH', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-DAVEN-D6-MESH' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / Fractal Design / North
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'North', 'North', 'Fractal Design', 'CASE-FD-NORTH', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-FD-NORTH' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / Fractal Design / Meshify 2 Compact
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Meshify 2 Compact', 'Meshify 2 Compact', 'Fractal Design', 'CASE-FD-MESHIFY2-C', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-FD-MESHIFY2-C' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / NZXT / H5 Flow
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'H5 Flow', 'CC-H51FB-01', 'NZXT', 'CASE-NZXT-H5-FLOW', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-NZXT-H5-FLOW' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / NZXT / H7 Flow
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'H7 Flow', 'CM-H71FB-01', 'NZXT', 'CASE-NZXT-H7-FLOW', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-NZXT-H7-FLOW' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 390, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 170, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / LIAN LI / LANCOOL 216
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'LANCOOL 216', 'LANCOOL 216', 'LIAN LI', 'CASE-LL-LANCOOL216', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-LL-LANCOOL216' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 390, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 170, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / LIAN LI / O11 Dynamic EVO
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'O11 Dynamic EVO', 'O11D EVO', 'LIAN LI', 'CASE-LL-O11D-EVO', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-LL-O11D-EVO' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 390, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 170, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / Corsair / 4000D Airflow
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, '4000D Airflow', 'CC-9011200-WW', 'Corsair', 'CASE-COR-4000D-AF', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-COR-4000D-AF' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / Corsair / 5000D Airflow
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, '5000D Airflow', 'CC-9011210-WW', 'Corsair', 'CASE-COR-5000D-AF', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-COR-5000D-AF' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 390, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 170, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / Phanteks / Eclipse G360A
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Eclipse G360A', 'PH-EC360ATG', 'Phanteks', 'CASE-PHA-G360A', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-PHA-G360A' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / Cooler Master / MasterBox NR200P
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'MasterBox NR200P', 'MCB-NR200P', 'Cooler Master', 'CASE-CM-NR200P', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-CM-NR200P' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미니타워', 'MINI_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MINI_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 330, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 155, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / HYTE / Y60
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Y60', 'CS-HYTE-Y60', 'HYTE', 'CASE-HYTE-Y60', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-HYTE-Y60' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 390, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 170, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / be quiet! / Pure Base 500DX
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Pure Base 500DX', 'BGW37', 'be quiet!', 'CASE-BQ-500DX', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-BQ-500DX' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 3, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- 케이스 / Antec / P20C Elite
SET @category_id := 8;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'P20C Elite', 'P20C Elite', 'Antec', 'CASE-ANT-P20C-ELITE', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CASE-ANT-P20C-ELITE' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '미들타워', 'MID_TOWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'MID_TOWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'case_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'ATX / Micro-ATX / Mini-ITX', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'supported_motherboards';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_gpu_length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'max_cpu_cooler_height';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 8
  AND d.spec_key = 'included_fans';

-- CPU 쿨러 / Thermalright / Peerless Assassin 120 SE
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Peerless Assassin 120 SE', 'PA120 SE', 'Thermalright', 'COOLER-TR-PA120SE', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-TR-PA120SE' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / Thermalright / Phantom Spirit 120 SE
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Phantom Spirit 120 SE', 'PS120 SE', 'Thermalright', 'COOLER-TR-PS120SE', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-TR-PS120SE' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / DEEPCOOL / AK400
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'AK400', 'R-AK400-BKNNMN-G-1', 'DEEPCOOL', 'COOLER-DC-AK400', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-DC-AK400' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 155, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / DEEPCOOL / AK620
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'AK620', 'R-AK620-BKNNMT-G', 'DEEPCOOL', 'COOLER-DC-AK620', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-DC-AK620' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / DEEPCOOL / AG400
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'AG400', 'R-AG400-BKNNMN-G-1', 'DEEPCOOL', 'COOLER-DC-AG400', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-DC-AG400' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 155, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / PCCOOLER / PALADIN 400
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PALADIN 400', 'PALADIN 400', 'PCCOOLER', 'COOLER-PCC-PALADIN400', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-PCC-PALADIN400' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 155, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / Cooler Master / Hyper 212 Halo
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Hyper 212 Halo', 'RR-S4KK-20PA-R1', 'Cooler Master', 'COOLER-CM-H212-HALO', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-CM-H212-HALO' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 155, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / Noctua / NH-D15
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NH-D15', 'NH-D15', 'Noctua', 'COOLER-NOC-NHD15', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-NOC-NHD15' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / Noctua / NH-U12A
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NH-U12A', 'NH-U12A', 'Noctua', 'COOLER-NOC-NHU12A', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-NOC-NHU12A' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 155, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / be quiet! / Dark Rock Pro 5
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Dark Rock Pro 5', 'BK036', 'be quiet!', 'COOLER-BQ-DRP5', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-BQ-DRP5' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / ID-COOLING / SE-224-XTS
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'SE-224-XTS', 'SE-224-XTS', 'ID-COOLING', 'COOLER-ID-SE224XTS', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-ID-SE224XTS' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 155, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / JONSBO / CR-1000 EVO
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'CR-1000 EVO', 'CR-1000 EVO', 'JONSBO', 'COOLER-JONSBO-CR1000EVO', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-JONSBO-CR1000EVO' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 155, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / 3RSYS / Socoool RC1800
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Socoool RC1800', 'RC1800', '3RSYS', 'COOLER-3R-RC1800', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-3R-RC1800' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 165, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / 3RSYS / Socoool RC410
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Socoool RC410', 'RC410', '3RSYS', 'COOLER-3R-RC410', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-3R-RC410' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '공랭', 'AIR', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIR' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 155, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'max_height';

-- CPU 쿨러 / ARCTIC / Liquid Freezer III 240
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Liquid Freezer III 240', 'ACFRE00134A', 'ARCTIC', 'COOLER-ARC-LF3-240', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-ARC-LF3-240' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일체형 수랭', 'AIO_LIQUID', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIO_LIQUID' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 240, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'radiator_size';

-- CPU 쿨러 / ARCTIC / Liquid Freezer III 360
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Liquid Freezer III 360', 'ACFRE00136A', 'ARCTIC', 'COOLER-ARC-LF3-360', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-ARC-LF3-360' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일체형 수랭', 'AIO_LIQUID', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIO_LIQUID' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'radiator_size';

-- CPU 쿨러 / DEEPCOOL / LS720
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'LS720', 'R-LS720-BKAMNT-G-1', 'DEEPCOOL', 'COOLER-DC-LS720', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-DC-LS720' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일체형 수랭', 'AIO_LIQUID', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIO_LIQUID' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'radiator_size';

-- CPU 쿨러 / NZXT / Kraken 240
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Kraken 240', 'RL-KN240-B1', 'NZXT', 'COOLER-NZXT-KRAKEN240', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-NZXT-KRAKEN240' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일체형 수랭', 'AIO_LIQUID', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIO_LIQUID' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 240, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'radiator_size';

-- CPU 쿨러 / Corsair / iCUE H100i ELITE
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'iCUE H100i ELITE', 'CW-9060058-WW', 'Corsair', 'COOLER-COR-H100I-ELITE', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-COR-H100I-ELITE' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일체형 수랭', 'AIO_LIQUID', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIO_LIQUID' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 240, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'radiator_size';

-- CPU 쿨러 / LIAN LI / GALAHAD II Trinity 360
SET @category_id := 9;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GALAHAD II Trinity 360', 'GA2T36B', 'LIAN LI', 'COOLER-LL-GA2T-360', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'COOLER-LL-GA2T-360' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '일체형 수랭', 'AIO_LIQUID', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'AIO_LIQUID' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'cooling_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 360, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'radiator_size';

-- 쿨링팬 / ARCTIC / P12 PWM PST
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'P12 PWM PST', 'ACFAN00120A', 'ARCTIC', 'FAN-ARC-P12-PWM-PST', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-ARC-P12-PWM-PST' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4핀 PWM', '4PIN_PWM', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4PIN_PWM' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / ARCTIC / P14 PWM PST
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'P14 PWM PST', 'ACFAN00125A', 'ARCTIC', 'FAN-ARC-P14-PWM-PST', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-ARC-P14-PWM-PST' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 140, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4핀 PWM', '4PIN_PWM', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4PIN_PWM' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / Noctua / NF-A12x25 PWM
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NF-A12x25 PWM', 'NF-A12x25 PWM', 'Noctua', 'FAN-NOC-A12X25-PWM', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-NOC-A12X25-PWM' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4핀 PWM', '4PIN_PWM', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4PIN_PWM' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / Noctua / NF-P12 redux-1700 PWM
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NF-P12 redux-1700 PWM', 'NF-P12 redux-1700 PWM', 'Noctua', 'FAN-NOC-P12-REDUX', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-NOC-P12-REDUX' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4핀 PWM', '4PIN_PWM', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4PIN_PWM' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / be quiet! / Silent Wings 4 120mm PWM
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Silent Wings 4 120mm PWM', 'BL092', 'be quiet!', 'FAN-BQ-SW4-120', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-BQ-SW4-120' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4핀 PWM', '4PIN_PWM', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4PIN_PWM' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / DEEPCOOL / FC120
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'FC120', 'R-FC120-BAMN3-G-1', 'DEEPCOOL', 'FAN-DC-FC120', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-DC-FC120' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4핀 PWM', '4PIN_PWM', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4PIN_PWM' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / Thermalright / TL-C12C
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'TL-C12C', 'TL-C12C', 'Thermalright', 'FAN-TR-TLC12C', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-TR-TLC12C' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4핀 PWM', '4PIN_PWM', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4PIN_PWM' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / darkFlash / C6M RGB
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'C6M RGB', 'C6M RGB', 'darkFlash', 'FAN-DF-C6M-RGB', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-DF-C6M-RGB' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3핀 DC', '3PIN_DC', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3PIN_DC' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / 3RSYS / Socoool FAN 120
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Socoool FAN 120', 'Socoool 120', '3RSYS', 'FAN-3R-SOCOOL120', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-3R-SOCOOL120' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3핀 DC', '3PIN_DC', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3PIN_DC' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / Corsair / AF120 ELITE
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'AF120 ELITE', 'CO-9050140-WW', 'Corsair', 'FAN-COR-AF120-ELITE', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-COR-AF120-ELITE' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4핀 PWM', '4PIN_PWM', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4PIN_PWM' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / LIAN LI / UNI FAN SL-INF 120
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'UNI FAN SL-INF 120', 'UF-SLIN120-1B', 'LIAN LI', 'FAN-LL-SLINF120', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-LL-SLINF120' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '3핀 DC', '3PIN_DC', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '3PIN_DC' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- 쿨링팬 / Cooler Master / SickleFlow 120 ARGB
SET @category_id := 10;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'SickleFlow 120 ARGB', 'MFX-B2DN-18NPA-R1', 'Cooler Master', 'FAN-CM-SF120-ARGB', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'FAN-CM-SF120-ARGB' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'fan_size';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 25, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'thickness';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4핀 PWM', '4PIN_PWM', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4PIN_PWM' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'connection_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = @category_id
  AND d.spec_key = 'has_rgb';

-- ODD / LG Electronics / Slim Portable DVD Writer
SET @category_id := 17;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Slim Portable DVD Writer', 'GP62NW60', 'LG Electronics', 'ODD-LG-GP62NW60', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'ODD-LG-GP62NW60' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DVD-RW', 'DVD_RW', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DVD_RW' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'odd_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 2.0', 'USB_2_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_2_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'is_external';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '외장형', 'EXTERNAL', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'EXTERNAL' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'DVD / CD', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'supported_discs';

-- ODD / LG Electronics / Slim Portable DVD Writer
SET @category_id := 17;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Slim Portable DVD Writer', 'GP62NB60', 'LG Electronics', 'ODD-LG-GP62NB60', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'ODD-LG-GP62NB60' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DVD-RW', 'DVD_RW', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DVD_RW' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'odd_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 2.0', 'USB_2_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_2_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'is_external';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '외장형', 'EXTERNAL', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'EXTERNAL' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'DVD / CD', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'supported_discs';

-- ODD / ASUS / External Slim DVD-RW
SET @category_id := 17;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'External Slim DVD-RW', 'SDRW-08D2S-U', 'ASUS', 'ODD-ASUS-SDRW08D2S', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'ODD-ASUS-SDRW08D2S' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DVD-RW', 'DVD_RW', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DVD_RW' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'odd_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 2.0', 'USB_2_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_2_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'is_external';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '외장형', 'EXTERNAL', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'EXTERNAL' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'DVD / CD', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'supported_discs';

-- ODD / ASUS / Internal DVD Writer
SET @category_id := 17;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Internal DVD Writer', 'DRW-24D5MT', 'ASUS', 'ODD-ASUS-DRW24D5MT', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'ODD-ASUS-DRW24D5MT' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DVD-RW', 'DVD_RW', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DVD_RW' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'odd_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA', 'SATA', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'is_external';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '5.25인치', '5_25_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '5_25_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'DVD / CD', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'supported_discs';

-- ODD / Hitachi-LG Data Storage / Internal DVD Writer
SET @category_id := 17;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Internal DVD Writer', 'GH24NSD5', 'Hitachi-LG Data Storage', 'ODD-HLDS-GH24NSD5', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'ODD-HLDS-GH24NSD5' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'DVD-RW', 'DVD_RW', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DVD_RW' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'odd_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA', 'SATA', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'is_external';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '5.25인치', '5_25_INCH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '5_25_INCH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'DVD / CD', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'supported_discs';

-- ODD / Pioneer / Portable Blu-ray/DVD Writer
SET @category_id := 17;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Portable Blu-ray/DVD Writer', 'BDR-XD08', 'Pioneer', 'ODD-PIO-BDRXD08', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'ODD-PIO-BDRXD08' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Blu-ray Writer', 'BLU_RAY_WRITER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'BLU_RAY_WRITER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'odd_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 2.0', 'USB_2_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_2_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'is_external';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '외장형', 'EXTERNAL', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'EXTERNAL' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'form_factor';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, 'Blu-ray / DVD / CD', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 17
  AND d.spec_key = 'supported_discs';

-- 케이블류 / NEXT / SATA3 6Gbps Cable 0.5m
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'SATA3 6Gbps Cable 0.5m', 'NEXT-SATA3-05', 'NEXT', 'CAB-NEXT-SATA3-05', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-NEXT-SATA3-05' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 케이블', 'SATA_CABLE', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_CABLE' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 0.5, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'length';

-- 케이블류 / Coms / SATA3 Lock Cable 0.5m
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'SATA3 Lock Cable 0.5m', 'SATA3 Lock 0.5m', 'Coms', 'CAB-COMS-SATA3-LOCK', 0.00, 5, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-COMS-SATA3-LOCK' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 케이블', 'SATA_CABLE', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_CABLE' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 0.5, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'length';

-- 케이블류 / CableMate / SATA Power Y Splitter
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'SATA Power Y Splitter', 'SATA Power Y', 'CableMate', 'CAB-CM-SATA-PWR-Y', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-CM-SATA-PWR-Y' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '전원 연장 케이블', 'POWER_EXTENSION', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'POWER_EXTENSION' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

-- 케이블류 / CableMate / PCIe 8-pin Extension Cable
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PCIe 8-pin Extension Cable', 'PCIe 8-pin Extension', 'CableMate', 'CAB-CM-PCIE8-EXT', 0.00, 3, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-CM-PCIE8-EXT' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '전원 연장 케이블', 'POWER_EXTENSION', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'POWER_EXTENSION' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

-- 케이블류 / AsiaHorse / 24-pin ARGB PSU Extension Cable
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, '24-pin ARGB PSU Extension Cable', '24-pin ARGB Extension', 'AsiaHorse', 'CAB-AH-24PIN-ARGB', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-AH-24PIN-ARGB' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '전원 연장 케이블', 'POWER_EXTENSION', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'POWER_EXTENSION' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

-- 케이블류 / EZDIY-FAB / PSU Extension Cable Kit
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PSU Extension Cable Kit', 'Sleeved Cable Kit', 'EZDIY-FAB', 'CAB-EZDIY-PSU-KIT', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-EZDIY-PSU-KIT' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '전원 연장 케이블', 'POWER_EXTENSION', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'POWER_EXTENSION' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

-- 케이블류 / NEXI / DisplayPort 1.4 Cable 2m
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DisplayPort 1.4 Cable 2m', 'NX-DP142M', 'NEXI', 'CAB-NEXI-DP14-2M', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-NEXI-DP14-2M' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '디스플레이 케이블', 'DISPLAY_CABLE', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DISPLAY_CABLE' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'length';

-- 케이블류 / Cable Matters / HDMI 2.1 8K Cable 2m
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'HDMI 2.1 8K Cable 2m', 'HDMI 2.1 2m', 'Cable Matters', 'CAB-CM-HDMI21-2M', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-CM-HDMI21-2M' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '디스플레이 케이블', 'DISPLAY_CABLE', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'DISPLAY_CABLE' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 2, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'length';

-- 케이블류 / NEXT / USB 3.0 Extension Cable
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'USB 3.0 Extension Cable', 'NEXT-USB30-EXT', 'NEXT', 'CAB-NEXT-USB30-EXT', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-NEXT-USB30-EXT' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 케이블', 'USB_CABLE', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_CABLE' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

-- 케이블류 / Coms / USB-C to USB-A Adapter Cable
SET @category_id := 18;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'USB-C to USB-A Adapter Cable', 'USB-C to A', 'Coms', 'CAB-COMS-USBC-A', 0.00, 4, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAB-COMS-USBC-A' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 케이블', 'USB_CABLE', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_CABLE' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 18
  AND d.spec_key = 'cable_type';

-- 캡처카드 / Elgato / Game Capture HD60 X
SET @category_id := 16;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Game Capture HD60 X', 'HD60 X', 'Elgato', 'CAP-ELGATO-HD60X', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAP-ELGATO-HD60X' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 3.0', 'USB_3_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_3_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 60Hz', '4K_60', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_60' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '1080p 60fps', '1080P_60FPS', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '1080P_60FPS' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'hdr_support';

-- 캡처카드 / Elgato / 4K60 Pro MK.2
SET @category_id := 16;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, '4K60 Pro MK.2', '4K60 Pro MK.2', 'Elgato', 'CAP-ELGATO-4K60PRO-MK2', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAP-ELGATO-4K60PRO-MK2' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x4', 'PCIE_X4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 60Hz', '4K_60', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_60' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 60fps', '4K_60FPS', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_60FPS' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'hdr_support';

-- 캡처카드 / AVerMedia / Live Gamer MINI
SET @category_id := 16;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Live Gamer MINI', 'GC311', 'AVerMedia', 'CAP-AVM-GC311', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAP-AVM-GC311' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 3.0', 'USB_3_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_3_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '1080p 60Hz', '1080P_60', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '1080P_60' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '1080p 60fps', '1080P_60FPS', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '1080P_60FPS' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'hdr_support';

-- 캡처카드 / AVerMedia / Live Gamer EXTREME 3
SET @category_id := 16;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Live Gamer EXTREME 3', 'GC551G2', 'AVerMedia', 'CAP-AVM-GC551G2', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAP-AVM-GC551G2' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 3.0', 'USB_3_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_3_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 60Hz', '4K_60', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_60' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '1080p 60fps', '1080P_60FPS', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '1080P_60FPS' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'hdr_support';

-- 캡처카드 / AVerMedia / Live Gamer 4K
SET @category_id := 16;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Live Gamer 4K', 'GC573', 'AVerMedia', 'CAP-AVM-GC573', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAP-AVM-GC573' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x4', 'PCIE_X4', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X4' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 60Hz', '4K_60', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_60' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 60fps', '4K_60FPS', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_60FPS' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'hdr_support';

-- 캡처카드 / Razer / Ripsaw HD
SET @category_id := 16;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ripsaw HD', 'RZ20-02850100', 'Razer', 'CAP-RAZER-RIPSAWHD', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAP-RAZER-RIPSAWHD' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 3.0', 'USB_3_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_3_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 60Hz', '4K_60', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_60' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '1080p 60fps', '1080P_60FPS', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '1080P_60FPS' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'hdr_support';

-- 캡처카드 / ASUS / TUF Gaming Capture Box
SET @category_id := 16;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'TUF Gaming Capture Box', 'CU4K30', 'ASUS', 'CAP-ASUS-CU4K30', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAP-ASUS-CU4K30' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB-C', 'USB_C', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_C' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 60Hz', '4K_60', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_60' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 30fps', '4K_30FPS', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_30FPS' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'hdr_support';

-- 캡처카드 / EVGA / XR1 Lite
SET @category_id := 16;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'XR1 Lite', '141-U1-CB20-LR', 'EVGA', 'CAP-EVGA-XR1-LITE', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'CAP-EVGA-XR1-LITE' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'USB 3.0', 'USB_3_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'USB_3_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '4K 60Hz', '4K_60', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '4K_60' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_passthrough';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '1080p 60fps', '1080P_60FPS', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '1080P_60FPS' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'max_recording';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 16
  AND d.spec_key = 'hdr_support';

-- 사운드카드 / Creative / Sound Blaster Audigy FX
SET @category_id := 15;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Sound Blaster Audigy FX', 'SB1570', 'Creative', 'SOUND-CRE-AUDIGY-FX', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SOUND-CRE-AUDIGY-FX' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '5.1채널', '5_1CH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '5_1CH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'channel_support';

-- 사운드카드 / Creative / Sound BlasterX AE-5 Plus
SET @category_id := 15;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Sound BlasterX AE-5 Plus', 'SB1740', 'Creative', 'SOUND-CRE-AE5PLUS', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SOUND-CRE-AE5PLUS' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '5.1채널', '5_1CH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '5_1CH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'channel_support';

-- 사운드카드 / Creative / Sound Blaster Z SE
SET @category_id := 15;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Sound Blaster Z SE', 'SB1500 SE', 'Creative', 'SOUND-CRE-Z-SE', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SOUND-CRE-Z-SE' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '5.1채널', '5_1CH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '5_1CH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'channel_support';

-- 사운드카드 / ASUS / Xonar SE
SET @category_id := 15;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Xonar SE', 'XONAR SE', 'ASUS', 'SOUND-ASUS-XONAR-SE', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SOUND-ASUS-XONAR-SE' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '5.1채널', '5_1CH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '5_1CH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'channel_support';

-- 사운드카드 / ASUS / Xonar AE
SET @category_id := 15;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Xonar AE', 'XONAR AE', 'ASUS', 'SOUND-ASUS-XONAR-AE', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SOUND-ASUS-XONAR-AE' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '7.1채널', '7_1CH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '7_1CH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'channel_support';

-- 사운드카드 / EVGA / NU Audio Pro
SET @category_id := 15;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'NU Audio Pro', '712-P1-AN11-KR', 'EVGA', 'SOUND-EVGA-NU-AUDIO-PRO', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SOUND-EVGA-NU-AUDIO-PRO' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '5.1채널', '5_1CH', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = '5_1CH' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'channel_support';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, '고음질 DAC', NULL, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 15
  AND d.spec_key = 'dac_chip';

-- 무선 랜카드 / ASUS / PCE-AX3000
SET @category_id := 14;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PCE-AX3000', 'PCE-AX3000', 'ASUS', 'WIFI-ASUS-PCE-AX3000', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'WIFI-ASUS-PCE-AX3000' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Wi-Fi 6', 'WIFI_6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'WIFI_6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Bluetooth 5.x', 'BT_5_X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'BT_5_X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'bluetooth_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'dual_band_support';

-- 무선 랜카드 / ASUS / PCE-AXE5400
SET @category_id := 14;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PCE-AXE5400', 'PCE-AXE5400', 'ASUS', 'WIFI-ASUS-PCE-AXE5400', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'WIFI-ASUS-PCE-AXE5400' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Wi-Fi 6E', 'WIFI_6E', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'WIFI_6E' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Bluetooth 5.x', 'BT_5_X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'BT_5_X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'bluetooth_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'dual_band_support';

-- 무선 랜카드 / TP-Link / Archer TX3000E
SET @category_id := 14;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Archer TX3000E', 'Archer TX3000E', 'TP-Link', 'WIFI-TPL-TX3000E', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'WIFI-TPL-TX3000E' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Wi-Fi 6', 'WIFI_6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'WIFI_6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Bluetooth 5.0', 'BT_5_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'BT_5_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'bluetooth_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'dual_band_support';

-- 무선 랜카드 / TP-Link / Archer T4E
SET @category_id := 14;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Archer T4E', 'Archer T4E', 'TP-Link', 'WIFI-TPL-T4E', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'WIFI-TPL-T4E' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Wi-Fi 5', 'WIFI_5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'WIFI_5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'dual_band_support';

-- 무선 랜카드 / ipTIME / AX3000PX
SET @category_id := 14;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'AX3000PX', 'AX3000PX', 'ipTIME', 'WIFI-IPTIME-AX3000PX', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'WIFI-IPTIME-AX3000PX' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Wi-Fi 6', 'WIFI_6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'WIFI_6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Bluetooth 5.x', 'BT_5_X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'BT_5_X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'bluetooth_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'dual_band_support';

-- 무선 랜카드 / ipTIME / A3000PX
SET @category_id := 14;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'A3000PX', 'A3000PX', 'ipTIME', 'WIFI-IPTIME-A3000PX', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'WIFI-IPTIME-A3000PX' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Wi-Fi 5', 'WIFI_5', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'WIFI_5' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'dual_band_support';

-- 무선 랜카드 / Intel / Wi-Fi 6 AX200 PCIe Kit
SET @category_id := 14;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Wi-Fi 6 AX200 PCIe Kit', 'AX200 PCIe Kit', 'Intel', 'WIFI-INT-AX200-KIT', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'WIFI-INT-AX200-KIT' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Wi-Fi 6', 'WIFI_6', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'WIFI_6' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Bluetooth 5.x', 'BT_5_X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'BT_5_X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'bluetooth_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'dual_band_support';

-- 무선 랜카드 / Intel / Wi-Fi 6E AX210 PCIe Kit
SET @category_id := 14;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Wi-Fi 6E AX210 PCIe Kit', 'AX210 PCIe Kit', 'Intel', 'WIFI-INT-AX210-KIT', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'WIFI-INT-AX210-KIT' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe x1', 'PCIE_X1', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_X1' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'interface';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Wi-Fi 6E', 'WIFI_6E', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'WIFI_6E' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'wifi_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'Bluetooth 5.x', 'BT_5_X', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'BT_5_X' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'bluetooth_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 14
  AND d.spec_key = 'dual_band_support';

-- 팬 허브/컨트롤러 / DEEPCOOL / FH-10 Fan Hub
SET @category_id := 13;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'FH-10 Fan Hub', 'FH-10', 'DEEPCOOL', 'HUB-DC-FH10', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HUB-DC-FH10' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '팬 허브', 'FAN_HUB', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FAN_HUB' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 10, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'port_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 전원', 'SATA_POWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_POWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'power_connector';

-- 팬 허브/컨트롤러 / ARCTIC / Case Fan Hub
SET @category_id := 13;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Case Fan Hub', 'ACFAN00175A', 'ARCTIC', 'HUB-ARC-CASEFAN', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HUB-ARC-CASEFAN' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '팬 허브', 'FAN_HUB', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FAN_HUB' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 10, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'port_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 전원', 'SATA_POWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_POWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'power_connector';

-- 팬 허브/컨트롤러 / Thermaltake / Commander FP
SET @category_id := 13;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Commander FP', 'AC-023-AN1NAN-A1', 'Thermaltake', 'HUB-TT-COMMANDER-FP', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HUB-TT-COMMANDER-FP' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '팬 허브', 'FAN_HUB', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FAN_HUB' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 10, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'port_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 전원', 'SATA_POWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_POWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'power_connector';

-- 팬 허브/컨트롤러 / Phanteks / Universal Fan Controller
SET @category_id := 13;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Universal Fan Controller', 'PH-PWHUB_02', 'Phanteks', 'HUB-PHA-FANCTRL', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HUB-PHA-FANCTRL' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '팬 허브', 'FAN_HUB', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FAN_HUB' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'port_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 전원', 'SATA_POWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_POWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'power_connector';

-- 팬 허브/컨트롤러 / NZXT / RGB & Fan Controller
SET @category_id := 13;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'RGB & Fan Controller', 'AC-2RGBC-B1', 'NZXT', 'HUB-NZXT-RGB-FAN', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HUB-NZXT-RGB-FAN' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PWM+ARGB 허브', 'PWM_ARGB_HUB', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PWM_ARGB_HUB' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'port_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 전원', 'SATA_POWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_POWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'power_connector';

-- 팬 허브/컨트롤러 / Corsair / iCUE Commander CORE XT
SET @category_id := 13;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'iCUE Commander CORE XT', 'CL-9011112-WW', 'Corsair', 'HUB-COR-CCORE-XT', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HUB-COR-CCORE-XT' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PWM+ARGB 허브', 'PWM_ARGB_HUB', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PWM_ARGB_HUB' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 6, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'port_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 전원', 'SATA_POWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_POWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'power_connector';

-- 팬 허브/컨트롤러 / darkFlash / RC2 ARGB PWM HUB
SET @category_id := 13;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'RC2 ARGB PWM HUB', 'RC2 ARGB PWM HUB', 'darkFlash', 'HUB-DF-RC2-ARGB', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HUB-DF-RC2-ARGB' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PWM+ARGB 허브', 'PWM_ARGB_HUB', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PWM_ARGB_HUB' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 10, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'port_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 전원', 'SATA_POWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_POWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'power_connector';

-- 팬 허브/컨트롤러 / SilverStone / CPF04 PWM Fan Hub
SET @category_id := 13;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'CPF04 PWM Fan Hub', 'CPF04', 'SilverStone', 'HUB-SST-CPF04', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'HUB-SST-CPF04' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '팬 허브', 'FAN_HUB', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'FAN_HUB' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'hub_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 8, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'port_count';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'SATA 전원', 'SATA_POWER', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SATA_POWER' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 13
  AND d.spec_key = 'power_connector';

-- 라이저 케이블 / LIAN LI / PCIe 4.0 Riser Cable
SET @category_id := 12;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PCIe 4.0 Riser Cable', 'PW-PCI-4-60', 'LIAN LI', 'RISER-LL-PCIE4-60', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RISER-LL-PCIE4-60' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0', 'PCIE_4_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'pcie_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 600, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '직선형', 'STRAIGHT', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'STRAIGHT' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'angle';

-- 라이저 케이블 / Cooler Master / Vertical Graphics Card Holder Kit V3
SET @category_id := 12;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Vertical Graphics Card Holder Kit V3', 'MCA-U000R-KFVK03', 'Cooler Master', 'RISER-CM-V3-KIT', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RISER-CM-V3-KIT' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0', 'PCIE_4_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'pcie_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '직선형', 'STRAIGHT', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'STRAIGHT' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'angle';

-- 라이저 케이블 / Thermaltake / TT Premium PCI-E 4.0 Extender
SET @category_id := 12;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'TT Premium PCI-E 4.0 Extender', 'AC-059-CO1OTN-C1', 'Thermaltake', 'RISER-TT-PCIE4', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RISER-TT-PCIE4' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0', 'PCIE_4_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'pcie_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '직선형', 'STRAIGHT', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'STRAIGHT' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'angle';

-- 라이저 케이블 / Phanteks / Premium PCIe 4.0 x16 Riser Cable
SET @category_id := 12;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Premium PCIe 4.0 x16 Riser Cable', 'PH-CBRS4.0', 'Phanteks', 'RISER-PHA-PCIE4', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RISER-PHA-PCIE4' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0', 'PCIE_4_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'pcie_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '직선형', 'STRAIGHT', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'STRAIGHT' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'angle';

-- 라이저 케이블 / LINKUP / Ultra PCIe 4.0 X16 Riser Cable
SET @category_id := 12;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'Ultra PCIe 4.0 X16 Riser Cable', 'PCIE4EXT11SR-020', 'LINKUP', 'RISER-LINKUP-PCIE4', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RISER-LINKUP-PCIE4' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0', 'PCIE_4_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'pcie_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '직선형', 'STRAIGHT', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'STRAIGHT' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'angle';

-- 라이저 케이블 / darkFlash / PCIe 4.0 x16 Riser Cable
SET @category_id := 12;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'PCIe 4.0 x16 Riser Cable', 'PCIe 4.0 Riser', 'darkFlash', 'RISER-DF-PCIE4', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'RISER-DF-PCIE4' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, 'PCIe 4.0', 'PCIE_4_0', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'PCIE_4_0' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'pcie_version';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 200, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'length';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '직선형', 'STRAIGHT', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'STRAIGHT' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 12
  AND d.spec_key = 'angle';

-- 그래픽카드 지지대 / darkFlash / DL240 ARGB GPU Support
SET @category_id := 11;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'DL240 ARGB GPU Support', 'DL240 ARGB', 'darkFlash', 'SUPPORT-DF-DL240-ARGB', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SUPPORT-DF-DL240-ARGB' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '수직 지지대', 'VERTICAL', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'VERTICAL' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'support_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 70, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_min';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_max';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'has_rgb';

-- 그래픽카드 지지대 / 3RSYS / ICEAGE G5 GPU Support
SET @category_id := 11;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'ICEAGE G5 GPU Support', 'ICEAGE G5', '3RSYS', 'SUPPORT-3R-ICEAGE-G5', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SUPPORT-3R-ICEAGE-G5' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '수직 지지대', 'VERTICAL', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'VERTICAL' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'support_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 70, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_min';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_max';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'has_rgb';

-- 그래픽카드 지지대 / ABKO / SUITMASTER VGA Support
SET @category_id := 11;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'SUITMASTER VGA Support', 'SUITMASTER VGA Support', 'ABKO', 'SUPPORT-ABKO-SUITMASTER', 0.00, 2, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SUPPORT-ABKO-SUITMASTER' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '수직 지지대', 'VERTICAL', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'VERTICAL' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'support_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 70, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_min';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_max';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'has_rgb';

-- 그래픽카드 지지대 / JONSBO / VC-20 ARGB GPU Holder
SET @category_id := 11;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'VC-20 ARGB GPU Holder', 'VC-20 ARGB', 'JONSBO', 'SUPPORT-JONSBO-VC20', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SUPPORT-JONSBO-VC20' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '수직 지지대', 'VERTICAL', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'VERTICAL' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'support_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 70, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_min';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_max';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'has_rgb';

-- 그래픽카드 지지대 / Cooler Master / ELV8 Universal ARGB GPU Holder
SET @category_id := 11;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'ELV8 Universal ARGB GPU Holder', 'MCA-U000R-GSBTG-00', 'Cooler Master', 'SUPPORT-CM-ELV8', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SUPPORT-CM-ELV8' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '수직 지지대', 'VERTICAL', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'VERTICAL' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'support_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 70, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_min';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_max';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, TRUE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'has_rgb';

-- 그래픽카드 지지대 / LIAN LI / GB-001 Anti-Sag Bracket
SET @category_id := 11;
INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, estimated_price, safe_quantity, active, created_at, updated_at)
VALUES (@company_id, @category_id, @created_by, 'GB-001 Anti-Sag Bracket', 'GB-001', 'LIAN LI', 'SUPPORT-LL-GB001', 0.00, 1, TRUE, NOW(6), NOW(6))
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    part_name = VALUES(part_name),
    model_name = VALUES(model_name),
    manufacturer = VALUES(manufacturer),
    safe_quantity = VALUES(safe_quantity),
    active = TRUE,
    updated_at = NOW(6);
SET @part_id := (SELECT part_id FROM tb_pc_part WHERE company_id = @company_id AND part_code = 'SUPPORT-LL-GB001' LIMIT 1);
DELETE FROM tb_part_spec_value WHERE company_id = @company_id AND part_id = @part_id;
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, NULL, o.option_id, '나사 고정', 'SCREW_FIXED', NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
LEFT JOIN tb_part_spec_option o ON o.spec_definition_id = d.spec_definition_id AND o.option_value = 'SCREW_FIXED' AND o.active = TRUE
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'support_type';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 70, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_min';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, 120, NULL, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'height_max';
INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_text, value_number, value_boolean, selected_option_id, selected_option_label_snapshot, selected_option_value_snapshot, created_at, updated_at)
SELECT @company_id, @part_id, d.spec_definition_id, NULL, NULL, FALSE, NULL, NULL, NULL, NOW(6), NOW(6)
FROM tb_part_spec_definition d
JOIN tb_part_category c ON c.company_id = d.company_id AND c.category_id = d.category_id
WHERE @part_id IS NOT NULL
  AND d.company_id = @company_id
  AND d.category_id = 11
  AND d.spec_key = 'has_rgb';

COMMIT;

-- 품목 후보 250건, SELECT 선택지 84건, 사양값 1107건 생성 기준.
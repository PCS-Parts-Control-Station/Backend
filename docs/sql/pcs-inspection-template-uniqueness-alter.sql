ALTER TABLE tb_inspection_template_item
    ADD UNIQUE INDEX IF NOT EXISTS uk_inspection_template_item_name (template_id, item_name);

ALTER TABLE tb_inspection_template_item_option
    ADD UNIQUE INDEX IF NOT EXISTS uk_inspection_template_item_option_label (item_id, option_label);

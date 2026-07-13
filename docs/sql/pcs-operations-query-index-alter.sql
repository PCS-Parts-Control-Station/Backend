CREATE INDEX IF NOT EXISTS idx_stock_document_company_created
    ON tb_stock_document (company_id, created_at DESC, document_id DESC);

CREATE INDEX IF NOT EXISTS idx_inspection_company_date
    ON tb_inspection (company_id, inspected_at DESC, inspection_id DESC);

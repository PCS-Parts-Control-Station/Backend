USE pcs_db;

ALTER TABLE tb_stock_document
    DROP INDEX uk_stock_document_company_document_no,
    ADD CONSTRAINT uk_stock_document_document_no UNIQUE (document_no);

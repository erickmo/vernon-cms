-- Rename indexes back
ALTER INDEX idx_data_fields_data_type_id RENAME TO idx_domain_fields_domain_id;
ALTER INDEX idx_data_fields_sort_order RENAME TO idx_domain_fields_sort_order;
ALTER INDEX idx_data_records_data_type_id RENAME TO idx_domain_records_domain_id;
ALTER INDEX idx_data_records_data_slug RENAME TO idx_domain_records_domain_slug;
ALTER INDEX idx_data_records_data RENAME TO idx_domain_records_data;

-- Rename columns back in data_fields
ALTER TABLE data_fields RENAME COLUMN related_data_id TO related_domain_id;
ALTER TABLE data_fields RENAME COLUMN related_data_slug TO related_domain_slug;
ALTER TABLE data_fields RENAME COLUMN data_type_id TO domain_id;

-- Rename columns back in data_records
ALTER TABLE data_records RENAME COLUMN data_slug TO domain_slug;
ALTER TABLE data_records RENAME COLUMN data_type_id TO domain_id;

-- Rename tables back
ALTER TABLE data_fields RENAME TO domain_fields;
ALTER TABLE data_types RENAME TO domains;
ALTER TABLE data_records RENAME TO domain_records;

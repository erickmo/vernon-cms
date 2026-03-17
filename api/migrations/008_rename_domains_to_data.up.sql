-- Rename domain_records to data_records
ALTER TABLE domain_records RENAME TO data_records;

-- Rename domains to data_types
ALTER TABLE domains RENAME TO data_types;

-- Rename domain_fields to data_fields
ALTER TABLE domain_fields RENAME TO data_fields;

-- Rename domain_id column to data_type_id in data_records
ALTER TABLE data_records RENAME COLUMN domain_id TO data_type_id;

-- Rename domain_slug column to data_slug in data_records
ALTER TABLE data_records RENAME COLUMN domain_slug TO data_slug;

-- Rename domain_id column to data_type_id in data_fields
ALTER TABLE data_fields RENAME COLUMN domain_id TO data_type_id;

-- Rename related_domain_id and related_domain_slug in data_fields
ALTER TABLE data_fields RENAME COLUMN related_domain_id TO related_data_id;
ALTER TABLE data_fields RENAME COLUMN related_domain_slug TO related_data_slug;

-- Rename indexes
ALTER INDEX idx_domain_fields_domain_id RENAME TO idx_data_fields_data_type_id;
ALTER INDEX idx_domain_fields_sort_order RENAME TO idx_data_fields_sort_order;
ALTER INDEX idx_domain_records_domain_id RENAME TO idx_data_records_data_type_id;
ALTER INDEX idx_domain_records_domain_slug RENAME TO idx_data_records_data_slug;
ALTER INDEX idx_domain_records_data RENAME TO idx_data_records_data;

-- Remove site_id indexes
DROP INDEX IF EXISTS idx_pages_site_id;
DROP INDEX IF EXISTS idx_content_categories_site_id;
DROP INDEX IF EXISTS idx_contents_site_id;
DROP INDEX IF EXISTS idx_domains_site_id;
DROP INDEX IF EXISTS idx_domain_records_site_id;

DROP INDEX IF EXISTS idx_pages_site_slug;
DROP INDEX IF EXISTS idx_content_categories_site_slug;
DROP INDEX IF EXISTS idx_contents_site_slug;
DROP INDEX IF EXISTS idx_domains_site_slug;

-- Remove site_id columns
ALTER TABLE pages DROP COLUMN IF EXISTS site_id;
ALTER TABLE content_categories DROP COLUMN IF EXISTS site_id;
ALTER TABLE contents DROP COLUMN IF EXISTS site_id;
ALTER TABLE domains DROP COLUMN IF EXISTS site_id;
ALTER TABLE domain_records DROP COLUMN IF EXISTS site_id;

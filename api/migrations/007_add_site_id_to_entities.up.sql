-- Create default site if users exist
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM users LIMIT 1) THEN
        INSERT INTO sites (id, name, slug, custom_domain, owner_id)
        SELECT '00000000-0000-0000-0000-000000000001'::uuid, 'Default Site', 'default', 'localhost',
               (SELECT id FROM users ORDER BY created_at ASC LIMIT 1)
        ON CONFLICT DO NOTHING;

        -- Add all existing users as admin members of default site
        INSERT INTO site_members (id, site_id, user_id, role)
        SELECT gen_random_uuid(), '00000000-0000-0000-0000-000000000001'::uuid, id, 'admin'
        FROM users
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- Add site_id columns (nullable first for backfill)
ALTER TABLE pages ADD COLUMN IF NOT EXISTS site_id UUID REFERENCES sites(id) ON DELETE CASCADE;
ALTER TABLE content_categories ADD COLUMN IF NOT EXISTS site_id UUID REFERENCES sites(id) ON DELETE CASCADE;
ALTER TABLE contents ADD COLUMN IF NOT EXISTS site_id UUID REFERENCES sites(id) ON DELETE CASCADE;
ALTER TABLE domains ADD COLUMN IF NOT EXISTS site_id UUID REFERENCES sites(id) ON DELETE CASCADE;
ALTER TABLE domain_records ADD COLUMN IF NOT EXISTS site_id UUID REFERENCES sites(id) ON DELETE CASCADE;

-- Backfill existing data with default site
UPDATE pages SET site_id = '00000000-0000-0000-0000-000000000001' WHERE site_id IS NULL;
UPDATE content_categories SET site_id = '00000000-0000-0000-0000-000000000001' WHERE site_id IS NULL;
UPDATE contents SET site_id = '00000000-0000-0000-0000-000000000001' WHERE site_id IS NULL;
UPDATE domains SET site_id = '00000000-0000-0000-0000-000000000001' WHERE site_id IS NULL;
UPDATE domain_records SET site_id = '00000000-0000-0000-0000-000000000001' WHERE site_id IS NULL;

-- Set NOT NULL constraints
ALTER TABLE pages ALTER COLUMN site_id SET NOT NULL;
ALTER TABLE content_categories ALTER COLUMN site_id SET NOT NULL;
ALTER TABLE contents ALTER COLUMN site_id SET NOT NULL;
ALTER TABLE domains ALTER COLUMN site_id SET NOT NULL;
ALTER TABLE domain_records ALTER COLUMN site_id SET NOT NULL;

-- Drop old unique constraints that don't include site_id
ALTER TABLE pages DROP CONSTRAINT IF EXISTS pages_slug_key;
DROP INDEX IF EXISTS idx_pages_slug;

-- Recreate slug unique constraints scoped to site
CREATE UNIQUE INDEX IF NOT EXISTS idx_pages_site_slug ON pages(site_id, slug);
CREATE UNIQUE INDEX IF NOT EXISTS idx_content_categories_site_slug ON content_categories(site_id, slug);
CREATE UNIQUE INDEX IF NOT EXISTS idx_contents_site_slug ON contents(site_id, slug);
CREATE UNIQUE INDEX IF NOT EXISTS idx_domains_site_slug ON domains(site_id, slug);

-- Add site_id indexes
CREATE INDEX IF NOT EXISTS idx_pages_site_id ON pages(site_id);
CREATE INDEX IF NOT EXISTS idx_content_categories_site_id ON content_categories(site_id);
CREATE INDEX IF NOT EXISTS idx_contents_site_id ON contents(site_id);
CREATE INDEX IF NOT EXISTS idx_domains_site_id ON domains(site_id);
CREATE INDEX IF NOT EXISTS idx_domain_records_site_id ON domain_records(site_id);

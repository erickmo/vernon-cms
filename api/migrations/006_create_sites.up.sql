CREATE TABLE sites (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name          VARCHAR(255) NOT NULL,
    slug          VARCHAR(255) NOT NULL,
    custom_domain VARCHAR(255) NOT NULL,
    owner_id      UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    is_active     BOOLEAN NOT NULL DEFAULT true,
    settings      JSONB NOT NULL DEFAULT '{}',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT sites_slug_unique UNIQUE (slug),
    CONSTRAINT sites_custom_domain_unique UNIQUE (custom_domain)
);
CREATE INDEX idx_sites_owner_id ON sites(owner_id);
CREATE INDEX idx_sites_custom_domain ON sites(custom_domain);

CREATE TABLE site_members (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id    UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role       VARCHAR(20) NOT NULL DEFAULT 'viewer'
               CHECK (role IN ('admin', 'editor', 'viewer')),
    invited_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT site_members_unique UNIQUE (site_id, user_id)
);
CREATE INDEX idx_site_members_site_id ON site_members(site_id);
CREATE INDEX idx_site_members_user_id ON site_members(user_id);

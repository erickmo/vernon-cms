CREATE TABLE IF NOT EXISTS domains (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(100),
    plural_name VARCHAR(255) NOT NULL,
    sidebar_section VARCHAR(100) NOT NULL DEFAULT 'content',
    sidebar_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS domain_fields (
    id UUID PRIMARY KEY,
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    label VARCHAR(255) NOT NULL,
    field_type VARCHAR(50) NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT false,
    default_value TEXT,
    placeholder VARCHAR(255),
    help_text TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    options JSONB,
    related_domain_id UUID REFERENCES domains(id) ON DELETE SET NULL,
    related_domain_slug VARCHAR(255),
    UNIQUE(domain_id, name)
);

CREATE TABLE IF NOT EXISTS domain_records (
    id UUID PRIMARY KEY,
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    domain_slug VARCHAR(255) NOT NULL,
    data JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_domain_fields_domain_id ON domain_fields(domain_id);
CREATE INDEX idx_domain_fields_sort_order ON domain_fields(domain_id, sort_order);
CREATE INDEX idx_domain_records_domain_id ON domain_records(domain_id);
CREATE INDEX idx_domain_records_domain_slug ON domain_records(domain_slug);
CREATE INDEX idx_domain_records_data ON domain_records USING GIN (data);

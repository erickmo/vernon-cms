CREATE TABLE IF NOT EXISTS api_tokens (
    id UUID PRIMARY KEY,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    prefix VARCHAR(10) NOT NULL,
    permissions JSONB NOT NULL DEFAULT '[]',
    expires_at TIMESTAMPTZ,
    last_used_at TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_api_tokens_site_id ON api_tokens(site_id);
CREATE INDEX idx_api_tokens_token_hash ON api_tokens(token_hash);

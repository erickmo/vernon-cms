CREATE TABLE IF NOT EXISTS contents (
    id UUID PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    slug VARCHAR(500) NOT NULL UNIQUE,
    body TEXT NOT NULL DEFAULT '',
    excerpt TEXT NOT NULL DEFAULT '',
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    page_id UUID NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES content_categories(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    metadata JSONB NOT NULL DEFAULT '{}',
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_contents_slug ON contents(slug);
CREATE INDEX idx_contents_status ON contents(status);
CREATE INDEX idx_contents_page_id ON contents(page_id);
CREATE INDEX idx_contents_category_id ON contents(category_id);
CREATE INDEX idx_contents_author_id ON contents(author_id);
CREATE INDEX idx_contents_published_at ON contents(published_at);

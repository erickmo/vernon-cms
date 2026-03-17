CREATE TABLE IF NOT EXISTS media_files (
    id UUID PRIMARY KEY,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    file_name VARCHAR(500) NOT NULL,
    file_url TEXT NOT NULL,
    thumbnail_url TEXT,
    mime_type VARCHAR(100) NOT NULL DEFAULT 'application/octet-stream',
    file_size BIGINT NOT NULL DEFAULT 0,
    width INT,
    height INT,
    alt TEXT,
    caption TEXT,
    folder VARCHAR(255),
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_media_files_site_id ON media_files(site_id);
CREATE INDEX idx_media_files_folder ON media_files(folder);
CREATE INDEX idx_media_files_mime_type ON media_files(mime_type);
CREATE INDEX idx_media_files_created_at ON media_files(created_at DESC);

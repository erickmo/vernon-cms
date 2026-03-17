-- name: GetContent :one
SELECT * FROM contents WHERE id = $1;

-- name: GetContentBySlug :one
SELECT * FROM contents WHERE slug = $1;

-- name: ListContents :many
SELECT * FROM contents ORDER BY created_at DESC LIMIT $1 OFFSET $2;

-- name: ListContentsByPageID :many
SELECT * FROM contents WHERE page_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3;

-- name: ListContentsByCategoryID :many
SELECT * FROM contents WHERE category_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3;

-- name: CountContents :one
SELECT COUNT(*) FROM contents;

-- name: CreateContent :exec
INSERT INTO contents (id, title, slug, body, excerpt, status, page_id, category_id, author_id, metadata, published_at, created_at, updated_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13);

-- name: UpdateContent :exec
UPDATE contents SET title = $1, slug = $2, body = $3, excerpt = $4, status = $5,
    metadata = $6, published_at = $7, updated_at = $8
WHERE id = $9;

-- name: DeleteContent :exec
DELETE FROM contents WHERE id = $1;

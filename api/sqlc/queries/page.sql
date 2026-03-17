-- name: GetPage :one
SELECT * FROM pages WHERE id = $1;

-- name: GetPageBySlug :one
SELECT * FROM pages WHERE slug = $1;

-- name: ListPages :many
SELECT * FROM pages ORDER BY created_at DESC LIMIT $1 OFFSET $2;

-- name: CountPages :one
SELECT COUNT(*) FROM pages;

-- name: CreatePage :exec
INSERT INTO pages (id, name, slug, variables, is_active, created_at, updated_at)
VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: UpdatePage :exec
UPDATE pages SET name = $1, slug = $2, variables = $3, is_active = $4, updated_at = $5
WHERE id = $6;

-- name: DeletePage :exec
DELETE FROM pages WHERE id = $1;

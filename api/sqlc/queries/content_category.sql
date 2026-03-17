-- name: GetContentCategory :one
SELECT * FROM content_categories WHERE id = $1;

-- name: GetContentCategoryBySlug :one
SELECT * FROM content_categories WHERE slug = $1;

-- name: ListContentCategories :many
SELECT * FROM content_categories ORDER BY created_at DESC LIMIT $1 OFFSET $2;

-- name: CountContentCategories :one
SELECT COUNT(*) FROM content_categories;

-- name: CreateContentCategory :exec
INSERT INTO content_categories (id, name, slug, created_at, updated_at)
VALUES ($1, $2, $3, $4, $5);

-- name: UpdateContentCategory :exec
UPDATE content_categories SET name = $1, slug = $2, updated_at = $3
WHERE id = $4;

-- name: DeleteContentCategory :exec
DELETE FROM content_categories WHERE id = $1;

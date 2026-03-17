-- name: GetUser :one
SELECT * FROM users WHERE id = $1;

-- name: GetUserByEmail :one
SELECT * FROM users WHERE email = $1;

-- name: ListUsers :many
SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2;

-- name: CountUsers :one
SELECT COUNT(*) FROM users;

-- name: CreateUser :exec
INSERT INTO users (id, email, password_hash, name, role, is_active, created_at, updated_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8);

-- name: UpdateUser :exec
UPDATE users SET email = $1, password_hash = $2, name = $3, role = $4, is_active = $5, updated_at = $6
WHERE id = $7;

-- name: DeleteUser :exec
DELETE FROM users WHERE id = $1;

package database

import (
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/user"
)

type UserRepository struct {
	db *sqlx.DB
}

func NewUserRepository(db *sqlx.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Save(u *user.User) error {
	query := `INSERT INTO users (id, email, password_hash, name, role, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err := r.db.Exec(query, u.ID, u.Email, u.PasswordHash, u.Name, u.Role, u.IsActive, u.CreatedAt, u.UpdatedAt)
	return err
}

func (r *UserRepository) Update(u *user.User) error {
	query := `UPDATE users SET email = $1, password_hash = $2, name = $3, role = $4, is_active = $5, updated_at = $6 WHERE id = $7`
	result, err := r.db.Exec(query, u.Email, u.PasswordHash, u.Name, u.Role, u.IsActive, u.UpdatedAt, u.ID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("user not found: %s", u.ID)
	}
	return nil
}

func (r *UserRepository) Delete(id uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM users WHERE id = $1`, id)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("user not found: %s", id)
	}
	return nil
}

func (r *UserRepository) FindByID(id uuid.UUID) (*user.User, error) {
	var u user.User
	err := r.db.Get(&u, `SELECT * FROM users WHERE id = $1`, id)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("user not found: %s", id)
	}
	return &u, err
}

func (r *UserRepository) FindByEmail(email string) (*user.User, error) {
	var u user.User
	err := r.db.Get(&u, `SELECT * FROM users WHERE email = $1`, email)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("user not found with email: %s", email)
	}
	return &u, err
}

func (r *UserRepository) FindAll(offset, limit int) ([]*user.User, int, error) {
	var total int
	err := r.db.Get(&total, `SELECT COUNT(*) FROM users`)
	if err != nil {
		return nil, 0, err
	}

	var users []*user.User
	err = r.db.Select(&users, `SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2`, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

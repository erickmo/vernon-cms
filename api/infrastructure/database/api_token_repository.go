package database

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/apitoken"
)

type APITokenRepository struct {
	db *sqlx.DB
}

func NewAPITokenRepository(db *sqlx.DB) *APITokenRepository {
	return &APITokenRepository{db: db}
}

// apiTokenRow is an intermediate struct for scanning JSONB permissions.
type apiTokenRow struct {
	ID          uuid.UUID  `db:"id"`
	SiteID      uuid.UUID  `db:"site_id"`
	Name        string     `db:"name"`
	TokenHash   string     `db:"token_hash"`
	Prefix      string     `db:"prefix"`
	Permissions []byte     `db:"permissions"`
	ExpiresAt   *time.Time `db:"expires_at"`
	LastUsedAt  *time.Time `db:"last_used_at"`
	IsActive    bool       `db:"is_active"`
	CreatedAt   time.Time  `db:"created_at"`
}

func (row *apiTokenRow) toAPIToken() *apitoken.APIToken {
	var perms []string
	if len(row.Permissions) > 0 {
		_ = json.Unmarshal(row.Permissions, &perms)
	}
	if perms == nil {
		perms = []string{}
	}
	return &apitoken.APIToken{
		ID:          row.ID,
		SiteID:      row.SiteID,
		Name:        row.Name,
		TokenHash:   row.TokenHash,
		Prefix:      row.Prefix,
		Permissions: perms,
		ExpiresAt:   row.ExpiresAt,
		LastUsedAt:  row.LastUsedAt,
		IsActive:    row.IsActive,
		CreatedAt:   row.CreatedAt,
	}
}

func (r *APITokenRepository) Save(t *apitoken.APIToken) error {
	perms, err := json.Marshal(t.Permissions)
	if err != nil {
		return err
	}
	_, err = r.db.Exec(`
		INSERT INTO api_tokens (id, site_id, name, token_hash, prefix, permissions, expires_at, is_active, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`, t.ID, t.SiteID, t.Name, t.TokenHash, t.Prefix, perms, t.ExpiresAt, t.IsActive, t.CreatedAt)
	return err
}

func (r *APITokenRepository) Update(t *apitoken.APIToken) error {
	perms, err := json.Marshal(t.Permissions)
	if err != nil {
		return err
	}
	result, err := r.db.Exec(`
		UPDATE api_tokens
		SET name = $1, permissions = $2, expires_at = $3, is_active = $4
		WHERE id = $5 AND site_id = $6
	`, t.Name, perms, t.ExpiresAt, t.IsActive, t.ID, t.SiteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("api token not found: %s", t.ID)
	}
	return nil
}

func (r *APITokenRepository) Delete(id, siteID uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM api_tokens WHERE id = $1 AND site_id = $2`, id, siteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("api token not found: %s", id)
	}
	return nil
}

func (r *APITokenRepository) FindByID(id, siteID uuid.UUID) (*apitoken.APIToken, error) {
	var row apiTokenRow
	err := r.db.Get(&row, `SELECT * FROM api_tokens WHERE id = $1 AND site_id = $2`, id, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("api token not found: %s", id)
	}
	if err != nil {
		return nil, err
	}
	return row.toAPIToken(), nil
}

func (r *APITokenRepository) FindAll(siteID uuid.UUID) ([]*apitoken.APIToken, error) {
	var rows []apiTokenRow
	err := r.db.Select(&rows, `
		SELECT * FROM api_tokens WHERE site_id = $1 ORDER BY created_at DESC
	`, siteID)
	if err != nil {
		return []*apitoken.APIToken{}, nil
	}
	result := make([]*apitoken.APIToken, len(rows))
	for i, row := range rows {
		result[i] = row.toAPIToken()
	}
	return result, nil
}

func (r *APITokenRepository) FindByHash(hash string) (*apitoken.APIToken, error) {
	var row apiTokenRow
	err := r.db.Get(&row, `SELECT * FROM api_tokens WHERE token_hash = $1 AND is_active = true`, hash)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("api token not found")
	}
	if err != nil {
		return nil, err
	}
	return row.toAPIToken(), nil
}

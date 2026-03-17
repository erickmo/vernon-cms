package apitoken

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

type APIToken struct {
	ID          uuid.UUID  `db:"id"`
	SiteID      uuid.UUID  `db:"site_id"`
	Name        string     `db:"name"`
	TokenHash   string     `db:"token_hash"`
	Prefix      string     `db:"prefix"`
	Permissions []string   `db:"permissions"`
	ExpiresAt   *time.Time `db:"expires_at"`
	LastUsedAt  *time.Time `db:"last_used_at"`
	IsActive    bool       `db:"is_active"`
	CreatedAt   time.Time  `db:"created_at"`
}

func NewAPIToken(siteID uuid.UUID, name, tokenHash, prefix string, permissions []string, expiresAt *time.Time) (*APIToken, error) {
	if name == "" {
		return nil, errors.New("token name is required")
	}
	if tokenHash == "" {
		return nil, errors.New("token hash is required")
	}
	return &APIToken{
		ID:          uuid.New(),
		SiteID:      siteID,
		Name:        name,
		TokenHash:   tokenHash,
		Prefix:      prefix,
		Permissions: permissions,
		ExpiresAt:   expiresAt,
		IsActive:    true,
		CreatedAt:   time.Now(),
	}, nil
}

func (t *APIToken) ToggleActive() {
	t.IsActive = !t.IsActive
}

type WriteRepository interface {
	Save(t *APIToken) error
	Update(t *APIToken) error
	Delete(id, siteID uuid.UUID) error
	FindByID(id, siteID uuid.UUID) (*APIToken, error)
}

type ReadRepository interface {
	FindAll(siteID uuid.UUID) ([]*APIToken, error)
	FindByID(id, siteID uuid.UUID) (*APIToken, error)
	FindByHash(hash string) (*APIToken, error)
}

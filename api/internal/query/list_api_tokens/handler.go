package listapitoken

import (
	"context"
	"time"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/apitoken"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID uuid.UUID
}

func (q Query) QueryName() string { return "ListAPITokens" }

type TokenReadModel struct {
	ID          uuid.UUID  `json:"id"`
	Name        string     `json:"name"`
	Token       string     `json:"token"`
	Prefix      string     `json:"prefix"`
	Permissions []string   `json:"permissions"`
	ExpiresAt   *time.Time `json:"expires_at,omitempty"`
	LastUsedAt  *time.Time `json:"last_used_at,omitempty"`
	IsActive    bool       `json:"is_active"`
	CreatedAt   time.Time  `json:"created_at"`
}

type Handler struct {
	repo apitoken.ReadRepository
}

func NewHandler(repo apitoken.ReadRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	tokens, err := h.repo.FindAll(query.SiteID)
	if err != nil {
		return []*TokenReadModel{}, nil
	}
	result := make([]*TokenReadModel, len(tokens))
	for i, t := range tokens {
		result[i] = toReadModel(t, "")
	}
	return result, nil
}

func toReadModel(t *apitoken.APIToken, plainToken string) *TokenReadModel {
	perms := t.Permissions
	if perms == nil {
		perms = []string{}
	}
	return &TokenReadModel{
		ID:          t.ID,
		Name:        t.Name,
		Token:       plainToken,
		Prefix:      t.Prefix,
		Permissions: perms,
		ExpiresAt:   t.ExpiresAt,
		LastUsedAt:  t.LastUsedAt,
		IsActive:    t.IsActive,
		CreatedAt:   t.CreatedAt,
	}
}

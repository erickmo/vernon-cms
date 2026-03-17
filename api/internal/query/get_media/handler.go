package getmedia

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/media"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	ID     uuid.UUID
	SiteID uuid.UUID
}

func (q Query) QueryName() string { return "GetMedia" }

type Handler struct {
	repo media.ReadRepository
}

func NewHandler(repo media.ReadRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	return h.repo.FindByID(query.ID, query.SiteID)
}

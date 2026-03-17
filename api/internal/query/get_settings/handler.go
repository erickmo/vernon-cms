package getsettings

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/settings"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID uuid.UUID
}

func (q Query) QueryName() string { return "GetSettings" }

type Handler struct {
	repo settings.ReadRepository
}

func NewHandler(repo settings.ReadRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	s, err := h.repo.FindBySiteID(query.SiteID)
	if err != nil {
		// return empty settings if not found
		return &settings.Settings{SiteID: query.SiteID}, nil
	}
	return s, nil
}

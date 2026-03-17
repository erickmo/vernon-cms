package listmediafolders

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/media"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID uuid.UUID
}

func (q Query) QueryName() string { return "ListMediaFolders" }

type Handler struct {
	repo media.ReadRepository
}

func NewHandler(repo media.ReadRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	folders, err := h.repo.FindFolders(query.SiteID)
	if err != nil {
		return []string{}, nil
	}
	return folders, nil
}

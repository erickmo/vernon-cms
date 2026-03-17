package listmedia

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/media"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID   uuid.UUID
	Search   string
	MimeType string
	Folder   string
	Page     int
	PerPage  int
}

func (q Query) QueryName() string { return "ListMedia" }

type Handler struct {
	repo media.ReadRepository
}

func NewHandler(repo media.ReadRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	limit := query.PerPage
	if limit <= 0 {
		limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * limit
	}
	files, _, err := h.repo.FindAll(query.SiteID, query.Search, query.MimeType, query.Folder, offset, limit)
	if err != nil {
		return []*media.MediaFile{}, nil
	}
	return files, nil
}

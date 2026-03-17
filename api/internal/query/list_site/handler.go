package listsite

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/site"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	UserID uuid.UUID `json:"user_id"`
	Page   int       `json:"page"`
	Limit  int       `json:"limit"`
}

func (q Query) QueryName() string { return "ListSite" }

type ReadModel struct {
	ID           uuid.UUID `json:"id"`
	Name         string    `json:"name"`
	Slug         string    `json:"slug"`
	CustomDomain string    `json:"custom_domain"`
	OwnerID      uuid.UUID `json:"owner_id"`
	IsActive     bool      `json:"is_active"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

type ListResult struct {
	Items []*ReadModel `json:"items"`
	Total int          `json:"total"`
	Page  int          `json:"page"`
	Limit int          `json:"limit"`
}

type Handler struct {
	repo   site.ReadRepository
	tracer trace.Tracer
}

func NewHandler(repo site.ReadRepository) *Handler {
	return &Handler{
		repo:   repo,
		tracer: otel.Tracer("query.list_site"),
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	_, span := h.tracer.Start(ctx, "ListSite.Handle")
	defer span.End()

	if query.Limit <= 0 {
		query.Limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * query.Limit
	}

	sites, total, err := h.repo.FindByUserID(query.UserID, offset, query.Limit)
	if err != nil {
		return nil, err
	}

	items := make([]*ReadModel, len(sites))
	for i, s := range sites {
		items[i] = &ReadModel{
			ID:           s.ID,
			Name:         s.Name,
			Slug:         s.Slug,
			CustomDomain: s.CustomDomain,
			OwnerID:      s.OwnerID,
			IsActive:     s.IsActive,
			CreatedAt:    s.CreatedAt,
			UpdatedAt:    s.UpdatedAt,
		}
	}

	return &ListResult{
		Items: items,
		Total: total,
		Page:  query.Page,
		Limit: query.Limit,
	}, nil
}

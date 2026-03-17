package listpage

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/page"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID uuid.UUID `json:"site_id"`
	Page   int       `json:"page"`
	Limit  int       `json:"limit"`
}

func (q Query) QueryName() string { return "ListPage" }

type ReadModel struct {
	ID        string          `json:"id"`
	SiteID    string          `json:"site_id"`
	Name      string          `json:"name"`
	Slug      string          `json:"slug"`
	Variables json.RawMessage `json:"variables"`
	IsActive  bool            `json:"is_active"`
	CreatedAt time.Time       `json:"created_at"`
	UpdatedAt time.Time       `json:"updated_at"`
}

type ListResult struct {
	Items []*ReadModel `json:"items"`
	Total int          `json:"total"`
	Page  int          `json:"page"`
	Limit int          `json:"limit"`
}

type Handler struct {
	repo   page.ReadRepository
	tracer trace.Tracer
}

func NewHandler(repo page.ReadRepository) *Handler {
	return &Handler{
		repo:   repo,
		tracer: otel.Tracer("query.list_page"),
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)

	_, span := h.tracer.Start(ctx, "ListPage.Handle")
	defer span.End()

	if query.Limit <= 0 {
		query.Limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * query.Limit
	}

	pages, total, err := h.repo.FindAll(query.SiteID, offset, query.Limit)
	if err != nil {
		return nil, err
	}

	items := make([]*ReadModel, len(pages))
	for i, p := range pages {
		items[i] = &ReadModel{
			ID:        p.ID.String(),
			SiteID:    p.SiteID.String(),
			Name:      p.Name,
			Slug:      p.Slug,
			Variables: p.Variables,
			IsActive:  p.IsActive,
			CreatedAt: p.CreatedAt,
			UpdatedAt: p.UpdatedAt,
		}
	}

	return &ListResult{
		Items: items,
		Total: total,
		Page:  query.Page,
		Limit: query.Limit,
	}, nil
}

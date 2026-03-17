package listcontentcategory

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	contentcategory "github.com/erickmo/vernon-cms/internal/domain/content_category"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID uuid.UUID `json:"site_id"`
	Page   int       `json:"page"`
	Limit  int       `json:"limit"`
}

func (q Query) QueryName() string { return "ListContentCategory" }

type ReadModel struct {
	ID        uuid.UUID `json:"id"`
	SiteID    uuid.UUID `json:"site_id"`
	Name      string    `json:"name"`
	Slug      string    `json:"slug"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type ListResult struct {
	Items []*ReadModel `json:"items"`
	Total int          `json:"total"`
	Page  int          `json:"page"`
	Limit int          `json:"limit"`
}

type Handler struct {
	repo   contentcategory.ReadRepository
	tracer trace.Tracer
}

func NewHandler(repo contentcategory.ReadRepository) *Handler {
	return &Handler{
		repo:   repo,
		tracer: otel.Tracer("query.list_content_category"),
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)

	_, span := h.tracer.Start(ctx, "ListContentCategory.Handle")
	defer span.End()

	if query.Limit <= 0 {
		query.Limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * query.Limit
	}

	categories, total, err := h.repo.FindAll(query.SiteID, offset, query.Limit)
	if err != nil {
		return nil, err
	}

	items := make([]*ReadModel, len(categories))
	for i, c := range categories {
		items[i] = &ReadModel{
			ID:        c.ID,
			SiteID:    c.SiteID,
			Name:      c.Name,
			Slug:      c.Slug,
			CreatedAt: c.CreatedAt,
			UpdatedAt: c.UpdatedAt,
		}
	}

	return &ListResult{
		Items: items,
		Total: total,
		Page:  query.Page,
		Limit: query.Limit,
	}, nil
}

package listcontent

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/content"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID uuid.UUID `json:"site_id"`
	Page   int       `json:"page"`
	Limit  int       `json:"limit"`
}

func (q Query) QueryName() string { return "ListContent" }

type ReadModel struct {
	ID          uuid.UUID       `json:"id"`
	SiteID      uuid.UUID       `json:"site_id"`
	Title       string          `json:"title"`
	Slug        string          `json:"slug"`
	Body        string          `json:"body"`
	Excerpt     string          `json:"excerpt"`
	Status      string          `json:"status"`
	PageID      uuid.UUID       `json:"page_id"`
	CategoryID  uuid.UUID       `json:"category_id"`
	AuthorID    uuid.UUID       `json:"author_id"`
	Metadata    json.RawMessage `json:"metadata"`
	PublishedAt *time.Time      `json:"published_at"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}

type ListResult struct {
	Items []*ReadModel `json:"items"`
	Total int          `json:"total"`
	Page  int          `json:"page"`
	Limit int          `json:"limit"`
}

type Handler struct {
	repo   content.ReadRepository
	tracer trace.Tracer
}

func NewHandler(repo content.ReadRepository) *Handler {
	return &Handler{
		repo:   repo,
		tracer: otel.Tracer("query.list_content"),
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)

	_, span := h.tracer.Start(ctx, "ListContent.Handle")
	defer span.End()

	if query.Limit <= 0 {
		query.Limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * query.Limit
	}

	contents, total, err := h.repo.FindAll(query.SiteID, offset, query.Limit)
	if err != nil {
		return nil, err
	}

	items := make([]*ReadModel, len(contents))
	for i, ct := range contents {
		items[i] = &ReadModel{
			ID:          ct.ID,
			SiteID:      ct.SiteID,
			Title:       ct.Title,
			Slug:        ct.Slug,
			Body:        ct.Body,
			Excerpt:     ct.Excerpt,
			Status:      string(ct.Status),
			PageID:      ct.PageID,
			CategoryID:  ct.CategoryID,
			AuthorID:    ct.AuthorID,
			Metadata:    ct.Metadata,
			PublishedAt: ct.PublishedAt,
			CreatedAt:   ct.CreatedAt,
			UpdatedAt:   ct.UpdatedAt,
		}
	}

	return &ListResult{
		Items: items,
		Total: total,
		Page:  query.Page,
		Limit: query.Limit,
	}, nil
}

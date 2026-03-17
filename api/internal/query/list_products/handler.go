package listproducts

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/product"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID     uuid.UUID  `json:"site_id"`
	Search     string     `json:"search"`
	CategoryID *uuid.UUID `json:"category_id"`
	Page       int        `json:"page"`
	Limit      int        `json:"limit"`
}

func (q Query) QueryName() string { return "ListProducts" }

type ReadModel struct {
	ID          uuid.UUID       `json:"id"`
	SiteID      uuid.UUID       `json:"site_id"`
	CategoryID  *uuid.UUID      `json:"category_id,omitempty"`
	Name        string          `json:"name"`
	Slug        string          `json:"slug"`
	Description string          `json:"description"`
	Price       float64         `json:"price"`
	Stock       *int            `json:"stock,omitempty"`
	Images      json.RawMessage `json:"images"`
	Metadata    json.RawMessage `json:"metadata"`
	IsActive    bool            `json:"is_active"`
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
	repo   product.ReadRepository
	tracer trace.Tracer
}

func NewHandler(repo product.ReadRepository) *Handler {
	return &Handler{
		repo:   repo,
		tracer: otel.Tracer("query.list_products"),
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)

	_, span := h.tracer.Start(ctx, "ListProducts.Handle")
	defer span.End()

	if query.Limit <= 0 {
		query.Limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * query.Limit
	}

	products, total, err := h.repo.FindAll(query.SiteID, query.Search, query.CategoryID, offset, query.Limit)
	if err != nil {
		return nil, err
	}

	items := make([]*ReadModel, len(products))
	for i, p := range products {
		items[i] = &ReadModel{
			ID:          p.ID,
			SiteID:      p.SiteID,
			CategoryID:  p.CategoryID,
			Name:        p.Name,
			Slug:        p.Slug,
			Description: p.Description,
			Price:       p.Price,
			Stock:       p.Stock,
			Images:      p.Images,
			Metadata:    p.Metadata,
			IsActive:    p.IsActive,
			CreatedAt:   p.CreatedAt,
			UpdatedAt:   p.UpdatedAt,
		}
	}

	return &ListResult{
		Items: items,
		Total: total,
		Page:  query.Page,
		Limit: query.Limit,
	}, nil
}

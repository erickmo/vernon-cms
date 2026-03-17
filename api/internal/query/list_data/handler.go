package listdata

import (
	"context"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	data "github.com/erickmo/vernon-cms/internal/domain/data"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID uuid.UUID `json:"site_id"`
	Page   int       `json:"page"`
	Limit  int       `json:"limit"`
}

func (q Query) QueryName() string { return "ListData" }

type ListResult struct {
	Items []*data.DataType `json:"items"`
	Total int              `json:"total"`
	Page  int              `json:"page"`
	Limit int              `json:"limit"`
}

type Handler struct {
	repo   data.DataReadRepository
	tracer trace.Tracer
}

func NewHandler(repo data.DataReadRepository) *Handler {
	return &Handler{repo: repo, tracer: otel.Tracer("query.list_data")}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	_, span := h.tracer.Start(ctx, "ListData.Handle")
	defer span.End()

	if query.Limit <= 0 {
		query.Limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * query.Limit
	}

	dataTypes, total, err := h.repo.FindAllDataTypes(query.SiteID, offset, query.Limit)
	if err != nil {
		return nil, err
	}

	return &ListResult{Items: dataTypes, Total: total, Page: query.Page, Limit: query.Limit}, nil
}

package listdatarecord

import (
	"context"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	data "github.com/erickmo/vernon-cms/internal/domain/data"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID   uuid.UUID `json:"site_id"`
	DataSlug string    `json:"data_slug"`
	Search   string    `json:"search"`
	Page     int       `json:"page"`
	Limit    int       `json:"limit"`
}

func (q Query) QueryName() string { return "ListDataRecord" }

type ListResult struct {
	Items []*data.DataRecord `json:"items"`
	Total int                `json:"total"`
	Page  int                `json:"page"`
	Limit int                `json:"limit"`
}

type Handler struct {
	repo   data.DataReadRepository
	tracer trace.Tracer
}

func NewHandler(repo data.DataReadRepository) *Handler {
	return &Handler{repo: repo, tracer: otel.Tracer("query.list_data_record")}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	_, span := h.tracer.Start(ctx, "ListDataRecord.Handle")
	defer span.End()

	if query.Limit <= 0 {
		query.Limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * query.Limit
	}

	records, total, err := h.repo.FindRecordsByDataSlug(query.DataSlug, query.SiteID, query.Search, offset, query.Limit)
	if err != nil {
		return nil, err
	}

	return &ListResult{Items: records, Total: total, Page: query.Page, Limit: query.Limit}, nil
}

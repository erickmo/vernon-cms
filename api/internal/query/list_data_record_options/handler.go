package listdatarecordoptions

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
}

func (q Query) QueryName() string { return "ListDataRecordOptions" }

type Handler struct {
	repo   data.DataReadRepository
	tracer trace.Tracer
}

func NewHandler(repo data.DataReadRepository) *Handler {
	return &Handler{repo: repo, tracer: otel.Tracer("query.list_data_record_options")}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	_, span := h.tracer.Start(ctx, "ListDataRecordOptions.Handle")
	defer span.End()

	return h.repo.FindRecordOptions(query.DataSlug, query.SiteID)
}

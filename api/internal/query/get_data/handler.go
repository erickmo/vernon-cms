package getdata

import (
	"context"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	data "github.com/erickmo/vernon-cms/internal/domain/data"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	ID     uuid.UUID `json:"id"`
	SiteID uuid.UUID `json:"site_id"`
}

func (q Query) QueryName() string { return "GetData" }

type Handler struct {
	repo   data.DataReadRepository
	tracer trace.Tracer
}

func NewHandler(repo data.DataReadRepository) *Handler {
	return &Handler{repo: repo, tracer: otel.Tracer("query.get_data")}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	_, span := h.tracer.Start(ctx, "GetData.Handle")
	defer span.End()

	return h.repo.FindDataTypeByID(query.ID, query.SiteID)
}

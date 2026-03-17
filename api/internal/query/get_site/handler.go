package getsite

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
	ID uuid.UUID `json:"id"`
}

func (q Query) QueryName() string { return "GetSite" }

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

type Handler struct {
	repo   site.ReadRepository
	tracer trace.Tracer
}

func NewHandler(repo site.ReadRepository) *Handler {
	return &Handler{
		repo:   repo,
		tracer: otel.Tracer("query.get_site"),
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	_, span := h.tracer.Start(ctx, "GetSite.Handle")
	defer span.End()

	s, err := h.repo.FindByID(query.ID)
	if err != nil {
		return nil, err
	}

	return &ReadModel{
		ID:           s.ID,
		Name:         s.Name,
		Slug:         s.Slug,
		CustomDomain: s.CustomDomain,
		OwnerID:      s.OwnerID,
		IsActive:     s.IsActive,
		CreatedAt:    s.CreatedAt,
		UpdatedAt:    s.UpdatedAt,
	}, nil
}

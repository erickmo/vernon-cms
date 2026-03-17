package listsitemember

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
	SiteID uuid.UUID `json:"site_id"`
}

func (q Query) QueryName() string { return "ListSiteMember" }

type ReadModel struct {
	ID        uuid.UUID  `json:"id"`
	SiteID    uuid.UUID  `json:"site_id"`
	UserID    uuid.UUID  `json:"user_id"`
	Role      string     `json:"role"`
	InvitedBy *uuid.UUID `json:"invited_by,omitempty"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
}

type Handler struct {
	repo   site.ReadRepository
	tracer trace.Tracer
}

func NewHandler(repo site.ReadRepository) *Handler {
	return &Handler{
		repo:   repo,
		tracer: otel.Tracer("query.list_site_member"),
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	_, span := h.tracer.Start(ctx, "ListSiteMember.Handle")
	defer span.End()

	members, err := h.repo.FindMembersBySiteID(query.SiteID)
	if err != nil {
		return nil, err
	}

	items := make([]*ReadModel, len(members))
	for i, m := range members {
		items[i] = &ReadModel{
			ID:        m.ID,
			SiteID:    m.SiteID,
			UserID:    m.UserID,
			Role:      string(m.Role),
			InvitedBy: m.InvitedBy,
			CreatedAt: m.CreatedAt,
			UpdatedAt: m.UpdatedAt,
		}
	}

	return items, nil
}

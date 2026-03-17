package removesitemember

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/site"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type Command struct {
	SiteID uuid.UUID `json:"site_id" validate:"required"`
	UserID uuid.UUID `json:"user_id" validate:"required"`
}

func (c Command) CommandName() string { return "RemoveSiteMember" }

type Handler struct {
	repo     site.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo site.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.remove_site_member"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "RemoveSiteMember.Handle")
	defer span.End()

	if err := h.repo.RemoveMember(c.SiteID, c.UserID); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, site.SiteMemberRemoved{
		SiteID: c.SiteID,
		UserID: c.UserID,
		Time:   time.Now(),
	})
}

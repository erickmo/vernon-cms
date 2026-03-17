package updatesite

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
	ID           uuid.UUID `json:"id" validate:"required"`
	Name         string    `json:"name" validate:"required"`
	CustomDomain string    `json:"custom_domain" validate:"required"`
}

func (c Command) CommandName() string { return "UpdateSite" }

type Handler struct {
	repo     site.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo site.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.update_site"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "UpdateSite.Handle")
	defer span.End()

	s, err := h.repo.FindByID(c.ID)
	if err != nil {
		return err
	}

	s.Name = c.Name
	s.CustomDomain = c.CustomDomain
	s.UpdatedAt = time.Now()

	if err := h.repo.Update(s); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, site.SiteUpdated{
		SiteID: s.ID,
		Name:   s.Name,
		Domain: s.CustomDomain,
		Time:   time.Now(),
	})
}

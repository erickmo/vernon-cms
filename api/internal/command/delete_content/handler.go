package deletecontent

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/content"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	ID uuid.UUID `json:"id" validate:"required"`
}

func (c Command) CommandName() string { return "DeleteContent" }

type Handler struct {
	repo     content.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo content.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.delete_content"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "DeleteContent.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	if err := h.repo.Delete(c.ID, siteID); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, content.ContentDeleted{
		ContentID: c.ID,
		Time:      time.Now(),
	})
}

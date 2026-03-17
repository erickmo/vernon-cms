package deletecontentcategory

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	contentcategory "github.com/erickmo/vernon-cms/internal/domain/content_category"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	ID uuid.UUID `json:"id" validate:"required"`
}

func (c Command) CommandName() string { return "DeleteContentCategory" }

type Handler struct {
	repo     contentcategory.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo contentcategory.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.delete_content_category"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "DeleteContentCategory.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	if err := h.repo.Delete(c.ID, siteID); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, contentcategory.ContentCategoryDeleted{
		CategoryID: c.ID,
		Time:       time.Now(),
	})
}

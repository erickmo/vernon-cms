package updatecontentcategory

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
	ID   uuid.UUID `json:"id" validate:"required"`
	Name string    `json:"name" validate:"required"`
	Slug string    `json:"slug" validate:"required"`
}

func (c Command) CommandName() string { return "UpdateContentCategory" }

type Handler struct {
	repo     contentcategory.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo contentcategory.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.update_content_category"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "UpdateContentCategory.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	cat, err := h.repo.FindByID(c.ID, siteID)
	if err != nil {
		return err
	}

	if err := cat.UpdateName(c.Name); err != nil {
		return err
	}
	if err := cat.UpdateSlug(c.Slug); err != nil {
		return err
	}

	if err := h.repo.Update(cat); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, contentcategory.ContentCategoryUpdated{
		CategoryID: cat.ID,
		Name:       cat.Name,
		Slug:       cat.Slug,
		Time:       time.Now(),
	})
}

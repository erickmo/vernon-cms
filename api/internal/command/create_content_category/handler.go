package createcontentcategory

import (
	"context"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	contentcategory "github.com/erickmo/vernon-cms/internal/domain/content_category"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	Name string `json:"name" validate:"required"`
	Slug string `json:"slug" validate:"required"`
}

func (c Command) CommandName() string { return "CreateContentCategory" }

type Handler struct {
	repo     contentcategory.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo contentcategory.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.create_content_category"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "CreateContentCategory.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	cat, err := contentcategory.NewContentCategory(siteID, c.Name, c.Slug)
	if err != nil {
		return err
	}

	if err := h.repo.Save(cat); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, contentcategory.ContentCategoryCreated{
		CategoryID: cat.ID,
		Name:       cat.Name,
		Slug:       cat.Slug,
		Time:       time.Now(),
	})
}

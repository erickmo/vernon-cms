package createpage

import (
	"context"
	"encoding/json"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/page"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	Name      string          `json:"name" validate:"required"`
	Slug      string          `json:"slug" validate:"required"`
	Variables json.RawMessage `json:"variables"`
}

func (c Command) CommandName() string { return "CreatePage" }

type Handler struct {
	repo     page.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo page.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.create_page"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "CreatePage.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	p, err := page.NewPage(siteID, c.Name, c.Slug, c.Variables)
	if err != nil {
		return err
	}

	if err := h.repo.Save(p); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, page.PageCreated{
		PageID: p.ID,
		Name:   p.Name,
		Slug:   p.Slug,
		Time:   time.Now(),
	})
}

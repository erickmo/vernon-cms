package updatepage

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/page"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	ID        uuid.UUID       `json:"id" validate:"required"`
	Name      string          `json:"name" validate:"required"`
	Slug      string          `json:"slug" validate:"required"`
	Variables json.RawMessage `json:"variables"`
	IsActive  *bool           `json:"is_active"`
}

func (c Command) CommandName() string { return "UpdatePage" }

type Handler struct {
	repo     page.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo page.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.update_page"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "UpdatePage.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	p, err := h.repo.FindByID(c.ID, siteID)
	if err != nil {
		return err
	}

	if err := p.UpdateName(c.Name); err != nil {
		return err
	}
	if err := p.UpdateSlug(c.Slug); err != nil {
		return err
	}
	if c.Variables != nil {
		p.UpdateVariables(c.Variables)
	}
	if c.IsActive != nil {
		p.SetActive(*c.IsActive)
	}

	if err := h.repo.Update(p); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, page.PageUpdated{
		PageID: p.ID,
		Name:   p.Name,
		Slug:   p.Slug,
		Time:   time.Now(),
	})
}

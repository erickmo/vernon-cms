package updatecontent

import (
	"context"
	"encoding/json"
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
	ID       uuid.UUID       `json:"id" validate:"required"`
	Title    string          `json:"title" validate:"required"`
	Slug     string          `json:"slug" validate:"required"`
	Body     string          `json:"body"`
	Excerpt  string          `json:"excerpt"`
	Metadata json.RawMessage `json:"metadata"`
}

func (c Command) CommandName() string { return "UpdateContent" }

type Handler struct {
	repo     content.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo content.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.update_content"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "UpdateContent.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	ct, err := h.repo.FindByID(c.ID, siteID)
	if err != nil {
		return err
	}

	if err := ct.UpdateTitle(c.Title); err != nil {
		return err
	}
	if err := ct.UpdateSlug(c.Slug); err != nil {
		return err
	}
	ct.UpdateBody(c.Body, c.Excerpt)
	if c.Metadata != nil {
		ct.UpdateMetadata(c.Metadata)
	}

	if err := h.repo.Update(ct); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, content.ContentUpdated{
		ContentID: ct.ID,
		Title:     ct.Title,
		Slug:      ct.Slug,
		Time:      time.Now(),
	})
}

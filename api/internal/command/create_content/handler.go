package createcontent

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
	Title      string          `json:"title" validate:"required"`
	Slug       string          `json:"slug" validate:"required"`
	Body       string          `json:"body"`
	Excerpt    string          `json:"excerpt"`
	PageID     uuid.UUID       `json:"page_id" validate:"required"`
	CategoryID uuid.UUID       `json:"category_id" validate:"required"`
	AuthorID   uuid.UUID       `json:"author_id" validate:"required"`
	Metadata   json.RawMessage `json:"metadata"`
}

func (c Command) CommandName() string { return "CreateContent" }

type Handler struct {
	repo     content.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo content.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.create_content"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "CreateContent.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	ct, err := content.NewContent(siteID, c.Title, c.Slug, c.Body, c.Excerpt, c.PageID, c.CategoryID, c.AuthorID, c.Metadata)
	if err != nil {
		return err
	}

	if err := h.repo.Save(ct); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, content.ContentCreated{
		ContentID:  ct.ID,
		Title:      ct.Title,
		Slug:       ct.Slug,
		AuthorID:   ct.AuthorID,
		CategoryID: ct.CategoryID,
		PageID:     ct.PageID,
		Time:       time.Now(),
	})
}

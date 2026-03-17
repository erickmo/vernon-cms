package deletedata

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	data "github.com/erickmo/vernon-cms/internal/domain/data"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	ID uuid.UUID `json:"id" validate:"required"`
}

func (c Command) CommandName() string { return "DeleteData" }

type Handler struct {
	repo     data.DataWriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo data.DataWriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{repo: repo, eventBus: eventBus, tracer: otel.Tracer("command.delete_data")}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	ctx, span := h.tracer.Start(ctx, "DeleteData.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	if err := h.repo.DeleteDataType(c.ID, siteID); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, data.DataDeleted{DataTypeID: c.ID, Time: time.Now()})
}

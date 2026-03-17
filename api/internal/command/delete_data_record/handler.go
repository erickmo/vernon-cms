package deletedatarecord

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	data "github.com/erickmo/vernon-cms/internal/domain/data"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type Command struct {
	ID       uuid.UUID `json:"id" validate:"required"`
	DataSlug string    `json:"data_slug" validate:"required"`
}

func (c Command) CommandName() string { return "DeleteDataRecord" }

type Handler struct {
	repo     data.DataWriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo data.DataWriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{repo: repo, eventBus: eventBus, tracer: otel.Tracer("command.delete_data_record")}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	ctx, span := h.tracer.Start(ctx, "DeleteDataRecord.Handle")
	defer span.End()

	if err := h.repo.DeleteRecord(c.ID); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, data.DataRecordDeleted{
		RecordID: c.ID, DataSlug: c.DataSlug, Time: time.Now(),
	})
}

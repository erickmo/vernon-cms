package updatedatarecord

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	data "github.com/erickmo/vernon-cms/internal/domain/data"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type Command struct {
	ID       uuid.UUID       `json:"id" validate:"required"`
	DataSlug string          `json:"data_slug" validate:"required"`
	Data     json.RawMessage `json:"data" validate:"required"`
}

func (c Command) CommandName() string { return "UpdateDataRecord" }

type Handler struct {
	repo     data.DataWriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo data.DataWriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{repo: repo, eventBus: eventBus, tracer: otel.Tracer("command.update_data_record")}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	ctx, span := h.tracer.Start(ctx, "UpdateDataRecord.Handle")
	defer span.End()

	now := time.Now()
	record := &data.DataRecord{
		ID:        c.ID,
		Data:      c.Data,
		UpdatedAt: now,
	}

	if err := h.repo.UpdateRecord(record); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, data.DataRecordUpdated{
		RecordID: c.ID, DataSlug: c.DataSlug, Time: now,
	})
}

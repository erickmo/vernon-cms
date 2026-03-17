package createdatarecord

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
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	DataSlug string          `json:"data_slug" validate:"required"`
	Data     json.RawMessage `json:"data" validate:"required"`
}

func (c Command) CommandName() string { return "CreateDataRecord" }

type Handler struct {
	repo     data.DataWriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo data.DataWriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{repo: repo, eventBus: eventBus, tracer: otel.Tracer("command.create_data_record")}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	ctx, span := h.tracer.Start(ctx, "CreateDataRecord.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	d, err := h.repo.FindDataTypeBySlug(c.DataSlug, siteID)
	if err != nil {
		return err
	}

	now := time.Now()
	rec := &data.DataRecord{
		ID:         uuid.New(),
		SiteID:     siteID,
		DataTypeID: d.ID,
		DataSlug:   d.Slug,
		Data:       c.Data,
		CreatedAt:  now,
		UpdatedAt:  now,
	}

	if err := h.repo.SaveRecord(rec); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, data.DataRecordCreated{
		RecordID: rec.ID, DataSlug: d.Slug, Time: now,
	})
}

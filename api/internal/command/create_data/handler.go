package createdata

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

type FieldInput struct {
	Name            string          `json:"name" validate:"required"`
	Label           string          `json:"label" validate:"required"`
	FieldType       string          `json:"field_type" validate:"required"`
	IsRequired      bool            `json:"is_required"`
	DefaultValue    *string         `json:"default_value"`
	Placeholder     *string         `json:"placeholder"`
	HelpText        *string         `json:"help_text"`
	SortOrder       int             `json:"sort_order"`
	Options         json.RawMessage `json:"options"`
	RelatedDataID   *uuid.UUID      `json:"related_data_id"`
	RelatedDataSlug *string         `json:"related_data_slug"`
}

type Command struct {
	Name           string       `json:"name" validate:"required"`
	Slug           string       `json:"slug" validate:"required"`
	Description    *string      `json:"description"`
	Icon           *string      `json:"icon"`
	PluralName     string       `json:"plural_name" validate:"required"`
	SidebarSection string       `json:"sidebar_section"`
	SidebarOrder   int          `json:"sidebar_order"`
	Fields         []FieldInput `json:"fields"`
}

func (c Command) CommandName() string { return "CreateData" }

type Handler struct {
	repo     data.DataWriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo data.DataWriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{repo: repo, eventBus: eventBus, tracer: otel.Tracer("command.create_data")}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	ctx, span := h.tracer.Start(ctx, "CreateData.Handle")
	defer span.End()

	siteID := middleware.GetSiteID(ctx)

	d, err := data.NewDataType(siteID, c.Name, c.Slug, c.PluralName, c.SidebarSection, c.SidebarOrder, c.Description, c.Icon)
	if err != nil {
		return err
	}

	if err := h.repo.SaveDataType(d); err != nil {
		return err
	}

	fields := make([]*data.DataField, 0, len(c.Fields))
	for _, fi := range c.Fields {
		f, err := data.NewDataField(d.ID, fi.Name, fi.Label, data.FieldType(fi.FieldType), fi.IsRequired, fi.SortOrder)
		if err != nil {
			return err
		}
		f.DefaultValue = fi.DefaultValue
		f.Placeholder = fi.Placeholder
		f.HelpText = fi.HelpText
		if fi.Options != nil {
			f.Options = fi.Options
		}
		f.RelatedDataID = fi.RelatedDataID
		f.RelatedDataSlug = fi.RelatedDataSlug
		fields = append(fields, f)
	}

	if len(fields) > 0 {
		if err := h.repo.SaveFields(d.ID, fields); err != nil {
			return err
		}
	}

	return h.eventBus.Publish(ctx, data.DataCreated{
		DataTypeID: d.ID, Name: d.Name, Slug: d.Slug, Time: time.Now(),
	})
}

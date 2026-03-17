package addsitemember

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/site"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type Command struct {
	SiteID    uuid.UUID `json:"site_id" validate:"required"`
	UserID    uuid.UUID `json:"user_id" validate:"required"`
	Role      string    `json:"role" validate:"required,oneof=admin editor viewer"`
	InvitedBy uuid.UUID `json:"invited_by"`
}

func (c Command) CommandName() string { return "AddSiteMember" }

type Handler struct {
	repo     site.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo site.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.add_site_member"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "AddSiteMember.Handle")
	defer span.End()

	var invitedBy *uuid.UUID
	if c.InvitedBy != uuid.Nil {
		invitedBy = &c.InvitedBy
	}

	member, err := site.NewSiteMember(c.SiteID, c.UserID, site.SiteRole(c.Role), invitedBy)
	if err != nil {
		return err
	}

	if err := h.repo.SaveMember(member); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, site.SiteMemberAdded{
		SiteID: c.SiteID,
		UserID: c.UserID,
		Role:   site.SiteRole(c.Role),
		Time:   time.Now(),
	})
}

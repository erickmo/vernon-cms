package updatesitememberrole

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
	SiteID uuid.UUID `json:"site_id" validate:"required"`
	UserID uuid.UUID `json:"user_id" validate:"required"`
	Role   string    `json:"role" validate:"required,oneof=admin editor viewer"`
}

func (c Command) CommandName() string { return "UpdateSiteMemberRole" }

type Handler struct {
	repo     site.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo site.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.update_site_member_role"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "UpdateSiteMemberRole.Handle")
	defer span.End()

	role := site.SiteRole(c.Role)
	if !role.IsValid() {
		return &invalidRoleError{role: c.Role}
	}

	if err := h.repo.UpdateMemberRole(c.SiteID, c.UserID, role); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, site.SiteMemberRoleUpdated{
		SiteID: c.SiteID,
		UserID: c.UserID,
		Role:   role,
		Time:   time.Now(),
	})
}

type invalidRoleError struct{ role string }

func (e *invalidRoleError) Error() string { return "invalid role: " + e.role }

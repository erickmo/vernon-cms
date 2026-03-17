package updateuser

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/user"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type Command struct {
	ID    uuid.UUID `json:"id" validate:"required"`
	Email string    `json:"email" validate:"required,email"`
	Name  string    `json:"name" validate:"required"`
	Role  user.Role `json:"role" validate:"required,oneof=admin editor viewer"`
}

func (c Command) CommandName() string { return "UpdateUser" }

type Handler struct {
	repo     user.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo user.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.update_user"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "UpdateUser.Handle")
	defer span.End()

	u, err := h.repo.FindByID(c.ID)
	if err != nil {
		return err
	}

	if err := u.UpdateEmail(c.Email); err != nil {
		return err
	}
	if err := u.UpdateName(c.Name); err != nil {
		return err
	}
	u.UpdateRole(c.Role)

	if err := h.repo.Update(u); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, user.UserUpdated{
		UserID: u.ID,
		Email:  u.Email,
		Name:   u.Name,
		Time:   time.Now(),
	})
}

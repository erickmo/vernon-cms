package createuser

import (
	"context"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/user"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type Command struct {
	Email        string    `json:"email" validate:"required,email"`
	PasswordHash string    `json:"password_hash" validate:"required"`
	Name         string    `json:"name" validate:"required"`
	Role         user.Role `json:"role" validate:"required,oneof=admin editor viewer"`
}

func (c Command) CommandName() string { return "CreateUser" }

type Handler struct {
	repo     user.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo user.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.create_user"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "CreateUser.Handle")
	defer span.End()

	u, err := user.NewUser(c.Email, c.PasswordHash, c.Name, c.Role)
	if err != nil {
		return err
	}

	if err := h.repo.Save(u); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, user.UserCreated{
		UserID: u.ID,
		Email:  u.Email,
		Name:   u.Name,
		Role:   u.Role,
		Time:   time.Now(),
	})
}

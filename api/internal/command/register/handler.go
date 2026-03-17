package register

import (
	"context"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/user"
	"github.com/erickmo/vernon-cms/pkg/auth"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type Command struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=8"`
	Name     string `json:"name" validate:"required"`
}

func (c Command) CommandName() string { return "Register" }

type Result struct {
	UserID string `json:"user_id"`
}

type Handler struct {
	repo     user.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo user.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.register"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "Register.Handle")
	defer span.End()

	passwordHash, err := auth.HashPassword(c.Password)
	if err != nil {
		return err
	}

	u, err := user.NewUser(c.Email, passwordHash, c.Name, user.RoleViewer)
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

package deleteclient

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/client"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
)

type Command struct {
	ID uuid.UUID `json:"id" validate:"required"`
}

func (c Command) CommandName() string { return "DeleteClient" }

type Handler struct {
	repo client.WriteRepository
}

func NewHandler(repo client.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	// guard: check exists first
	if _, err := h.repo.FindByID(c.ID); err != nil {
		return err
	}
	return h.repo.Delete(c.ID)
}

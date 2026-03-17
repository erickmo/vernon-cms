package updateclient

import (
	"context"
	"time"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/client"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
)

type Command struct {
	ID      uuid.UUID `json:"id" validate:"required"`
	Name    string    `json:"name" validate:"required"`
	Email   string    `json:"email" validate:"required,email"`
	Phone   *string   `json:"phone"`
	Company *string   `json:"company"`
	Address *string   `json:"address"`
}

func (c Command) CommandName() string { return "UpdateClient" }

type Handler struct {
	repo client.WriteRepository
}

func NewHandler(repo client.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	cl, err := h.repo.FindByID(c.ID)
	if err != nil {
		return err
	}

	cl.Name = c.Name
	cl.Email = c.Email
	cl.Phone = c.Phone
	cl.Company = c.Company
	cl.Address = c.Address
	cl.UpdatedAt = time.Now()

	return h.repo.Update(cl)
}

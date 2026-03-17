package updateapitoken

import (
	"context"
	"time"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/apitoken"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	ID          uuid.UUID  `json:"id" validate:"required"`
	Name        string     `json:"name" validate:"required"`
	Permissions []string   `json:"permissions"`
	ExpiresAt   *time.Time `json:"expires_at"`
}

func (c Command) CommandName() string { return "UpdateAPIToken" }

type Handler struct {
	repo apitoken.WriteRepository
}

func NewHandler(repo apitoken.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	siteID := middleware.GetSiteID(ctx)

	t, err := h.repo.FindByID(c.ID, siteID)
	if err != nil {
		return err
	}
	t.Name = c.Name
	if c.Permissions != nil {
		t.Permissions = c.Permissions
	}
	t.ExpiresAt = c.ExpiresAt

	return h.repo.Update(t)
}

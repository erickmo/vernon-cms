package toggleapitoken

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/apitoken"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	ID uuid.UUID `json:"id" validate:"required"`
}

func (c Command) CommandName() string { return "ToggleAPIToken" }

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
	t.ToggleActive()
	return h.repo.Update(t)
}

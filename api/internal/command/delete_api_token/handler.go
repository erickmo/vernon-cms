package deleteapitoken

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

func (c Command) CommandName() string { return "DeleteAPIToken" }

type Handler struct {
	repo apitoken.WriteRepository
}

func NewHandler(repo apitoken.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	siteID := middleware.GetSiteID(ctx)
	return h.repo.Delete(c.ID, siteID)
}

package updatemedia

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/media"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	ID      uuid.UUID `json:"id" validate:"required"`
	Alt     *string   `json:"alt"`
	Caption *string   `json:"caption"`
	Folder  *string   `json:"folder"`
}

func (c Command) CommandName() string { return "UpdateMedia" }

type Handler struct {
	repo media.WriteRepository
}

func NewHandler(repo media.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	siteID := middleware.GetSiteID(ctx)

	m, err := h.repo.FindByID(c.ID, siteID)
	if err != nil {
		return err
	}
	m.Alt = c.Alt
	m.Caption = c.Caption
	m.Folder = c.Folder

	return h.repo.Update(m)
}

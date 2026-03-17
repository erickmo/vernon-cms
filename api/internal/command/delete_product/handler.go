package deleteproduct

import (
	"context"
	"time"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/product"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	ID uuid.UUID `json:"id" validate:"required"`
}

func (c Command) CommandName() string { return "DeleteProduct" }

type Handler struct {
	repo     product.WriteRepository
	eventBus eventbus.EventBus
}

func NewHandler(repo product.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{repo: repo, eventBus: eventBus}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	siteID := middleware.GetSiteID(ctx)

	if err := h.repo.Delete(c.ID, siteID); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, product.ProductDeleted{
		ProductID: c.ID,
		Time:      time.Now(),
	})
}

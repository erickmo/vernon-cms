package deleteproductcategory

import (
	"context"
	"time"

	"github.com/google/uuid"

	productcategory "github.com/erickmo/vernon-cms/internal/domain/product_category"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	ID uuid.UUID `json:"id" validate:"required"`
}

func (c Command) CommandName() string { return "DeleteProductCategory" }

type Handler struct {
	repo     productcategory.WriteRepository
	eventBus eventbus.EventBus
}

func NewHandler(repo productcategory.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{repo: repo, eventBus: eventBus}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	siteID := middleware.GetSiteID(ctx)

	if err := h.repo.Delete(c.ID, siteID); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, productcategory.ProductCategoryDeleted{
		CategoryID: c.ID,
		Time:       time.Now(),
	})
}

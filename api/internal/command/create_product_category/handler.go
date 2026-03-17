package createproductcategory

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
	ParentID    *uuid.UUID `json:"parent_id"`
	Name        string     `json:"name" validate:"required"`
	Slug        string     `json:"slug" validate:"required"`
	Description *string    `json:"description"`
}

func (c Command) CommandName() string { return "CreateProductCategory" }

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

	cat, err := productcategory.NewProductCategory(siteID, c.Name, c.Slug)
	if err != nil {
		return err
	}
	cat.ParentID = c.ParentID
	cat.Description = c.Description

	if err := h.repo.Save(cat); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, productcategory.ProductCategoryCreated{
		CategoryID: cat.ID,
		Name:       cat.Name,
		Slug:       cat.Slug,
		Time:       time.Now(),
	})
}

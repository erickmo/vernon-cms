package createproduct

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/product"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	CategoryID  *uuid.UUID      `json:"category_id"`
	Name        string          `json:"name" validate:"required"`
	Slug        string          `json:"slug" validate:"required"`
	Description string          `json:"description"`
	Price       float64         `json:"price" validate:"min=0"`
	Stock       *int            `json:"stock"`
	Images      json.RawMessage `json:"images"`
	Metadata    json.RawMessage `json:"metadata"`
}

func (c Command) CommandName() string { return "CreateProduct" }

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

	p, err := product.NewProduct(siteID, c.Name, c.Slug, c.Price)
	if err != nil {
		return err
	}
	p.CategoryID = c.CategoryID
	p.Description = c.Description
	p.Stock = c.Stock
	if c.Images != nil {
		p.Images = c.Images
	}
	if c.Metadata != nil {
		p.Metadata = c.Metadata
	}

	if err := h.repo.Save(p); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, product.ProductCreated{
		ProductID:  p.ID,
		Name:       p.Name,
		Slug:       p.Slug,
		CategoryID: p.CategoryID,
		Time:       time.Now(),
	})
}

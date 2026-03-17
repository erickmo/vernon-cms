package updateproduct

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
	ID          uuid.UUID       `json:"id" validate:"required"`
	CategoryID  *uuid.UUID      `json:"category_id"`
	Name        string          `json:"name" validate:"required"`
	Slug        string          `json:"slug" validate:"required"`
	Description string          `json:"description"`
	Price       float64         `json:"price" validate:"min=0"`
	Stock       *int            `json:"stock"`
	Images      json.RawMessage `json:"images"`
	Metadata    json.RawMessage `json:"metadata"`
	IsActive    bool            `json:"is_active"`
}

func (c Command) CommandName() string { return "UpdateProduct" }

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

	p, err := h.repo.FindByID(c.ID, siteID)
	if err != nil {
		return err
	}

	p.CategoryID = c.CategoryID
	p.Name = c.Name
	p.Slug = c.Slug
	p.Description = c.Description
	p.Price = c.Price
	p.Stock = c.Stock
	p.IsActive = c.IsActive
	p.UpdatedAt = time.Now()
	if c.Images != nil {
		p.Images = c.Images
	}
	if c.Metadata != nil {
		p.Metadata = c.Metadata
	}

	if err := h.repo.Update(p); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, product.ProductUpdated{
		ProductID: p.ID,
		Name:      p.Name,
		Slug:      p.Slug,
		Time:      time.Now(),
	})
}

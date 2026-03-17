package product

import (
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
)

type Product struct {
	ID          uuid.UUID       `json:"id" db:"id"`
	SiteID      uuid.UUID       `json:"site_id" db:"site_id"`
	CategoryID  *uuid.UUID      `json:"category_id,omitempty" db:"category_id"`
	Name        string          `json:"name" db:"name"`
	Slug        string          `json:"slug" db:"slug"`
	Description string          `json:"description" db:"description"`
	Price       float64         `json:"price" db:"price"`
	Stock       *int            `json:"stock,omitempty" db:"stock"`
	Images      json.RawMessage `json:"images" db:"images"`
	Metadata    json.RawMessage `json:"metadata" db:"metadata"`
	IsActive    bool            `json:"is_active" db:"is_active"`
	CreatedAt   time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at" db:"updated_at"`
}

func NewProduct(siteID uuid.UUID, name, slug string, price float64) (*Product, error) {
	if name == "" {
		return nil, errors.New("product name is required")
	}
	if slug == "" {
		return nil, errors.New("product slug is required")
	}
	if price < 0 {
		return nil, errors.New("product price cannot be negative")
	}
	now := time.Now()
	return &Product{
		ID:        uuid.New(),
		SiteID:    siteID,
		Name:      name,
		Slug:      slug,
		Price:     price,
		Images:    json.RawMessage(`[]`),
		Metadata:  json.RawMessage(`{}`),
		IsActive:  true,
		CreatedAt: now,
		UpdatedAt: now,
	}, nil
}

func (p *Product) Deactivate() {
	p.IsActive = false
	p.UpdatedAt = time.Now()
}

func (p *Product) Activate() {
	p.IsActive = true
	p.UpdatedAt = time.Now()
}

type WriteRepository interface {
	Save(p *Product) error
	Update(p *Product) error
	Delete(id, siteID uuid.UUID) error
	FindByID(id, siteID uuid.UUID) (*Product, error)
}

type ReadRepository interface {
	FindByID(id, siteID uuid.UUID) (*Product, error)
	FindBySlug(slug string, siteID uuid.UUID) (*Product, error)
	FindAll(siteID uuid.UUID, search string, categoryID *uuid.UUID, offset, limit int) ([]*Product, int, error)
}

package productcategory

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

type ProductCategory struct {
	ID          uuid.UUID  `json:"id" db:"id"`
	SiteID      uuid.UUID  `json:"site_id" db:"site_id"`
	ParentID    *uuid.UUID `json:"parent_id,omitempty" db:"parent_id"`
	Name        string     `json:"name" db:"name"`
	Slug        string     `json:"slug" db:"slug"`
	Description *string    `json:"description,omitempty" db:"description"`
	CreatedAt   time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at" db:"updated_at"`
}

func NewProductCategory(siteID uuid.UUID, name, slug string) (*ProductCategory, error) {
	if name == "" {
		return nil, errors.New("category name is required")
	}
	if slug == "" {
		return nil, errors.New("category slug is required")
	}
	now := time.Now()
	return &ProductCategory{
		ID:        uuid.New(),
		SiteID:    siteID,
		Name:      name,
		Slug:      slug,
		CreatedAt: now,
		UpdatedAt: now,
	}, nil
}

func (c *ProductCategory) Update(name, slug string) error {
	if name == "" {
		return errors.New("category name is required")
	}
	if slug == "" {
		return errors.New("category slug is required")
	}
	c.Name = name
	c.Slug = slug
	c.UpdatedAt = time.Now()
	return nil
}

type WriteRepository interface {
	Save(c *ProductCategory) error
	Update(c *ProductCategory) error
	Delete(id, siteID uuid.UUID) error
	FindByID(id, siteID uuid.UUID) (*ProductCategory, error)
}

type ReadRepository interface {
	FindByID(id, siteID uuid.UUID) (*ProductCategory, error)
	FindAll(siteID uuid.UUID, offset, limit int) ([]*ProductCategory, int, error)
}

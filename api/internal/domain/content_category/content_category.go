package contentcategory

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

type ContentCategory struct {
	ID        uuid.UUID `json:"id" db:"id"`
	SiteID    uuid.UUID `json:"site_id" db:"site_id"`
	Name      string    `json:"name" db:"name"`
	Slug      string    `json:"slug" db:"slug"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

func NewContentCategory(siteID uuid.UUID, name, slug string) (*ContentCategory, error) {
	if name == "" {
		return nil, errors.New("category name is required")
	}
	if slug == "" {
		return nil, errors.New("category slug is required")
	}

	now := time.Now()
	return &ContentCategory{
		ID:        uuid.New(),
		SiteID:    siteID,
		Name:      name,
		Slug:      slug,
		CreatedAt: now,
		UpdatedAt: now,
	}, nil
}

func (c *ContentCategory) UpdateName(name string) error {
	if name == "" {
		return errors.New("category name is required")
	}
	c.Name = name
	c.UpdatedAt = time.Now()
	return nil
}

func (c *ContentCategory) UpdateSlug(slug string) error {
	if slug == "" {
		return errors.New("category slug is required")
	}
	c.Slug = slug
	c.UpdatedAt = time.Now()
	return nil
}

type WriteRepository interface {
	Save(category *ContentCategory) error
	Update(category *ContentCategory) error
	Delete(id, siteID uuid.UUID) error
	FindByID(id, siteID uuid.UUID) (*ContentCategory, error)
}

type ReadRepository interface {
	FindByID(id, siteID uuid.UUID) (*ContentCategory, error)
	FindBySlug(slug string, siteID uuid.UUID) (*ContentCategory, error)
	FindAll(siteID uuid.UUID, offset, limit int) ([]*ContentCategory, int, error)
}

package page

import (
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
)

type Page struct {
	ID        uuid.UUID       `json:"id" db:"id"`
	SiteID    uuid.UUID       `json:"site_id" db:"site_id"`
	Name      string          `json:"name" db:"name"`
	Slug      string          `json:"slug" db:"slug"`
	Variables json.RawMessage `json:"variables" db:"variables"`
	IsActive  bool            `json:"is_active" db:"is_active"`
	CreatedAt time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt time.Time       `json:"updated_at" db:"updated_at"`
}

func NewPage(siteID uuid.UUID, name, slug string, variables json.RawMessage) (*Page, error) {
	if name == "" {
		return nil, errors.New("page name is required")
	}
	if slug == "" {
		return nil, errors.New("page slug is required")
	}
	if variables == nil {
		variables = json.RawMessage(`{}`)
	}

	now := time.Now()
	return &Page{
		ID:        uuid.New(),
		SiteID:    siteID,
		Name:      name,
		Slug:      slug,
		Variables: variables,
		IsActive:  true,
		CreatedAt: now,
		UpdatedAt: now,
	}, nil
}

func (p *Page) UpdateName(name string) error {
	if name == "" {
		return errors.New("page name is required")
	}
	p.Name = name
	p.UpdatedAt = time.Now()
	return nil
}

func (p *Page) UpdateSlug(slug string) error {
	if slug == "" {
		return errors.New("page slug is required")
	}
	p.Slug = slug
	p.UpdatedAt = time.Now()
	return nil
}

func (p *Page) UpdateVariables(variables json.RawMessage) {
	p.Variables = variables
	p.UpdatedAt = time.Now()
}

func (p *Page) SetActive(active bool) {
	p.IsActive = active
	p.UpdatedAt = time.Now()
}

type WriteRepository interface {
	Save(page *Page) error
	Update(page *Page) error
	Delete(id, siteID uuid.UUID) error
	FindByID(id, siteID uuid.UUID) (*Page, error)
}

type ReadRepository interface {
	FindByID(id, siteID uuid.UUID) (*Page, error)
	FindBySlug(slug string, siteID uuid.UUID) (*Page, error)
	FindAll(siteID uuid.UUID, offset, limit int) ([]*Page, int, error)
}

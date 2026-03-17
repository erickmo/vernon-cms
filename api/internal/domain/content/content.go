package content

import (
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
)

type Status string

const (
	StatusDraft     Status = "draft"
	StatusPublished Status = "published"
	StatusArchived  Status = "archived"
)

type Content struct {
	ID          uuid.UUID       `json:"id" db:"id"`
	SiteID      uuid.UUID       `json:"site_id" db:"site_id"`
	Title       string          `json:"title" db:"title"`
	Slug        string          `json:"slug" db:"slug"`
	Body        string          `json:"body" db:"body"`
	Excerpt     string          `json:"excerpt" db:"excerpt"`
	Status      Status          `json:"status" db:"status"`
	PageID      uuid.UUID       `json:"page_id" db:"page_id"`
	CategoryID  uuid.UUID       `json:"category_id" db:"category_id"`
	AuthorID    uuid.UUID       `json:"author_id" db:"author_id"`
	Metadata    json.RawMessage `json:"metadata" db:"metadata"`
	PublishedAt *time.Time      `json:"published_at,omitempty" db:"published_at"`
	CreatedAt   time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at" db:"updated_at"`
}

func NewContent(siteID uuid.UUID, title, slug, body, excerpt string, pageID, categoryID, authorID uuid.UUID, metadata json.RawMessage) (*Content, error) {
	if title == "" {
		return nil, errors.New("content title is required")
	}
	if slug == "" {
		return nil, errors.New("content slug is required")
	}
	if metadata == nil {
		metadata = json.RawMessage(`{}`)
	}

	now := time.Now()
	return &Content{
		ID:         uuid.New(),
		SiteID:     siteID,
		Title:      title,
		Slug:       slug,
		Body:       body,
		Excerpt:    excerpt,
		Status:     StatusDraft,
		PageID:     pageID,
		CategoryID: categoryID,
		AuthorID:   authorID,
		Metadata:   metadata,
		CreatedAt:  now,
		UpdatedAt:  now,
	}, nil
}

func (c *Content) UpdateTitle(title string) error {
	if title == "" {
		return errors.New("content title is required")
	}
	c.Title = title
	c.UpdatedAt = time.Now()
	return nil
}

func (c *Content) UpdateSlug(slug string) error {
	if slug == "" {
		return errors.New("content slug is required")
	}
	c.Slug = slug
	c.UpdatedAt = time.Now()
	return nil
}

func (c *Content) UpdateBody(body, excerpt string) {
	c.Body = body
	c.Excerpt = excerpt
	c.UpdatedAt = time.Now()
}

func (c *Content) UpdateMetadata(metadata json.RawMessage) {
	c.Metadata = metadata
	c.UpdatedAt = time.Now()
}

func (c *Content) Publish() error {
	if c.Status == StatusPublished {
		return errors.New("content is already published")
	}
	now := time.Now()
	c.Status = StatusPublished
	c.PublishedAt = &now
	c.UpdatedAt = now
	return nil
}

func (c *Content) Archive() {
	c.Status = StatusArchived
	c.UpdatedAt = time.Now()
}

func (c *Content) ToDraft() {
	c.Status = StatusDraft
	c.PublishedAt = nil
	c.UpdatedAt = time.Now()
}

type WriteRepository interface {
	Save(content *Content) error
	Update(content *Content) error
	Delete(id, siteID uuid.UUID) error
	FindByID(id, siteID uuid.UUID) (*Content, error)
}

type ReadRepository interface {
	FindByID(id, siteID uuid.UUID) (*Content, error)
	FindBySlug(slug string, siteID uuid.UUID) (*Content, error)
	FindAll(siteID uuid.UUID, offset, limit int) ([]*Content, int, error)
	FindByPageID(pageID, siteID uuid.UUID, offset, limit int) ([]*Content, int, error)
	FindByCategoryID(categoryID, siteID uuid.UUID, offset, limit int) ([]*Content, int, error)
}

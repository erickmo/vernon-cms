package content

import (
	"time"

	"github.com/google/uuid"
)

type ContentCreated struct {
	ContentID  uuid.UUID `json:"content_id"`
	Title      string    `json:"title"`
	Slug       string    `json:"slug"`
	AuthorID   uuid.UUID `json:"author_id"`
	CategoryID uuid.UUID `json:"category_id"`
	PageID     uuid.UUID `json:"page_id"`
	Time       time.Time `json:"time"`
}

func (e ContentCreated) EventName() string    { return "content.created" }
func (e ContentCreated) OccurredAt() time.Time { return e.Time }

type ContentUpdated struct {
	ContentID uuid.UUID `json:"content_id"`
	Title     string    `json:"title"`
	Slug      string    `json:"slug"`
	Time      time.Time `json:"time"`
}

func (e ContentUpdated) EventName() string    { return "content.updated" }
func (e ContentUpdated) OccurredAt() time.Time { return e.Time }

type ContentPublished struct {
	ContentID uuid.UUID `json:"content_id"`
	Title     string    `json:"title"`
	Slug      string    `json:"slug"`
	Time      time.Time `json:"time"`
}

func (e ContentPublished) EventName() string    { return "content.published" }
func (e ContentPublished) OccurredAt() time.Time { return e.Time }

type ContentDeleted struct {
	ContentID uuid.UUID `json:"content_id"`
	Time      time.Time `json:"time"`
}

func (e ContentDeleted) EventName() string    { return "content.deleted" }
func (e ContentDeleted) OccurredAt() time.Time { return e.Time }

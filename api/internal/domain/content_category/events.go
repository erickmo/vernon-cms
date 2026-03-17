package contentcategory

import (
	"time"

	"github.com/google/uuid"
)

type ContentCategoryCreated struct {
	CategoryID uuid.UUID `json:"category_id"`
	Name       string    `json:"name"`
	Slug       string    `json:"slug"`
	Time       time.Time `json:"time"`
}

func (e ContentCategoryCreated) EventName() string    { return "content_category.created" }
func (e ContentCategoryCreated) OccurredAt() time.Time { return e.Time }

type ContentCategoryUpdated struct {
	CategoryID uuid.UUID `json:"category_id"`
	Name       string    `json:"name"`
	Slug       string    `json:"slug"`
	Time       time.Time `json:"time"`
}

func (e ContentCategoryUpdated) EventName() string    { return "content_category.updated" }
func (e ContentCategoryUpdated) OccurredAt() time.Time { return e.Time }

type ContentCategoryDeleted struct {
	CategoryID uuid.UUID `json:"category_id"`
	Time       time.Time `json:"time"`
}

func (e ContentCategoryDeleted) EventName() string    { return "content_category.deleted" }
func (e ContentCategoryDeleted) OccurredAt() time.Time { return e.Time }

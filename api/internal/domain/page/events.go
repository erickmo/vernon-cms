package page

import (
	"time"

	"github.com/google/uuid"
)

type PageCreated struct {
	PageID uuid.UUID `json:"page_id"`
	Name   string    `json:"name"`
	Slug   string    `json:"slug"`
	Time   time.Time `json:"time"`
}

func (e PageCreated) EventName() string    { return "page.created" }
func (e PageCreated) OccurredAt() time.Time { return e.Time }

type PageUpdated struct {
	PageID uuid.UUID `json:"page_id"`
	Name   string    `json:"name"`
	Slug   string    `json:"slug"`
	Time   time.Time `json:"time"`
}

func (e PageUpdated) EventName() string    { return "page.updated" }
func (e PageUpdated) OccurredAt() time.Time { return e.Time }

type PageDeleted struct {
	PageID uuid.UUID `json:"page_id"`
	Time   time.Time `json:"time"`
}

func (e PageDeleted) EventName() string    { return "page.deleted" }
func (e PageDeleted) OccurredAt() time.Time { return e.Time }

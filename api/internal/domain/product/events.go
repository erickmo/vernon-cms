package product

import (
	"time"

	"github.com/google/uuid"
)

type ProductCreated struct {
	ProductID  uuid.UUID  `json:"product_id"`
	Name       string     `json:"name"`
	Slug       string     `json:"slug"`
	CategoryID *uuid.UUID `json:"category_id,omitempty"`
	Time       time.Time  `json:"time"`
}

func (e ProductCreated) EventName() string     { return "product.created" }
func (e ProductCreated) OccurredAt() time.Time { return e.Time }

type ProductUpdated struct {
	ProductID uuid.UUID `json:"product_id"`
	Name      string    `json:"name"`
	Slug      string    `json:"slug"`
	Time      time.Time `json:"time"`
}

func (e ProductUpdated) EventName() string     { return "product.updated" }
func (e ProductUpdated) OccurredAt() time.Time { return e.Time }

type ProductDeleted struct {
	ProductID uuid.UUID `json:"product_id"`
	Time      time.Time `json:"time"`
}

func (e ProductDeleted) EventName() string     { return "product.deleted" }
func (e ProductDeleted) OccurredAt() time.Time { return e.Time }

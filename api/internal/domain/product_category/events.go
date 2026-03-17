package productcategory

import (
	"time"

	"github.com/google/uuid"
)

type ProductCategoryCreated struct {
	CategoryID uuid.UUID `json:"category_id"`
	Name       string    `json:"name"`
	Slug       string    `json:"slug"`
	Time       time.Time `json:"time"`
}

func (e ProductCategoryCreated) EventName() string     { return "product_category.created" }
func (e ProductCategoryCreated) OccurredAt() time.Time { return e.Time }

type ProductCategoryUpdated struct {
	CategoryID uuid.UUID `json:"category_id"`
	Name       string    `json:"name"`
	Slug       string    `json:"slug"`
	Time       time.Time `json:"time"`
}

func (e ProductCategoryUpdated) EventName() string     { return "product_category.updated" }
func (e ProductCategoryUpdated) OccurredAt() time.Time { return e.Time }

type ProductCategoryDeleted struct {
	CategoryID uuid.UUID `json:"category_id"`
	Time       time.Time `json:"time"`
}

func (e ProductCategoryDeleted) EventName() string     { return "product_category.deleted" }
func (e ProductCategoryDeleted) OccurredAt() time.Time { return e.Time }

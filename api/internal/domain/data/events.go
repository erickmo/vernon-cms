package data

import (
	"time"

	"github.com/google/uuid"
)

type DataCreated struct {
	DataTypeID uuid.UUID `json:"data_type_id"`
	Name       string    `json:"name"`
	Slug       string    `json:"slug"`
	Time       time.Time `json:"time"`
}

func (e DataCreated) EventName() string    { return "data.created" }
func (e DataCreated) OccurredAt() time.Time { return e.Time }

type DataUpdated struct {
	DataTypeID uuid.UUID `json:"data_type_id"`
	Name       string    `json:"name"`
	Slug       string    `json:"slug"`
	Time       time.Time `json:"time"`
}

func (e DataUpdated) EventName() string    { return "data.updated" }
func (e DataUpdated) OccurredAt() time.Time { return e.Time }

type DataDeleted struct {
	DataTypeID uuid.UUID `json:"data_type_id"`
	Time       time.Time `json:"time"`
}

func (e DataDeleted) EventName() string    { return "data.deleted" }
func (e DataDeleted) OccurredAt() time.Time { return e.Time }

type DataRecordCreated struct {
	RecordID uuid.UUID `json:"record_id"`
	DataSlug string    `json:"data_slug"`
	Time     time.Time `json:"time"`
}

func (e DataRecordCreated) EventName() string    { return "data_record.created" }
func (e DataRecordCreated) OccurredAt() time.Time { return e.Time }

type DataRecordUpdated struct {
	RecordID uuid.UUID `json:"record_id"`
	DataSlug string    `json:"data_slug"`
	Time     time.Time `json:"time"`
}

func (e DataRecordUpdated) EventName() string    { return "data_record.updated" }
func (e DataRecordUpdated) OccurredAt() time.Time { return e.Time }

type DataRecordDeleted struct {
	RecordID uuid.UUID `json:"record_id"`
	DataSlug string    `json:"data_slug"`
	Time     time.Time `json:"time"`
}

func (e DataRecordDeleted) EventName() string    { return "data_record.deleted" }
func (e DataRecordDeleted) OccurredAt() time.Time { return e.Time }

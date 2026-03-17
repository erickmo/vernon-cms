package data

import (
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
)

type FieldType string

const (
	FieldTypeText     FieldType = "text"
	FieldTypeTextarea FieldType = "textarea"
	FieldTypeNumber   FieldType = "number"
	FieldTypeEmail    FieldType = "email"
	FieldTypeURL      FieldType = "url"
	FieldTypePhone    FieldType = "phone"
	FieldTypeDate     FieldType = "date"
	FieldTypeSelect   FieldType = "select"
	FieldTypeCheckbox FieldType = "checkbox"
	FieldTypeImageURL FieldType = "image_url"
	FieldTypeRichText FieldType = "rich_text"
	FieldTypeRelation FieldType = "relation"
)

var ValidFieldTypes = map[FieldType]bool{
	FieldTypeText: true, FieldTypeTextarea: true, FieldTypeNumber: true,
	FieldTypeEmail: true, FieldTypeURL: true, FieldTypePhone: true,
	FieldTypeDate: true, FieldTypeSelect: true, FieldTypeCheckbox: true,
	FieldTypeImageURL: true, FieldTypeRichText: true, FieldTypeRelation: true,
}

type SelectOption struct {
	Label string `json:"label"`
	Value string `json:"value"`
}

type DataField struct {
	ID              uuid.UUID       `json:"id" db:"id"`
	DataTypeID      uuid.UUID       `json:"-" db:"data_type_id"`
	Name            string          `json:"name" db:"name"`
	Label           string          `json:"label" db:"label"`
	FieldType       FieldType       `json:"field_type" db:"field_type"`
	IsRequired      bool            `json:"is_required" db:"is_required"`
	DefaultValue    *string         `json:"default_value" db:"default_value"`
	Placeholder     *string         `json:"placeholder" db:"placeholder"`
	HelpText        *string         `json:"help_text" db:"help_text"`
	SortOrder       int             `json:"sort_order" db:"sort_order"`
	Options         json.RawMessage `json:"options" db:"options"`
	RelatedDataSlug *string         `json:"related_data_slug" db:"related_data_slug"`
	RelatedDataID   *uuid.UUID      `json:"related_data_id" db:"related_data_id"`
}

type DataType struct {
	ID             uuid.UUID    `json:"id" db:"id"`
	SiteID         uuid.UUID    `json:"site_id" db:"site_id"`
	Name           string       `json:"name" db:"name"`
	Slug           string       `json:"slug" db:"slug"`
	Description    *string      `json:"description" db:"description"`
	Icon           *string      `json:"icon" db:"icon"`
	PluralName     string       `json:"plural_name" db:"plural_name"`
	SidebarSection string       `json:"sidebar_section" db:"sidebar_section"`
	SidebarOrder   int          `json:"sidebar_order" db:"sidebar_order"`
	Fields         []*DataField `json:"fields" db:"-"`
	CreatedAt      time.Time    `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time    `json:"updated_at" db:"updated_at"`
}

func NewDataType(siteID uuid.UUID, name, slug, pluralName, sidebarSection string, sidebarOrder int, description, icon *string) (*DataType, error) {
	if name == "" {
		return nil, errors.New("domain name is required")
	}
	if slug == "" {
		return nil, errors.New("domain slug is required")
	}
	if pluralName == "" {
		return nil, errors.New("domain plural_name is required")
	}
	if sidebarSection == "" {
		sidebarSection = "content"
	}

	now := time.Now()
	return &DataType{
		ID:             uuid.New(),
		SiteID:         siteID,
		Name:           name,
		Slug:           slug,
		Description:    description,
		Icon:           icon,
		PluralName:     pluralName,
		SidebarSection: sidebarSection,
		SidebarOrder:   sidebarOrder,
		Fields:         make([]*DataField, 0),
		CreatedAt:      now,
		UpdatedAt:      now,
	}, nil
}

func NewDataField(dataTypeID uuid.UUID, name, label string, fieldType FieldType, isRequired bool, sortOrder int) (*DataField, error) {
	if name == "" {
		return nil, errors.New("field name is required")
	}
	if label == "" {
		return nil, errors.New("field label is required")
	}
	if !ValidFieldTypes[fieldType] {
		return nil, errors.New("invalid field type: " + string(fieldType))
	}

	return &DataField{
		ID:         uuid.New(),
		DataTypeID: dataTypeID,
		Name:       name,
		Label:      label,
		FieldType:  fieldType,
		IsRequired: isRequired,
		SortOrder:  sortOrder,
		Options:    json.RawMessage(`[]`),
	}, nil
}

type DataRecord struct {
	ID         uuid.UUID       `json:"id" db:"id"`
	SiteID     uuid.UUID       `json:"site_id" db:"site_id"`
	DataTypeID uuid.UUID       `json:"-" db:"data_type_id"`
	DataSlug   string          `json:"data_slug" db:"data_slug"`
	Data       json.RawMessage `json:"data" db:"data"`
	CreatedAt  time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt  time.Time       `json:"updated_at" db:"updated_at"`
}

type RecordOption struct {
	ID    uuid.UUID `json:"id"`
	Label string    `json:"label"`
}

type DataWriteRepository interface {
	SaveDataType(dataType *DataType) error
	UpdateDataType(dataType *DataType) error
	DeleteDataType(id, siteID uuid.UUID) error
	FindDataTypeByID(id, siteID uuid.UUID) (*DataType, error)
	FindDataTypeBySlug(slug string, siteID uuid.UUID) (*DataType, error)
	SaveFields(dataTypeID uuid.UUID, fields []*DataField) error
	ReplaceFields(dataTypeID uuid.UUID, fields []*DataField) error
	SaveRecord(record *DataRecord) error
	UpdateRecord(record *DataRecord) error
	DeleteRecord(id uuid.UUID) error
}

type DataReadRepository interface {
	FindDataTypeByID(id, siteID uuid.UUID) (*DataType, error)
	FindDataTypeBySlug(slug string, siteID uuid.UUID) (*DataType, error)
	FindAllDataTypes(siteID uuid.UUID, offset, limit int) ([]*DataType, int, error)
	FindFieldsByDataTypeID(dataTypeID uuid.UUID) ([]*DataField, error)
	FindRecordByID(id, siteID uuid.UUID) (*DataRecord, error)
	FindRecordsByDataSlug(dataSlug string, siteID uuid.UUID, search string, offset, limit int) ([]*DataRecord, int, error)
	FindRecordOptions(dataSlug string, siteID uuid.UUID) ([]*RecordOption, error)
}

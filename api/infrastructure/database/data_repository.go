package database

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	data "github.com/erickmo/vernon-cms/internal/domain/data"
)

type DataRepository struct {
	db *sqlx.DB
}

func NewDataRepository(db *sqlx.DB) *DataRepository {
	return &DataRepository{db: db}
}

// --- DataType CRUD (WriteRepository) ---

func (r *DataRepository) SaveDataType(d *data.DataType) error {
	query := `INSERT INTO data_types (id, site_id, name, slug, description, icon, plural_name, sidebar_section, sidebar_order, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`
	_, err := r.db.Exec(query, d.ID, d.SiteID, d.Name, d.Slug, d.Description, d.Icon, d.PluralName, d.SidebarSection, d.SidebarOrder, d.CreatedAt, d.UpdatedAt)
	return err
}

func (r *DataRepository) UpdateDataType(d *data.DataType) error {
	query := `UPDATE data_types SET name=$1, slug=$2, description=$3, icon=$4, plural_name=$5, sidebar_section=$6, sidebar_order=$7, updated_at=$8 WHERE id=$9`
	result, err := r.db.Exec(query, d.Name, d.Slug, d.Description, d.Icon, d.PluralName, d.SidebarSection, d.SidebarOrder, d.UpdatedAt, d.ID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("domain not found: %s", d.ID)
	}
	return nil
}

func (r *DataRepository) DeleteDataType(id, siteID uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM data_types WHERE id = $1 AND site_id = $2`, id, siteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("domain not found: %s", id)
	}
	return nil
}

// FindDataTypeByID for WriteRepository — site-scoped
func (r *DataRepository) FindDataTypeByID(id, siteID uuid.UUID) (*data.DataType, error) {
	return r.FindDataTypeByIDScoped(id, siteID)
}

// FindDataTypeBySlug for WriteRepository — site-scoped
func (r *DataRepository) FindDataTypeBySlug(slug string, siteID uuid.UUID) (*data.DataType, error) {
	return r.FindDataTypeBySlugScoped(slug, siteID)
}

// --- Site-scoped read helpers ---

func (r *DataRepository) FindDataTypeByIDScoped(id, siteID uuid.UUID) (*data.DataType, error) {
	var d data.DataType
	err := r.db.Get(&d, `SELECT * FROM data_types WHERE id = $1 AND site_id = $2`, id, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("domain not found: %s", id)
	}
	if err != nil {
		return nil, err
	}
	fields, err := r.FindFieldsByDataTypeID(d.ID)
	if err != nil {
		return nil, err
	}
	d.Fields = fields
	return &d, nil
}

func (r *DataRepository) FindDataTypeBySlugScoped(slug string, siteID uuid.UUID) (*data.DataType, error) {
	var d data.DataType
	err := r.db.Get(&d, `SELECT * FROM data_types WHERE slug = $1 AND site_id = $2`, slug, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("domain not found: %s", slug)
	}
	if err != nil {
		return nil, err
	}
	fields, err := r.FindFieldsByDataTypeID(d.ID)
	if err != nil {
		return nil, err
	}
	d.Fields = fields
	return &d, nil
}

func (r *DataRepository) FindAllDataTypes(siteID uuid.UUID, offset, limit int) ([]*data.DataType, int, error) {
	var total int
	err := r.db.Get(&total, `SELECT COUNT(*) FROM data_types WHERE site_id = $1`, siteID)
	if err != nil {
		return nil, 0, err
	}

	var dataTypes []*data.DataType
	err = r.db.Select(&dataTypes, `SELECT * FROM data_types WHERE site_id = $1 ORDER BY sidebar_section, sidebar_order, name LIMIT $2 OFFSET $3`, siteID, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	for _, d := range dataTypes {
		fields, err := r.FindFieldsByDataTypeID(d.ID)
		if err != nil {
			return nil, 0, err
		}
		d.Fields = fields
	}

	return dataTypes, total, nil
}

// --- Field CRUD ---

func (r *DataRepository) FindFieldsByDataTypeID(dataTypeID uuid.UUID) ([]*data.DataField, error) {
	var fields []*data.DataField
	err := r.db.Select(&fields, `SELECT * FROM data_fields WHERE data_type_id = $1 ORDER BY sort_order`, dataTypeID)
	if err != nil {
		return nil, err
	}
	if fields == nil {
		fields = make([]*data.DataField, 0)
	}
	for _, f := range fields {
		if f.Options == nil {
			f.Options = json.RawMessage(`[]`)
		}
	}
	return fields, nil
}

func (r *DataRepository) SaveFields(dataTypeID uuid.UUID, fields []*data.DataField) error {
	for _, f := range fields {
		query := `INSERT INTO data_fields (id, data_type_id, name, label, field_type, is_required, default_value, placeholder, help_text, sort_order, options, related_data_id, related_data_slug)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`
		opts := f.Options
		if opts == nil {
			opts = json.RawMessage(`[]`)
		}
		_, err := r.db.Exec(query, f.ID, dataTypeID, f.Name, f.Label, f.FieldType, f.IsRequired, f.DefaultValue, f.Placeholder, f.HelpText, f.SortOrder, opts, f.RelatedDataID, f.RelatedDataSlug)
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *DataRepository) ReplaceFields(dataTypeID uuid.UUID, fields []*data.DataField) error {
	tx, err := r.db.Beginx()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	_, err = tx.Exec(`DELETE FROM data_fields WHERE data_type_id = $1`, dataTypeID)
	if err != nil {
		return err
	}

	for _, f := range fields {
		opts := f.Options
		if opts == nil {
			opts = json.RawMessage(`[]`)
		}
		query := `INSERT INTO data_fields (id, data_type_id, name, label, field_type, is_required, default_value, placeholder, help_text, sort_order, options, related_data_id, related_data_slug)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`
		_, err := tx.Exec(query, f.ID, dataTypeID, f.Name, f.Label, f.FieldType, f.IsRequired, f.DefaultValue, f.Placeholder, f.HelpText, f.SortOrder, opts, f.RelatedDataID, f.RelatedDataSlug)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

// --- Record CRUD ---

func (r *DataRepository) SaveRecord(rec *data.DataRecord) error {
	query := `INSERT INTO data_records (id, site_id, data_type_id, data_slug, data, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`
	_, err := r.db.Exec(query, rec.ID, rec.SiteID, rec.DataTypeID, rec.DataSlug, rec.Data, rec.CreatedAt, rec.UpdatedAt)
	return err
}

func (r *DataRepository) UpdateRecord(rec *data.DataRecord) error {
	query := `UPDATE data_records SET data=$1, updated_at=$2 WHERE id=$3`
	result, err := r.db.Exec(query, rec.Data, rec.UpdatedAt, rec.ID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("domain record not found: %s", rec.ID)
	}
	return nil
}

func (r *DataRepository) DeleteRecord(id uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM data_records WHERE id = $1`, id)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("domain record not found: %s", id)
	}
	return nil
}

func (r *DataRepository) FindRecordByIDScoped(id, siteID uuid.UUID) (*data.DataRecord, error) {
	var rec data.DataRecord
	err := r.db.Get(&rec, `SELECT * FROM data_records WHERE id = $1 AND site_id = $2`, id, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("domain record not found: %s", id)
	}
	return &rec, err
}

func (r *DataRepository) FindRecordsByDataSlug(dataSlug string, siteID uuid.UUID, search string, offset, limit int) ([]*data.DataRecord, int, error) {
	var total int
	var records []*data.DataRecord

	if search != "" {
		searchPattern := "%" + strings.ToLower(search) + "%"
		err := r.db.Get(&total, `SELECT COUNT(*) FROM data_records WHERE data_slug = $1 AND site_id = $2 AND LOWER(data::text) LIKE $3`, dataSlug, siteID, searchPattern)
		if err != nil {
			return nil, 0, err
		}
		err = r.db.Select(&records, `SELECT * FROM data_records WHERE data_slug = $1 AND site_id = $2 AND LOWER(data::text) LIKE $3 ORDER BY created_at DESC LIMIT $4 OFFSET $5`, dataSlug, siteID, searchPattern, limit, offset)
		if err != nil {
			return nil, 0, err
		}
	} else {
		err := r.db.Get(&total, `SELECT COUNT(*) FROM data_records WHERE data_slug = $1 AND site_id = $2`, dataSlug, siteID)
		if err != nil {
			return nil, 0, err
		}
		err = r.db.Select(&records, `SELECT * FROM data_records WHERE data_slug = $1 AND site_id = $2 ORDER BY created_at DESC LIMIT $3 OFFSET $4`, dataSlug, siteID, limit, offset)
		if err != nil {
			return nil, 0, err
		}
	}

	if records == nil {
		records = make([]*data.DataRecord, 0)
	}
	return records, total, nil
}

func (r *DataRepository) FindRecordOptions(dataSlug string, siteID uuid.UUID) ([]*data.RecordOption, error) {
	var d data.DataType
	err := r.db.Get(&d, `SELECT * FROM data_types WHERE slug = $1 AND site_id = $2`, dataSlug, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("domain not found: %s", dataSlug)
	}
	if err != nil {
		return nil, err
	}

	var labelField string
	var fields []*data.DataField
	err = r.db.Select(&fields, `SELECT * FROM data_fields WHERE data_type_id = $1 ORDER BY sort_order`, d.ID)
	if err != nil {
		return nil, err
	}

	for _, f := range fields {
		if f.FieldType == data.FieldTypeText && f.IsRequired {
			labelField = f.Name
			break
		}
	}
	if labelField == "" && len(fields) > 0 {
		labelField = fields[0].Name
	}
	if labelField == "" {
		labelField = "id"
	}

	var records []*data.DataRecord
	err = r.db.Select(&records, `SELECT * FROM data_records WHERE data_slug = $1 AND site_id = $2 ORDER BY created_at`, dataSlug, siteID)
	if err != nil {
		return nil, err
	}

	options := make([]*data.RecordOption, 0, len(records))
	for _, rec := range records {
		label := ""
		if labelField != "id" {
			var dataMap map[string]interface{}
			if err := json.Unmarshal(rec.Data, &dataMap); err == nil {
				if v, ok := dataMap[labelField]; ok {
					label = fmt.Sprintf("%v", v)
				}
			}
		}
		if label == "" {
			label = rec.ID.String()
		}
		options = append(options, &data.RecordOption{
			ID:    rec.ID,
			Label: label,
		})
	}

	return options, nil
}

// DataReadRepository wraps DataRepository and implements data.DataReadRepository.
type DataReadRepository struct {
	repo *DataRepository
}

func NewDataReadRepository(repo *DataRepository) *DataReadRepository {
	return &DataReadRepository{repo: repo}
}

func (r *DataReadRepository) FindDataTypeByID(id, siteID uuid.UUID) (*data.DataType, error) {
	return r.repo.FindDataTypeByIDScoped(id, siteID)
}

func (r *DataReadRepository) FindDataTypeBySlug(slug string, siteID uuid.UUID) (*data.DataType, error) {
	return r.repo.FindDataTypeBySlugScoped(slug, siteID)
}

func (r *DataReadRepository) FindAllDataTypes(siteID uuid.UUID, offset, limit int) ([]*data.DataType, int, error) {
	return r.repo.FindAllDataTypes(siteID, offset, limit)
}

func (r *DataReadRepository) FindFieldsByDataTypeID(dataTypeID uuid.UUID) ([]*data.DataField, error) {
	return r.repo.FindFieldsByDataTypeID(dataTypeID)
}

func (r *DataReadRepository) FindRecordByID(id, siteID uuid.UUID) (*data.DataRecord, error) {
	return r.repo.FindRecordByIDScoped(id, siteID)
}

func (r *DataReadRepository) FindRecordsByDataSlug(dataSlug string, siteID uuid.UUID, search string, offset, limit int) ([]*data.DataRecord, int, error) {
	return r.repo.FindRecordsByDataSlug(dataSlug, siteID, search, offset, limit)
}

func (r *DataReadRepository) FindRecordOptions(dataSlug string, siteID uuid.UUID) ([]*data.RecordOption, error) {
	return r.repo.FindRecordOptions(dataSlug, siteID)
}

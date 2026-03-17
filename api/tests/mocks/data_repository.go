package mocks

import (
	"encoding/json"
	"fmt"
	"strings"
	"sync"

	"github.com/google/uuid"

	data "github.com/erickmo/vernon-cms/internal/domain/data"
)

type MockDataRepository struct {
	mu        sync.RWMutex
	dataTypes map[uuid.UUID]*data.DataType
	fields    map[uuid.UUID][]*data.DataField // keyed by dataTypeID
	records   map[uuid.UUID]*data.DataRecord

	SaveDataTypeErr   error
	UpdateDataTypeErr error
	DeleteDataTypeErr error
	FindDataTypeErr   error
	SaveFieldsErr     error
	ReplaceFieldsErr  error
	SaveRecordErr     error
	UpdateRecordErr   error
	DeleteRecordErr   error
	FindRecordErr     error
}

func NewMockDataRepository() *MockDataRepository {
	return &MockDataRepository{
		dataTypes: make(map[uuid.UUID]*data.DataType),
		fields:    make(map[uuid.UUID][]*data.DataField),
		records:   make(map[uuid.UUID]*data.DataRecord),
	}
}

// --- DataWriteRepository ---

func (m *MockDataRepository) SaveDataType(d *data.DataType) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.SaveDataTypeErr != nil {
		return m.SaveDataTypeErr
	}
	for _, existing := range m.dataTypes {
		if existing.Slug == d.Slug {
			return fmt.Errorf("duplicate slug: %s", d.Slug)
		}
	}
	copy := *d
	m.dataTypes[d.ID] = &copy
	return nil
}

func (m *MockDataRepository) UpdateDataType(d *data.DataType) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.UpdateDataTypeErr != nil {
		return m.UpdateDataTypeErr
	}
	if _, ok := m.dataTypes[d.ID]; !ok {
		return fmt.Errorf("domain not found: %s", d.ID)
	}
	copy := *d
	m.dataTypes[d.ID] = &copy
	return nil
}

func (m *MockDataRepository) DeleteDataType(id, siteID uuid.UUID) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.DeleteDataTypeErr != nil {
		return m.DeleteDataTypeErr
	}
	if _, ok := m.dataTypes[id]; !ok {
		return fmt.Errorf("domain not found: %s", id)
	}
	delete(m.dataTypes, id)
	delete(m.fields, id)
	return nil
}

func (m *MockDataRepository) SaveFields(dataTypeID uuid.UUID, fields []*data.DataField) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.SaveFieldsErr != nil {
		return m.SaveFieldsErr
	}
	existing := m.fields[dataTypeID]
	existing = append(existing, fields...)
	m.fields[dataTypeID] = existing
	return nil
}

func (m *MockDataRepository) ReplaceFields(dataTypeID uuid.UUID, fields []*data.DataField) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.ReplaceFieldsErr != nil {
		return m.ReplaceFieldsErr
	}
	m.fields[dataTypeID] = fields
	return nil
}

func (m *MockDataRepository) SaveRecord(rec *data.DataRecord) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.SaveRecordErr != nil {
		return m.SaveRecordErr
	}
	copy := *rec
	m.records[rec.ID] = &copy
	return nil
}

func (m *MockDataRepository) UpdateRecord(rec *data.DataRecord) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.UpdateRecordErr != nil {
		return m.UpdateRecordErr
	}
	if _, ok := m.records[rec.ID]; !ok {
		return fmt.Errorf("domain record not found: %s", rec.ID)
	}
	copy := *rec
	m.records[rec.ID] = &copy
	return nil
}

func (m *MockDataRepository) DeleteRecord(id uuid.UUID) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.DeleteRecordErr != nil {
		return m.DeleteRecordErr
	}
	if _, ok := m.records[id]; !ok {
		return fmt.Errorf("domain record not found: %s", id)
	}
	delete(m.records, id)
	return nil
}

// --- DataReadRepository ---

func (m *MockDataRepository) FindDataTypeByID(id, siteID uuid.UUID) (*data.DataType, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if m.FindDataTypeErr != nil {
		return nil, m.FindDataTypeErr
	}
	d, ok := m.dataTypes[id]
	if !ok {
		return nil, fmt.Errorf("domain not found: %s", id)
	}
	copy := *d
	copy.Fields = m.fields[id]
	return &copy, nil
}

func (m *MockDataRepository) FindDataTypeBySlug(slug string, siteID uuid.UUID) (*data.DataType, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if m.FindDataTypeErr != nil {
		return nil, m.FindDataTypeErr
	}
	for _, d := range m.dataTypes {
		if d.Slug == slug {
			copy := *d
			copy.Fields = m.fields[d.ID]
			return &copy, nil
		}
	}
	return nil, fmt.Errorf("domain not found: %s", slug)
}

func (m *MockDataRepository) FindAllDataTypes(siteID uuid.UUID, offset, limit int) ([]*data.DataType, int, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if m.FindDataTypeErr != nil {
		return nil, 0, m.FindDataTypeErr
	}
	all := make([]*data.DataType, 0, len(m.dataTypes))
	for _, d := range m.dataTypes {
		copy := *d
		copy.Fields = m.fields[d.ID]
		all = append(all, &copy)
	}
	total := len(all)
	if offset >= total {
		return []*data.DataType{}, total, nil
	}
	end := offset + limit
	if end > total {
		end = total
	}
	return all[offset:end], total, nil
}

func (m *MockDataRepository) FindFieldsByDataTypeID(dataTypeID uuid.UUID) ([]*data.DataField, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	fields := m.fields[dataTypeID]
	if fields == nil {
		return make([]*data.DataField, 0), nil
	}
	return fields, nil
}

func (m *MockDataRepository) FindRecordByID(id, siteID uuid.UUID) (*data.DataRecord, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if m.FindRecordErr != nil {
		return nil, m.FindRecordErr
	}
	rec, ok := m.records[id]
	if !ok {
		return nil, fmt.Errorf("domain record not found: %s", id)
	}
	copy := *rec
	return &copy, nil
}

func (m *MockDataRepository) FindRecordsByDataSlug(dataSlug string, siteID uuid.UUID, search string, offset, limit int) ([]*data.DataRecord, int, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if m.FindRecordErr != nil {
		return nil, 0, m.FindRecordErr
	}
	all := make([]*data.DataRecord, 0)
	for _, rec := range m.records {
		if rec.DataSlug != dataSlug {
			continue
		}
		if search != "" && !strings.Contains(strings.ToLower(string(rec.Data)), strings.ToLower(search)) {
			continue
		}
		copy := *rec
		all = append(all, &copy)
	}
	total := len(all)
	if offset >= total {
		return []*data.DataRecord{}, total, nil
	}
	end := offset + limit
	if end > total {
		end = total
	}
	return all[offset:end], total, nil
}

func (m *MockDataRepository) FindRecordOptions(dataSlug string, siteID uuid.UUID) ([]*data.RecordOption, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if m.FindRecordErr != nil {
		return nil, m.FindRecordErr
	}
	options := make([]*data.RecordOption, 0)
	for _, rec := range m.records {
		if rec.DataSlug != dataSlug {
			continue
		}
		label := ""
		var dataMap map[string]interface{}
		if err := json.Unmarshal(rec.Data, &dataMap); err == nil {
			for _, v := range dataMap {
				label = fmt.Sprintf("%v", v)
				break
			}
		}
		if label == "" {
			label = rec.ID.String()
		}
		options = append(options, &data.RecordOption{ID: rec.ID, Label: label})
	}
	return options, nil
}

func (m *MockDataRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.dataTypes = make(map[uuid.UUID]*data.DataType)
	m.fields = make(map[uuid.UUID][]*data.DataField)
	m.records = make(map[uuid.UUID]*data.DataRecord)
	m.SaveDataTypeErr = nil
	m.UpdateDataTypeErr = nil
	m.DeleteDataTypeErr = nil
	m.FindDataTypeErr = nil
	m.SaveFieldsErr = nil
	m.ReplaceFieldsErr = nil
	m.SaveRecordErr = nil
	m.UpdateRecordErr = nil
	m.DeleteRecordErr = nil
	m.FindRecordErr = nil
}

package mocks

import (
	"sync"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/settings"
)

// MockSettingsWriteRepository implements settings.WriteRepository.
type MockSettingsWriteRepository struct {
	mu       sync.RWMutex
	data     map[uuid.UUID]*settings.Settings
	UpsertErr error
}

func NewMockSettingsWriteRepository() *MockSettingsWriteRepository {
	return &MockSettingsWriteRepository{
		data: make(map[uuid.UUID]*settings.Settings),
	}
}

func (m *MockSettingsWriteRepository) Upsert(s *settings.Settings) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.UpsertErr != nil {
		return m.UpsertErr
	}

	m.data[s.SiteID] = s
	return nil
}

func (m *MockSettingsWriteRepository) Get(siteID uuid.UUID) *settings.Settings {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.data[siteID]
}

func (m *MockSettingsWriteRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.data = make(map[uuid.UUID]*settings.Settings)
	m.UpsertErr = nil
}

// MockSettingsReadRepository implements settings.ReadRepository.
type MockSettingsReadRepository struct {
	mu        sync.RWMutex
	data      map[uuid.UUID]*settings.Settings
	FindErr   error
}

func NewMockSettingsReadRepository() *MockSettingsReadRepository {
	return &MockSettingsReadRepository{
		data: make(map[uuid.UUID]*settings.Settings),
	}
}

func (m *MockSettingsReadRepository) FindBySiteID(siteID uuid.UUID) (*settings.Settings, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	s, ok := m.data[siteID]
	if !ok {
		return nil, nil // not found returns nil, nil (no error — caller defaults)
	}
	return s, nil
}

func (m *MockSettingsReadRepository) Seed(s *settings.Settings) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.data[s.SiteID] = s
}

func (m *MockSettingsReadRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.data = make(map[uuid.UUID]*settings.Settings)
	m.FindErr = nil
}

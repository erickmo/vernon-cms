package mocks

import (
	"fmt"
	"sync"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/apitoken"
)

// MockAPITokenWriteRepository implements apitoken.WriteRepository.
type MockAPITokenWriteRepository struct {
	mu        sync.RWMutex
	tokens    map[uuid.UUID]*apitoken.APIToken
	SaveErr   error
	UpdateErr error
	DeleteErr error
	FindErr   error
}

func NewMockAPITokenWriteRepository() *MockAPITokenWriteRepository {
	return &MockAPITokenWriteRepository{
		tokens: make(map[uuid.UUID]*apitoken.APIToken),
	}
}

func (m *MockAPITokenWriteRepository) Save(t *apitoken.APIToken) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.SaveErr != nil {
		return m.SaveErr
	}

	m.tokens[t.ID] = t
	return nil
}

func (m *MockAPITokenWriteRepository) Update(t *apitoken.APIToken) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.UpdateErr != nil {
		return m.UpdateErr
	}

	if _, ok := m.tokens[t.ID]; !ok {
		return fmt.Errorf("api token not found: %s", t.ID)
	}

	m.tokens[t.ID] = t
	return nil
}

func (m *MockAPITokenWriteRepository) Delete(id, siteID uuid.UUID) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.DeleteErr != nil {
		return m.DeleteErr
	}

	if _, ok := m.tokens[id]; !ok {
		return fmt.Errorf("api token not found: %s", id)
	}

	delete(m.tokens, id)
	return nil
}

func (m *MockAPITokenWriteRepository) FindByID(id, siteID uuid.UUID) (*apitoken.APIToken, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	t, ok := m.tokens[id]
	if !ok {
		return nil, fmt.Errorf("api token not found: %s", id)
	}
	return t, nil
}

func (m *MockAPITokenWriteRepository) Count() int {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return len(m.tokens)
}

func (m *MockAPITokenWriteRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.tokens = make(map[uuid.UUID]*apitoken.APIToken)
	m.SaveErr = nil
	m.UpdateErr = nil
	m.DeleteErr = nil
	m.FindErr = nil
}

// MockAPITokenReadRepository implements apitoken.ReadRepository.
type MockAPITokenReadRepository struct {
	mu      sync.RWMutex
	tokens  map[uuid.UUID]*apitoken.APIToken
	FindErr error
}

func NewMockAPITokenReadRepository() *MockAPITokenReadRepository {
	return &MockAPITokenReadRepository{
		tokens: make(map[uuid.UUID]*apitoken.APIToken),
	}
}

func (m *MockAPITokenReadRepository) FindAll(siteID uuid.UUID) ([]*apitoken.APIToken, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	result := make([]*apitoken.APIToken, 0)
	for _, t := range m.tokens {
		if t.SiteID == siteID {
			result = append(result, t)
		}
	}
	return result, nil
}

func (m *MockAPITokenReadRepository) FindByID(id, siteID uuid.UUID) (*apitoken.APIToken, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	t, ok := m.tokens[id]
	if !ok {
		return nil, fmt.Errorf("api token not found: %s", id)
	}
	return t, nil
}

func (m *MockAPITokenReadRepository) FindByHash(hash string) (*apitoken.APIToken, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	for _, t := range m.tokens {
		if t.TokenHash == hash {
			return t, nil
		}
	}
	return nil, fmt.Errorf("api token not found with hash")
}

func (m *MockAPITokenReadRepository) Seed(t *apitoken.APIToken) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.tokens[t.ID] = t
}

func (m *MockAPITokenReadRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.tokens = make(map[uuid.UUID]*apitoken.APIToken)
	m.FindErr = nil
}

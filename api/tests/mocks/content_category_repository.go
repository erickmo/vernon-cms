package mocks

import (
	"fmt"
	"sync"

	"github.com/google/uuid"

	contentcategory "github.com/erickmo/vernon-cms/internal/domain/content_category"
)

type MockContentCategoryRepository struct {
	mu         sync.RWMutex
	categories map[uuid.UUID]*contentcategory.ContentCategory
	SaveErr    error
	UpdateErr  error
	DeleteErr  error
	FindErr    error
}

func NewMockContentCategoryRepository() *MockContentCategoryRepository {
	return &MockContentCategoryRepository{
		categories: make(map[uuid.UUID]*contentcategory.ContentCategory),
	}
}

func (m *MockContentCategoryRepository) Save(c *contentcategory.ContentCategory) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.SaveErr != nil {
		return m.SaveErr
	}

	for _, existing := range m.categories {
		if existing.Slug == c.Slug {
			return fmt.Errorf("duplicate slug: %s", c.Slug)
		}
	}

	m.categories[c.ID] = c
	return nil
}

func (m *MockContentCategoryRepository) Update(c *contentcategory.ContentCategory) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.UpdateErr != nil {
		return m.UpdateErr
	}

	if _, ok := m.categories[c.ID]; !ok {
		return fmt.Errorf("content category not found: %s", c.ID)
	}

	m.categories[c.ID] = c
	return nil
}

func (m *MockContentCategoryRepository) Delete(id, siteID uuid.UUID) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.DeleteErr != nil {
		return m.DeleteErr
	}

	if _, ok := m.categories[id]; !ok {
		return fmt.Errorf("content category not found: %s", id)
	}

	delete(m.categories, id)
	return nil
}

func (m *MockContentCategoryRepository) FindByID(id, siteID uuid.UUID) (*contentcategory.ContentCategory, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	c, ok := m.categories[id]
	if !ok {
		return nil, fmt.Errorf("content category not found: %s", id)
	}
	return c, nil
}

func (m *MockContentCategoryRepository) FindBySlug(slug string, siteID uuid.UUID) (*contentcategory.ContentCategory, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	for _, c := range m.categories {
		if c.Slug == slug {
			return c, nil
		}
	}
	return nil, fmt.Errorf("content category not found with slug: %s", slug)
}

func (m *MockContentCategoryRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*contentcategory.ContentCategory, int, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, 0, m.FindErr
	}

	all := make([]*contentcategory.ContentCategory, 0, len(m.categories))
	for _, c := range m.categories {
		all = append(all, c)
	}

	total := len(all)
	if offset >= total {
		return []*contentcategory.ContentCategory{}, total, nil
	}

	end := offset + limit
	if end > total {
		end = total
	}

	return all[offset:end], total, nil
}

func (m *MockContentCategoryRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.categories = make(map[uuid.UUID]*contentcategory.ContentCategory)
	m.SaveErr = nil
	m.UpdateErr = nil
	m.DeleteErr = nil
	m.FindErr = nil
}

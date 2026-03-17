package mocks

import (
	"fmt"
	"sync"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/content"
)

type MockContentRepository struct {
	mu        sync.RWMutex
	contents  map[uuid.UUID]*content.Content
	SaveErr   error
	UpdateErr error
	DeleteErr error
	FindErr   error
}

func NewMockContentRepository() *MockContentRepository {
	return &MockContentRepository{
		contents: make(map[uuid.UUID]*content.Content),
	}
}

func (m *MockContentRepository) Save(c *content.Content) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.SaveErr != nil {
		return m.SaveErr
	}

	for _, existing := range m.contents {
		if existing.Slug == c.Slug {
			return fmt.Errorf("duplicate slug: %s", c.Slug)
		}
	}

	m.contents[c.ID] = c
	return nil
}

func (m *MockContentRepository) Update(c *content.Content) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.UpdateErr != nil {
		return m.UpdateErr
	}

	if _, ok := m.contents[c.ID]; !ok {
		return fmt.Errorf("content not found: %s", c.ID)
	}

	m.contents[c.ID] = c
	return nil
}

func (m *MockContentRepository) Delete(id, siteID uuid.UUID) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.DeleteErr != nil {
		return m.DeleteErr
	}

	if _, ok := m.contents[id]; !ok {
		return fmt.Errorf("content not found: %s", id)
	}

	delete(m.contents, id)
	return nil
}

func (m *MockContentRepository) FindByID(id, siteID uuid.UUID) (*content.Content, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	c, ok := m.contents[id]
	if !ok {
		return nil, fmt.Errorf("content not found: %s", id)
	}
	return c, nil
}

func (m *MockContentRepository) FindBySlug(slug string, siteID uuid.UUID) (*content.Content, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	for _, c := range m.contents {
		if c.Slug == slug {
			return c, nil
		}
	}
	return nil, fmt.Errorf("content not found with slug: %s", slug)
}

func (m *MockContentRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*content.Content, int, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, 0, m.FindErr
	}

	all := make([]*content.Content, 0, len(m.contents))
	for _, c := range m.contents {
		all = append(all, c)
	}

	total := len(all)
	if offset >= total {
		return []*content.Content{}, total, nil
	}

	end := offset + limit
	if end > total {
		end = total
	}

	return all[offset:end], total, nil
}

func (m *MockContentRepository) FindByPageID(pageID, siteID uuid.UUID, offset, limit int) ([]*content.Content, int, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, 0, m.FindErr
	}

	var filtered []*content.Content
	for _, c := range m.contents {
		if c.PageID == pageID {
			filtered = append(filtered, c)
		}
	}

	total := len(filtered)
	if offset >= total {
		return []*content.Content{}, total, nil
	}

	end := offset + limit
	if end > total {
		end = total
	}

	return filtered[offset:end], total, nil
}

func (m *MockContentRepository) FindByCategoryID(categoryID, siteID uuid.UUID, offset, limit int) ([]*content.Content, int, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, 0, m.FindErr
	}

	var filtered []*content.Content
	for _, c := range m.contents {
		if c.CategoryID == categoryID {
			filtered = append(filtered, c)
		}
	}

	total := len(filtered)
	if offset >= total {
		return []*content.Content{}, total, nil
	}

	end := offset + limit
	if end > total {
		end = total
	}

	return filtered[offset:end], total, nil
}

func (m *MockContentRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.contents = make(map[uuid.UUID]*content.Content)
	m.SaveErr = nil
	m.UpdateErr = nil
	m.DeleteErr = nil
	m.FindErr = nil
}

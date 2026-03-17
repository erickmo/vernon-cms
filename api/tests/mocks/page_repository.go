package mocks

import (
	"fmt"
	"sync"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/page"
)

type MockPageRepository struct {
	mu        sync.RWMutex
	pages     map[uuid.UUID]*page.Page
	SaveErr   error
	UpdateErr error
	DeleteErr error
	FindErr   error
}

func NewMockPageRepository() *MockPageRepository {
	return &MockPageRepository{
		pages: make(map[uuid.UUID]*page.Page),
	}
}

func (m *MockPageRepository) Save(p *page.Page) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.SaveErr != nil {
		return m.SaveErr
	}

	// Check unique slug
	for _, existing := range m.pages {
		if existing.Slug == p.Slug {
			return fmt.Errorf("duplicate slug: %s", p.Slug)
		}
	}

	m.pages[p.ID] = p
	return nil
}

func (m *MockPageRepository) Update(p *page.Page) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.UpdateErr != nil {
		return m.UpdateErr
	}

	if _, ok := m.pages[p.ID]; !ok {
		return fmt.Errorf("page not found: %s", p.ID)
	}

	m.pages[p.ID] = p
	return nil
}

func (m *MockPageRepository) Delete(id, siteID uuid.UUID) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.DeleteErr != nil {
		return m.DeleteErr
	}

	if _, ok := m.pages[id]; !ok {
		return fmt.Errorf("page not found: %s", id)
	}

	delete(m.pages, id)
	return nil
}

func (m *MockPageRepository) FindByID(id, siteID uuid.UUID) (*page.Page, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	p, ok := m.pages[id]
	if !ok {
		return nil, fmt.Errorf("page not found: %s", id)
	}
	return p, nil
}

func (m *MockPageRepository) FindBySlug(slug string, siteID uuid.UUID) (*page.Page, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	for _, p := range m.pages {
		if p.Slug == slug {
			return p, nil
		}
	}
	return nil, fmt.Errorf("page not found with slug: %s", slug)
}

func (m *MockPageRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*page.Page, int, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, 0, m.FindErr
	}

	all := make([]*page.Page, 0, len(m.pages))
	for _, p := range m.pages {
		all = append(all, p)
	}

	total := len(all)
	if offset >= total {
		return []*page.Page{}, total, nil
	}

	end := offset + limit
	if end > total {
		end = total
	}

	return all[offset:end], total, nil
}

func (m *MockPageRepository) Count() int {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return len(m.pages)
}

func (m *MockPageRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.pages = make(map[uuid.UUID]*page.Page)
	m.SaveErr = nil
	m.UpdateErr = nil
	m.DeleteErr = nil
	m.FindErr = nil
}

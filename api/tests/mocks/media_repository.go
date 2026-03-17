package mocks

import (
	"fmt"
	"strings"
	"sync"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/media"
)

// MockMediaWriteRepository implements media.WriteRepository.
type MockMediaWriteRepository struct {
	mu        sync.RWMutex
	files     map[uuid.UUID]*media.MediaFile
	SaveErr   error
	UpdateErr error
	DeleteErr error
	FindErr   error
}

func NewMockMediaWriteRepository() *MockMediaWriteRepository {
	return &MockMediaWriteRepository{
		files: make(map[uuid.UUID]*media.MediaFile),
	}
}

func (m *MockMediaWriteRepository) Save(f *media.MediaFile) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.SaveErr != nil {
		return m.SaveErr
	}

	m.files[f.ID] = f
	return nil
}

func (m *MockMediaWriteRepository) Update(f *media.MediaFile) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.UpdateErr != nil {
		return m.UpdateErr
	}

	if _, ok := m.files[f.ID]; !ok {
		return fmt.Errorf("media file not found: %s", f.ID)
	}

	m.files[f.ID] = f
	return nil
}

func (m *MockMediaWriteRepository) Delete(id, siteID uuid.UUID) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.DeleteErr != nil {
		return m.DeleteErr
	}

	if _, ok := m.files[id]; !ok {
		return fmt.Errorf("media file not found: %s", id)
	}

	delete(m.files, id)
	return nil
}

func (m *MockMediaWriteRepository) FindByID(id, siteID uuid.UUID) (*media.MediaFile, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	f, ok := m.files[id]
	if !ok {
		return nil, fmt.Errorf("media file not found: %s", id)
	}
	return f, nil
}

func (m *MockMediaWriteRepository) Count() int {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return len(m.files)
}

func (m *MockMediaWriteRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.files = make(map[uuid.UUID]*media.MediaFile)
	m.SaveErr = nil
	m.UpdateErr = nil
	m.DeleteErr = nil
	m.FindErr = nil
}

// MockMediaReadRepository implements media.ReadRepository.
type MockMediaReadRepository struct {
	mu      sync.RWMutex
	files   map[uuid.UUID]*media.MediaFile
	FindErr error
}

func NewMockMediaReadRepository() *MockMediaReadRepository {
	return &MockMediaReadRepository{
		files: make(map[uuid.UUID]*media.MediaFile),
	}
}

func (m *MockMediaReadRepository) FindByID(id, siteID uuid.UUID) (*media.MediaFile, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	f, ok := m.files[id]
	if !ok {
		return nil, fmt.Errorf("media file not found: %s", id)
	}
	return f, nil
}

func (m *MockMediaReadRepository) FindAll(siteID uuid.UUID, search, mimeType, folder string, offset, limit int) ([]*media.MediaFile, int, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, 0, m.FindErr
	}

	all := make([]*media.MediaFile, 0)
	for _, f := range m.files {
		if f.SiteID != siteID {
			continue
		}
		if search != "" && !strings.Contains(f.FileName, search) {
			continue
		}
		if mimeType != "" && f.MimeType != mimeType {
			continue
		}
		if folder != "" {
			if f.Folder == nil || *f.Folder != folder {
				continue
			}
		}
		all = append(all, f)
	}

	total := len(all)
	if offset >= total {
		return []*media.MediaFile{}, total, nil
	}
	end := offset + limit
	if end > total {
		end = total
	}
	return all[offset:end], total, nil
}

func (m *MockMediaReadRepository) FindFolders(siteID uuid.UUID) ([]string, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	seen := make(map[string]bool)
	result := make([]string, 0)
	for _, f := range m.files {
		if f.SiteID == siteID && f.Folder != nil {
			if !seen[*f.Folder] {
				seen[*f.Folder] = true
				result = append(result, *f.Folder)
			}
		}
	}
	return result, nil
}

func (m *MockMediaReadRepository) Seed(f *media.MediaFile) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.files[f.ID] = f
}

func (m *MockMediaReadRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.files = make(map[uuid.UUID]*media.MediaFile)
	m.FindErr = nil
}

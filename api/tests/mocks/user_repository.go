package mocks

import (
	"fmt"
	"sync"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/user"
)

type MockUserRepository struct {
	mu        sync.RWMutex
	users     map[uuid.UUID]*user.User
	SaveErr   error
	UpdateErr error
	DeleteErr error
	FindErr   error
}

func NewMockUserRepository() *MockUserRepository {
	return &MockUserRepository{
		users: make(map[uuid.UUID]*user.User),
	}
}

func (m *MockUserRepository) Save(u *user.User) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.SaveErr != nil {
		return m.SaveErr
	}

	for _, existing := range m.users {
		if existing.Email == u.Email {
			return fmt.Errorf("duplicate email: %s", u.Email)
		}
	}

	m.users[u.ID] = u
	return nil
}

func (m *MockUserRepository) Update(u *user.User) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.UpdateErr != nil {
		return m.UpdateErr
	}

	if _, ok := m.users[u.ID]; !ok {
		return fmt.Errorf("user not found: %s", u.ID)
	}

	m.users[u.ID] = u
	return nil
}

func (m *MockUserRepository) Delete(id uuid.UUID) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.DeleteErr != nil {
		return m.DeleteErr
	}

	if _, ok := m.users[id]; !ok {
		return fmt.Errorf("user not found: %s", id)
	}

	delete(m.users, id)
	return nil
}

func (m *MockUserRepository) FindByID(id uuid.UUID) (*user.User, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	u, ok := m.users[id]
	if !ok {
		return nil, fmt.Errorf("user not found: %s", id)
	}
	return u, nil
}

func (m *MockUserRepository) FindByEmail(email string) (*user.User, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, m.FindErr
	}

	for _, u := range m.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, fmt.Errorf("user not found with email: %s", email)
}

func (m *MockUserRepository) FindAll(offset, limit int) ([]*user.User, int, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.FindErr != nil {
		return nil, 0, m.FindErr
	}

	all := make([]*user.User, 0, len(m.users))
	for _, u := range m.users {
		all = append(all, u)
	}

	total := len(all)
	if offset >= total {
		return []*user.User{}, total, nil
	}

	end := offset + limit
	if end > total {
		end = total
	}

	return all[offset:end], total, nil
}

func (m *MockUserRepository) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.users = make(map[uuid.UUID]*user.User)
	m.SaveErr = nil
	m.UpdateErr = nil
	m.DeleteErr = nil
	m.FindErr = nil
}

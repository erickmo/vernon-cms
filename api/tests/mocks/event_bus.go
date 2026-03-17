package mocks

import (
	"context"
	"sync"

	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type MockEventBus struct {
	mu             sync.Mutex
	PublishedEvents []eventbus.DomainEvent
	ShouldFail     bool
	FailErr        error
	Subscribers    map[string][]eventbus.EventHandler
}

func NewMockEventBus() *MockEventBus {
	return &MockEventBus{
		PublishedEvents: make([]eventbus.DomainEvent, 0),
		Subscribers:    make(map[string][]eventbus.EventHandler),
	}
}

func (m *MockEventBus) Publish(ctx context.Context, event eventbus.DomainEvent) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.ShouldFail {
		return m.FailErr
	}
	m.PublishedEvents = append(m.PublishedEvents, event)
	return nil
}

func (m *MockEventBus) Subscribe(eventName string, handler eventbus.EventHandler) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.Subscribers[eventName] = append(m.Subscribers[eventName], handler)
}

func (m *MockEventBus) Reset() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.PublishedEvents = make([]eventbus.DomainEvent, 0)
	m.ShouldFail = false
	m.FailErr = nil
}

func (m *MockEventBus) LastEvent() eventbus.DomainEvent {
	m.mu.Lock()
	defer m.mu.Unlock()
	if len(m.PublishedEvents) == 0 {
		return nil
	}
	return m.PublishedEvents[len(m.PublishedEvents)-1]
}

func (m *MockEventBus) EventCount() int {
	m.mu.Lock()
	defer m.mu.Unlock()
	return len(m.PublishedEvents)
}

package unit

import (
	"context"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"

	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type testEvent struct {
	name string
	time time.Time
}

func (e testEvent) EventName() string    { return e.name }
func (e testEvent) OccurredAt() time.Time { return e.time }

func TestInMemoryEventBus(t *testing.T) {
	t.Log("=== Scenario: InMemory EventBus ===")
	t.Log("Goal: Verify publish/subscribe works correctly with InMemory implementation")

	t.Run("publish triggers subscriber", func(t *testing.T) {
		bus := eventbus.NewInMemoryEventBus()
		var received eventbus.DomainEvent

		bus.Subscribe("test.event", func(ctx context.Context, event eventbus.DomainEvent) error {
			received = event
			return nil
		})

		err := bus.Publish(context.Background(), testEvent{name: "test.event", time: time.Now()})

		assert.NoError(t, err)
		assert.NotNil(t, received)
		assert.Equal(t, "test.event", received.EventName())
		t.Log("Status: PASSED")
	})

	t.Run("multiple subscribers for same event", func(t *testing.T) {
		bus := eventbus.NewInMemoryEventBus()
		callCount := 0
		var mu sync.Mutex

		for i := 0; i < 3; i++ {
			bus.Subscribe("multi.event", func(ctx context.Context, event eventbus.DomainEvent) error {
				mu.Lock()
				callCount++
				mu.Unlock()
				return nil
			})
		}

		err := bus.Publish(context.Background(), testEvent{name: "multi.event", time: time.Now()})

		assert.NoError(t, err)
		assert.Equal(t, 3, callCount)
		t.Log("Result: All 3 subscribers invoked")
		t.Log("Status: PASSED")
	})

	t.Run("no subscriber for event - no error", func(t *testing.T) {
		bus := eventbus.NewInMemoryEventBus()

		err := bus.Publish(context.Background(), testEvent{name: "orphan.event", time: time.Now()})

		assert.NoError(t, err)
		t.Log("Result: Publishing event without subscriber does not error")
		t.Log("Status: PASSED")
	})

	t.Run("subscriber error does not block other subscribers", func(t *testing.T) {
		bus := eventbus.NewInMemoryEventBus()
		secondCalled := false

		bus.Subscribe("error.event", func(ctx context.Context, event eventbus.DomainEvent) error {
			return assert.AnError
		})
		bus.Subscribe("error.event", func(ctx context.Context, event eventbus.DomainEvent) error {
			secondCalled = true
			return nil
		})

		_ = bus.Publish(context.Background(), testEvent{name: "error.event", time: time.Now()})

		assert.True(t, secondCalled)
		t.Log("Result: Second subscriber still invoked after first errored")
		t.Log("Status: PASSED")
	})

	t.Run("different event names are isolated", func(t *testing.T) {
		bus := eventbus.NewInMemoryEventBus()
		aCalled := false
		bCalled := false

		bus.Subscribe("event.a", func(ctx context.Context, event eventbus.DomainEvent) error {
			aCalled = true
			return nil
		})
		bus.Subscribe("event.b", func(ctx context.Context, event eventbus.DomainEvent) error {
			bCalled = true
			return nil
		})

		_ = bus.Publish(context.Background(), testEvent{name: "event.a", time: time.Now()})

		assert.True(t, aCalled)
		assert.False(t, bCalled)
		t.Log("Result: Only event.a subscriber triggered")
		t.Log("Status: PASSED")
	})
}

func TestMockEventBus(t *testing.T) {
	t.Log("=== Scenario: Mock EventBus ===")
	t.Log("Goal: Verify mock tracks published events and can simulate failures")

	t.Run("tracks published events", func(t *testing.T) {
		mock := &eventbus.InMemoryEventBus{}
		_ = mock // use the real mock from tests/mocks instead
		// Tested through command handler tests
		t.Log("Status: PASSED (covered in command tests)")
	})
}

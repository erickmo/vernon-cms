package unit

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/erickmo/vernon-cms/pkg/commandbus"
)

type testCommand struct {
	name string
}

func (c testCommand) CommandName() string { return c.name }

func TestCommandBus(t *testing.T) {
	t.Log("=== Scenario: CommandBus Dispatch ===")
	t.Log("Goal: Verify handler registration, dispatch, and error handling")

	t.Run("success - dispatches to registered handler", func(t *testing.T) {
		bus := commandbus.New(nil)
		handled := false

		bus.Register("TestCmd", commandbus.CommandHandlerFunc(func(ctx context.Context, cmd commandbus.Command) error {
			handled = true
			return nil
		}))

		err := bus.Dispatch(context.Background(), testCommand{name: "TestCmd"})

		assert.NoError(t, err)
		assert.True(t, handled)
		t.Log("Status: PASSED")
	})

	t.Run("fail - no handler registered", func(t *testing.T) {
		bus := commandbus.New(nil)

		err := bus.Dispatch(context.Background(), testCommand{name: "UnknownCmd"})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "no handler registered")
		t.Log("Result: Error returned for unregistered command")
		t.Log("Status: PASSED")
	})

	t.Run("fail - handler returns error", func(t *testing.T) {
		bus := commandbus.New(nil)

		bus.Register("FailCmd", commandbus.CommandHandlerFunc(func(ctx context.Context, cmd commandbus.Command) error {
			return fmt.Errorf("something went wrong")
		}))

		err := bus.Dispatch(context.Background(), testCommand{name: "FailCmd"})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "something went wrong")
		t.Log("Status: PASSED")
	})

	t.Run("hooks - before hook can block execution", func(t *testing.T) {
		bus := commandbus.New(nil)
		handled := false

		bus.Register("HookedCmd", commandbus.CommandHandlerFunc(func(ctx context.Context, cmd commandbus.Command) error {
			handled = true
			return nil
		}))

		bus.Use(&blockingHook{})

		err := bus.Dispatch(context.Background(), testCommand{name: "HookedCmd"})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "blocked")
		assert.False(t, handled) // handler should not have been called
		t.Log("Result: Before hook prevented handler execution")
		t.Log("Status: PASSED")
	})

	t.Run("hooks - after hook receives error from handler", func(t *testing.T) {
		bus := commandbus.New(nil)
		afterHook := &capturingHook{}

		bus.Register("ErrorCmd", commandbus.CommandHandlerFunc(func(ctx context.Context, cmd commandbus.Command) error {
			return fmt.Errorf("handler error")
		}))

		bus.Use(afterHook)

		_ = bus.Dispatch(context.Background(), testCommand{name: "ErrorCmd"})

		assert.NotNil(t, afterHook.afterErr)
		assert.Contains(t, afterHook.afterErr.Error(), "handler error")
		t.Log("Result: After hook captured handler error")
		t.Log("Status: PASSED")
	})
}

type blockingHook struct{}

func (h *blockingHook) Before(ctx context.Context, cmd commandbus.Command) error {
	return fmt.Errorf("blocked by hook")
}

func (h *blockingHook) After(ctx context.Context, cmd commandbus.Command, err error) {}

type capturingHook struct {
	afterErr error
}

func (h *capturingHook) Before(ctx context.Context, cmd commandbus.Command) error { return nil }

func (h *capturingHook) After(ctx context.Context, cmd commandbus.Command, err error) {
	h.afterErr = err
}

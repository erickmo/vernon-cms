package unit

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type testQuery struct {
	name string
}

func (q testQuery) QueryName() string { return q.name }

func TestQueryBus(t *testing.T) {
	t.Log("=== Scenario: QueryBus Dispatch ===")
	t.Log("Goal: Verify handler registration, dispatch, and error handling")

	t.Run("success - dispatches and returns result", func(t *testing.T) {
		bus := querybus.New(nil)

		bus.Register("TestQuery", querybus.QueryHandlerFunc(func(ctx context.Context, q querybus.Query) (interface{}, error) {
			return map[string]string{"key": "value"}, nil
		}))

		result, err := bus.Dispatch(context.Background(), testQuery{name: "TestQuery"})

		assert.NoError(t, err)
		assert.NotNil(t, result)
		m := result.(map[string]string)
		assert.Equal(t, "value", m["key"])
		t.Log("Status: PASSED")
	})

	t.Run("fail - no handler registered", func(t *testing.T) {
		bus := querybus.New(nil)

		result, err := bus.Dispatch(context.Background(), testQuery{name: "Unknown"})

		assert.Error(t, err)
		assert.Nil(t, result)
		assert.Contains(t, err.Error(), "no handler registered")
		t.Log("Status: PASSED")
	})

	t.Run("fail - handler returns error", func(t *testing.T) {
		bus := querybus.New(nil)

		bus.Register("FailQuery", querybus.QueryHandlerFunc(func(ctx context.Context, q querybus.Query) (interface{}, error) {
			return nil, fmt.Errorf("query failed")
		}))

		result, err := bus.Dispatch(context.Background(), testQuery{name: "FailQuery"})

		assert.Error(t, err)
		assert.Nil(t, result)
		assert.Contains(t, err.Error(), "query failed")
		t.Log("Status: PASSED")
	})

	t.Run("success - handler returns nil result without error", func(t *testing.T) {
		bus := querybus.New(nil)

		bus.Register("NilQuery", querybus.QueryHandlerFunc(func(ctx context.Context, q querybus.Query) (interface{}, error) {
			return nil, nil
		}))

		result, err := bus.Dispatch(context.Background(), testQuery{name: "NilQuery"})

		assert.NoError(t, err)
		assert.Nil(t, result)
		t.Log("Result: Nil result without error is valid")
		t.Log("Status: PASSED")
	})
}

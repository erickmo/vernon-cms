package unit

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/erickmo/vernon-cms/pkg/apperror"
)

func TestAppErrors(t *testing.T) {
	t.Log("=== Scenario: Custom Application Error Types ===")
	t.Log("Goal: Verify error type detection and message formatting")

	t.Run("NotFoundError", func(t *testing.T) {
		err := &apperror.NotFoundError{Entity: "page", ID: "abc-123"}
		assert.Equal(t, "page not found: abc-123", err.Error())
		assert.True(t, apperror.IsNotFound(err))
		assert.False(t, apperror.IsValidation(err))
		assert.False(t, apperror.IsConflict(err))
		t.Log("Status: PASSED")
	})

	t.Run("ValidationError with field", func(t *testing.T) {
		err := &apperror.ValidationError{Field: "email", Message: "invalid format"}
		assert.Equal(t, "validation error on email: invalid format", err.Error())
		assert.True(t, apperror.IsValidation(err))
		assert.False(t, apperror.IsNotFound(err))
		t.Log("Status: PASSED")
	})

	t.Run("ValidationError without field", func(t *testing.T) {
		err := &apperror.ValidationError{Message: "request body is empty"}
		assert.Equal(t, "validation error: request body is empty", err.Error())
		assert.True(t, apperror.IsValidation(err))
		t.Log("Status: PASSED")
	})

	t.Run("ConflictError", func(t *testing.T) {
		err := &apperror.ConflictError{Entity: "user", Field: "email", Value: "john@test.com"}
		assert.Equal(t, "user with email 'john@test.com' already exists", err.Error())
		assert.True(t, apperror.IsConflict(err))
		assert.False(t, apperror.IsNotFound(err))
		t.Log("Status: PASSED")
	})

	t.Run("UnauthorizedError with message", func(t *testing.T) {
		err := &apperror.UnauthorizedError{Message: "invalid credentials"}
		assert.Equal(t, "invalid credentials", err.Error())
		assert.True(t, apperror.IsUnauthorized(err))
		t.Log("Status: PASSED")
	})

	t.Run("UnauthorizedError without message", func(t *testing.T) {
		err := &apperror.UnauthorizedError{}
		assert.Equal(t, "unauthorized", err.Error())
		t.Log("Status: PASSED")
	})

	t.Run("ForbiddenError with message", func(t *testing.T) {
		err := &apperror.ForbiddenError{Message: "admin only"}
		assert.Equal(t, "admin only", err.Error())
		assert.True(t, apperror.IsForbidden(err))
		t.Log("Status: PASSED")
	})

	t.Run("ForbiddenError without message", func(t *testing.T) {
		err := &apperror.ForbiddenError{}
		assert.Equal(t, "forbidden", err.Error())
		t.Log("Status: PASSED")
	})

	t.Run("type detection does not false-positive on plain error", func(t *testing.T) {
		err := assert.AnError
		assert.False(t, apperror.IsNotFound(err))
		assert.False(t, apperror.IsValidation(err))
		assert.False(t, apperror.IsConflict(err))
		assert.False(t, apperror.IsUnauthorized(err))
		assert.False(t, apperror.IsForbidden(err))
		t.Log("Result: Plain errors don't match any custom type")
		t.Log("Status: PASSED")
	})
}

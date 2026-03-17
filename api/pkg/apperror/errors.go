package apperror

import "fmt"

type NotFoundError struct {
	Entity string
	ID     string
}

func (e *NotFoundError) Error() string {
	return fmt.Sprintf("%s not found: %s", e.Entity, e.ID)
}

type ValidationError struct {
	Field   string
	Message string
}

func (e *ValidationError) Error() string {
	if e.Field != "" {
		return fmt.Sprintf("validation error on %s: %s", e.Field, e.Message)
	}
	return fmt.Sprintf("validation error: %s", e.Message)
}

type ConflictError struct {
	Entity string
	Field  string
	Value  string
}

func (e *ConflictError) Error() string {
	return fmt.Sprintf("%s with %s '%s' already exists", e.Entity, e.Field, e.Value)
}

type UnauthorizedError struct {
	Message string
}

func (e *UnauthorizedError) Error() string {
	if e.Message == "" {
		return "unauthorized"
	}
	return e.Message
}

type ForbiddenError struct {
	Message string
}

func (e *ForbiddenError) Error() string {
	if e.Message == "" {
		return "forbidden"
	}
	return e.Message
}

func IsNotFound(err error) bool {
	_, ok := err.(*NotFoundError)
	return ok
}

func IsValidation(err error) bool {
	_, ok := err.(*ValidationError)
	return ok
}

func IsConflict(err error) bool {
	_, ok := err.(*ConflictError)
	return ok
}

func IsUnauthorized(err error) bool {
	_, ok := err.(*UnauthorizedError)
	return ok
}

func IsForbidden(err error) bool {
	_, ok := err.(*ForbiddenError)
	return ok
}

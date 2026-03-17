package user

import (
	"time"

	"github.com/google/uuid"
)

type UserCreated struct {
	UserID uuid.UUID `json:"user_id"`
	Email  string    `json:"email"`
	Name   string    `json:"name"`
	Role   Role      `json:"role"`
	Time   time.Time `json:"time"`
}

func (e UserCreated) EventName() string    { return "user.created" }
func (e UserCreated) OccurredAt() time.Time { return e.Time }

type UserUpdated struct {
	UserID uuid.UUID `json:"user_id"`
	Email  string    `json:"email"`
	Name   string    `json:"name"`
	Time   time.Time `json:"time"`
}

func (e UserUpdated) EventName() string    { return "user.updated" }
func (e UserUpdated) OccurredAt() time.Time { return e.Time }

type UserDeleted struct {
	UserID uuid.UUID `json:"user_id"`
	Time   time.Time `json:"time"`
}

func (e UserDeleted) EventName() string    { return "user.deleted" }
func (e UserDeleted) OccurredAt() time.Time { return e.Time }

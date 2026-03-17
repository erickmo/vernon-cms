package user

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

type Role string

const (
	RoleAdmin  Role = "admin"
	RoleEditor Role = "editor"
	RoleViewer Role = "viewer"
)

type User struct {
	ID           uuid.UUID `json:"id" db:"id"`
	Email        string    `json:"email" db:"email"`
	PasswordHash string    `json:"-" db:"password_hash"`
	Name         string    `json:"name" db:"name"`
	Role         Role      `json:"role" db:"role"`
	IsActive     bool      `json:"is_active" db:"is_active"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`
}

func NewUser(email, passwordHash, name string, role Role) (*User, error) {
	if email == "" {
		return nil, errors.New("user email is required")
	}
	if passwordHash == "" {
		return nil, errors.New("password hash is required")
	}
	if name == "" {
		return nil, errors.New("user name is required")
	}
	if role == "" {
		role = RoleViewer
	}

	now := time.Now()
	return &User{
		ID:           uuid.New(),
		Email:        email,
		PasswordHash: passwordHash,
		Name:         name,
		Role:         role,
		IsActive:     true,
		CreatedAt:    now,
		UpdatedAt:    now,
	}, nil
}

func (u *User) UpdateName(name string) error {
	if name == "" {
		return errors.New("user name is required")
	}
	u.Name = name
	u.UpdatedAt = time.Now()
	return nil
}

func (u *User) UpdateEmail(email string) error {
	if email == "" {
		return errors.New("user email is required")
	}
	u.Email = email
	u.UpdatedAt = time.Now()
	return nil
}

func (u *User) UpdatePassword(passwordHash string) {
	u.PasswordHash = passwordHash
	u.UpdatedAt = time.Now()
}

func (u *User) UpdateRole(role Role) {
	u.Role = role
	u.UpdatedAt = time.Now()
}

func (u *User) SetActive(active bool) {
	u.IsActive = active
	u.UpdatedAt = time.Now()
}

type WriteRepository interface {
	Save(user *User) error
	Update(user *User) error
	Delete(id uuid.UUID) error
	FindByID(id uuid.UUID) (*User, error)
}

type ReadRepository interface {
	FindByID(id uuid.UUID) (*User, error)
	FindByEmail(email string) (*User, error)
	FindAll(offset, limit int) ([]*User, int, error)
}

package client

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

type Client struct {
	ID        uuid.UUID `db:"id"`
	Name      string    `db:"name"`
	Email     string    `db:"email"`
	Phone     *string   `db:"phone"`
	Company   *string   `db:"company"`
	Address   *string   `db:"address"`
	IsActive  bool      `db:"is_active"`
	CreatedAt time.Time `db:"created_at"`
	UpdatedAt time.Time `db:"updated_at"`
}

func NewClient(name, email string) (*Client, error) {
	if name == "" {
		return nil, errors.New("client name is required")
	}
	if email == "" {
		return nil, errors.New("client email is required")
	}
	return &Client{
		ID:        uuid.New(),
		Name:      name,
		Email:     email,
		IsActive:  true,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}, nil
}

func (c *Client) ToggleActive() {
	c.IsActive = !c.IsActive
	c.UpdatedAt = time.Now()
}

type WriteRepository interface {
	Save(c *Client) error
	Update(c *Client) error
	Delete(id uuid.UUID) error
	FindByID(id uuid.UUID) (*Client, error)
}

type ReadRepository interface {
	FindByID(id uuid.UUID) (*Client, error)
	FindAll(search string, isActive *bool, offset, limit int) ([]*Client, int, error)
}

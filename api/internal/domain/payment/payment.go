package payment

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

type Status string

const (
	StatusPending   Status = "pending"
	StatusPaid      Status = "paid"
	StatusFailed    Status = "failed"
	StatusCancelled Status = "cancelled"
)

type Payment struct {
	ID          uuid.UUID  `db:"id"`
	ClientID    uuid.UUID  `db:"client_id"`
	Amount      float64    `db:"amount"`
	Status      Status     `db:"status"`
	Description *string    `db:"description"`
	Method      *string    `db:"method"`
	DueDate     *time.Time `db:"due_date"`
	PaidAt      *time.Time `db:"paid_at"`
	CreatedAt   time.Time  `db:"created_at"`
	UpdatedAt   time.Time  `db:"updated_at"`
}

func NewPayment(clientID uuid.UUID, amount float64) (*Payment, error) {
	if clientID == uuid.Nil {
		return nil, errors.New("client_id is required")
	}
	if amount <= 0 {
		return nil, errors.New("amount must be greater than zero")
	}
	return &Payment{
		ID:        uuid.New(),
		ClientID:  clientID,
		Amount:    amount,
		Status:    StatusPending,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}, nil
}

type WriteRepository interface {
	Save(p *Payment) error
}

// PaymentWithClient is a read model that includes client name from JOIN.
type PaymentWithClient struct {
	Payment
	ClientName string `db:"client_name"`
}

type ReadRepository interface {
	FindByID(id uuid.UUID) (*PaymentWithClient, error)
	FindAll(clientID *uuid.UUID, status *Status, offset, limit int) ([]*PaymentWithClient, int, error)
}

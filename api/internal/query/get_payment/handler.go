package getpayment

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/payment"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	ID uuid.UUID `json:"id"`
}

func (q Query) QueryName() string { return "GetPayment" }

type Handler struct {
	repo payment.ReadRepository
}

func NewHandler(repo payment.ReadRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, query querybus.Query) (interface{}, error) {
	q := query.(Query)
	return h.repo.FindByID(q.ID)
}

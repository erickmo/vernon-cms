package listpayments

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/payment"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	ClientID *uuid.UUID      `json:"client_id"`
	Status   *payment.Status `json:"status"`
	Page     int             `json:"page"`
	PerPage  int             `json:"per_page"`
}

func (q Query) QueryName() string { return "ListPayments" }

type Result struct {
	Items   []*payment.PaymentWithClient `json:"items"`
	Total   int                          `json:"total"`
	Page    int                          `json:"page"`
	PerPage int                          `json:"per_page"`
}

type Handler struct {
	repo payment.ReadRepository
}

func NewHandler(repo payment.ReadRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, query querybus.Query) (interface{}, error) {
	q := query.(Query)

	if q.Page <= 0 {
		q.Page = 1
	}
	if q.PerPage <= 0 {
		q.PerPage = 20
	}
	offset := (q.Page - 1) * q.PerPage

	items, total, err := h.repo.FindAll(q.ClientID, q.Status, offset, q.PerPage)
	if err != nil {
		return nil, err
	}
	if items == nil {
		items = []*payment.PaymentWithClient{}
	}

	return Result{
		Items:   items,
		Total:   total,
		Page:    q.Page,
		PerPage: q.PerPage,
	}, nil
}

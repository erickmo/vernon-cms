package createpayment

import (
	"context"
	"time"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/payment"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
)

type Command struct {
	ClientID    uuid.UUID  `json:"client_id" validate:"required"`
	Amount      float64    `json:"amount" validate:"required,gt=0"`
	Description *string    `json:"description"`
	Method      *string    `json:"method"`
	DueDate     *time.Time `json:"due_date"`
}

func (c Command) CommandName() string { return "CreatePayment" }

// Result carries the created payment back to the HTTP handler.
type Result struct {
	Payment *payment.Payment
}

type resultKey struct{}

func WithResult(ctx context.Context, r *Result) context.Context {
	return context.WithValue(ctx, resultKey{}, r)
}

func getResult(ctx context.Context) *Result {
	r, _ := ctx.Value(resultKey{}).(*Result)
	return r
}

type Handler struct {
	repo payment.WriteRepository
}

func NewHandler(repo payment.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	p, err := payment.NewPayment(c.ClientID, c.Amount)
	if err != nil {
		return err
	}
	p.Description = c.Description
	p.Method = c.Method
	p.DueDate = c.DueDate

	if err := h.repo.Save(p); err != nil {
		return err
	}

	if res := getResult(ctx); res != nil {
		res.Payment = p
	}
	return nil
}

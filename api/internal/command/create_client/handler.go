package createclient

import (
	"context"

	"github.com/erickmo/vernon-cms/internal/domain/client"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
)

type Command struct {
	Name    string  `json:"name" validate:"required"`
	Email   string  `json:"email" validate:"required,email"`
	Phone   *string `json:"phone"`
	Company *string `json:"company"`
	Address *string `json:"address"`
}

func (c Command) CommandName() string { return "CreateClient" }

// Result carries the created client back to the HTTP handler.
type Result struct {
	Client *client.Client
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
	repo client.WriteRepository
}

func NewHandler(repo client.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	cl, err := client.NewClient(c.Name, c.Email)
	if err != nil {
		return err
	}
	cl.Phone = c.Phone
	cl.Company = c.Company
	cl.Address = c.Address

	if err := h.repo.Save(cl); err != nil {
		return err
	}

	if res := getResult(ctx); res != nil {
		res.Client = cl
	}
	return nil
}

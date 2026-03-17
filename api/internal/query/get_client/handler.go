package getclient

import (
	"context"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/client"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	ID uuid.UUID `json:"id"`
}

func (q Query) QueryName() string { return "GetClient" }

type Handler struct {
	repo client.ReadRepository
}

func NewHandler(repo client.ReadRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, query querybus.Query) (interface{}, error) {
	q := query.(Query)
	return h.repo.FindByID(q.ID)
}

package listclients

import (
	"context"

	"github.com/erickmo/vernon-cms/internal/domain/client"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	Search   string `json:"search"`
	IsActive *bool  `json:"is_active"`
	Page     int    `json:"page"`
	PerPage  int    `json:"per_page"`
}

func (q Query) QueryName() string { return "ListClients" }

type Result struct {
	Items   []*client.Client `json:"items"`
	Total   int              `json:"total"`
	Page    int              `json:"page"`
	PerPage int              `json:"per_page"`
}

type Handler struct {
	repo client.ReadRepository
}

func NewHandler(repo client.ReadRepository) *Handler {
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

	items, total, err := h.repo.FindAll(q.Search, q.IsActive, offset, q.PerPage)
	if err != nil {
		return nil, err
	}
	if items == nil {
		items = []*client.Client{}
	}

	return Result{
		Items:   items,
		Total:   total,
		Page:    q.Page,
		PerPage: q.PerPage,
	}, nil
}

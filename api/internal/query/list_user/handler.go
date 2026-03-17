package listuser

import (
	"context"
	"time"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/user"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	Page  int `json:"page"`
	Limit int `json:"limit"`
}

func (q Query) QueryName() string { return "ListUser" }

type ReadModel struct {
	ID        uuid.UUID `json:"id"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	Role      string    `json:"role"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type ListResult struct {
	Items []*ReadModel `json:"items"`
	Total int          `json:"total"`
	Page  int          `json:"page"`
	Limit int          `json:"limit"`
}

type Handler struct {
	repo   user.ReadRepository
	tracer trace.Tracer
}

func NewHandler(repo user.ReadRepository) *Handler {
	return &Handler{
		repo:   repo,
		tracer: otel.Tracer("query.list_user"),
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)

	_, span := h.tracer.Start(ctx, "ListUser.Handle")
	defer span.End()

	if query.Limit <= 0 {
		query.Limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * query.Limit
	}

	users, total, err := h.repo.FindAll(offset, query.Limit)
	if err != nil {
		return nil, err
	}

	items := make([]*ReadModel, len(users))
	for i, u := range users {
		items[i] = &ReadModel{
			ID:        u.ID,
			Email:     u.Email,
			Name:      u.Name,
			Role:      string(u.Role),
			IsActive:  u.IsActive,
			CreatedAt: u.CreatedAt,
			UpdatedAt: u.UpdatedAt,
		}
	}

	return &ListResult{
		Items: items,
		Total: total,
		Page:  query.Page,
		Limit: query.Limit,
	}, nil
}

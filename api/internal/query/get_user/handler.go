package getuser

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/infrastructure/telemetry"
	"github.com/erickmo/vernon-cms/internal/domain/user"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	ID uuid.UUID `json:"id"`
}

func (q Query) QueryName() string { return "GetUser" }

type ReadModel struct {
	ID        uuid.UUID `json:"id"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	Role      string    `json:"role"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Handler struct {
	repo    user.ReadRepository
	cache   *redis.Client
	metrics *telemetry.Metrics
	tracer  trace.Tracer
	ttl     time.Duration
}

func NewHandler(repo user.ReadRepository, cache *redis.Client, metrics *telemetry.Metrics, ttl time.Duration) *Handler {
	return &Handler{
		repo:    repo,
		cache:   cache,
		metrics: metrics,
		tracer:  otel.Tracer("query.get_user"),
		ttl:     ttl,
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)

	ctx, span := h.tracer.Start(ctx, "GetUser.Handle")
	defer span.End()

	cacheKey := fmt.Sprintf("user:%s", query.ID.String())

	cached, err := h.cache.Get(ctx, cacheKey).Bytes()
	if err == nil {
		span.SetAttributes(attribute.Bool("cache.hit", true))
		h.metrics.CacheHitCount.Add(ctx, 1)
		var rm ReadModel
		if err := json.Unmarshal(cached, &rm); err == nil {
			return &rm, nil
		}
	}

	span.SetAttributes(attribute.Bool("cache.hit", false))
	h.metrics.CacheMissCount.Add(ctx, 1)

	u, err := h.repo.FindByID(query.ID)
	if err != nil {
		return nil, err
	}

	rm := &ReadModel{
		ID:        u.ID,
		Email:     u.Email,
		Name:      u.Name,
		Role:      string(u.Role),
		IsActive:  u.IsActive,
		CreatedAt: u.CreatedAt,
		UpdatedAt: u.UpdatedAt,
	}

	if data, err := json.Marshal(rm); err == nil {
		h.cache.Set(ctx, cacheKey, data, h.ttl)
	}

	return rm, nil
}

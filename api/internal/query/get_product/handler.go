package getproduct

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
	"github.com/erickmo/vernon-cms/internal/domain/product"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	ID     uuid.UUID `json:"id"`
	SiteID uuid.UUID `json:"site_id"`
}

func (q Query) QueryName() string { return "GetProduct" }

type ReadModel struct {
	ID          uuid.UUID       `json:"id"`
	SiteID      uuid.UUID       `json:"site_id"`
	CategoryID  *uuid.UUID      `json:"category_id,omitempty"`
	Name        string          `json:"name"`
	Slug        string          `json:"slug"`
	Description string          `json:"description"`
	Price       float64         `json:"price"`
	Stock       *int            `json:"stock,omitempty"`
	Images      json.RawMessage `json:"images"`
	Metadata    json.RawMessage `json:"metadata"`
	IsActive    bool            `json:"is_active"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}

type Handler struct {
	repo    product.ReadRepository
	cache   *redis.Client
	metrics *telemetry.Metrics
	tracer  trace.Tracer
	ttl     time.Duration
}

func NewHandler(repo product.ReadRepository, cache *redis.Client, metrics *telemetry.Metrics, ttl time.Duration) *Handler {
	return &Handler{
		repo:    repo,
		cache:   cache,
		metrics: metrics,
		tracer:  otel.Tracer("query.get_product"),
		ttl:     ttl,
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)

	ctx, span := h.tracer.Start(ctx, "GetProduct.Handle")
	defer span.End()

	cacheKey := fmt.Sprintf("product:%s:%s", query.SiteID.String(), query.ID.String())

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

	p, err := h.repo.FindByID(query.ID, query.SiteID)
	if err != nil {
		return nil, err
	}

	rm := toReadModel(p)

	if data, err := json.Marshal(rm); err == nil {
		h.cache.Set(ctx, cacheKey, data, h.ttl)
	}

	return rm, nil
}

func toReadModel(p *product.Product) *ReadModel {
	return &ReadModel{
		ID:          p.ID,
		SiteID:      p.SiteID,
		CategoryID:  p.CategoryID,
		Name:        p.Name,
		Slug:        p.Slug,
		Description: p.Description,
		Price:       p.Price,
		Stock:       p.Stock,
		Images:      p.Images,
		Metadata:    p.Metadata,
		IsActive:    p.IsActive,
		CreatedAt:   p.CreatedAt,
		UpdatedAt:   p.UpdatedAt,
	}
}

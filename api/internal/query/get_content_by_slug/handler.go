package getcontentbyslug

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
	"github.com/erickmo/vernon-cms/internal/domain/content"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	Slug   string    `json:"slug"`
	SiteID uuid.UUID `json:"site_id"`
}

func (q Query) QueryName() string { return "GetContentBySlug" }

type ReadModel struct {
	ID          uuid.UUID       `json:"id"`
	SiteID      uuid.UUID       `json:"site_id"`
	Title       string          `json:"title"`
	Slug        string          `json:"slug"`
	Body        string          `json:"body"`
	Excerpt     string          `json:"excerpt"`
	Status      string          `json:"status"`
	PageID      uuid.UUID       `json:"page_id"`
	CategoryID  uuid.UUID       `json:"category_id"`
	AuthorID    uuid.UUID       `json:"author_id"`
	Metadata    json.RawMessage `json:"metadata"`
	PublishedAt *time.Time      `json:"published_at"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}

type Handler struct {
	repo    content.ReadRepository
	cache   *redis.Client
	metrics *telemetry.Metrics
	tracer  trace.Tracer
	ttl     time.Duration
}

func NewHandler(repo content.ReadRepository, cache *redis.Client, metrics *telemetry.Metrics, ttl time.Duration) *Handler {
	return &Handler{
		repo:    repo,
		cache:   cache,
		metrics: metrics,
		tracer:  otel.Tracer("query.get_content_by_slug"),
		ttl:     ttl,
	}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)

	ctx, span := h.tracer.Start(ctx, "GetContentBySlug.Handle")
	defer span.End()

	cacheKey := fmt.Sprintf("content:slug:%s:%s", query.SiteID.String(), query.Slug)

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

	ct, err := h.repo.FindBySlug(query.Slug, query.SiteID)
	if err != nil {
		return nil, err
	}

	rm := &ReadModel{
		ID:          ct.ID,
		SiteID:      ct.SiteID,
		Title:       ct.Title,
		Slug:        ct.Slug,
		Body:        ct.Body,
		Excerpt:     ct.Excerpt,
		Status:      string(ct.Status),
		PageID:      ct.PageID,
		CategoryID:  ct.CategoryID,
		AuthorID:    ct.AuthorID,
		Metadata:    ct.Metadata,
		PublishedAt: ct.PublishedAt,
		CreatedAt:   ct.CreatedAt,
		UpdatedAt:   ct.UpdatedAt,
	}

	if data, err := json.Marshal(rm); err == nil {
		h.cache.Set(ctx, cacheKey, data, h.ttl)
	}

	return rm, nil
}

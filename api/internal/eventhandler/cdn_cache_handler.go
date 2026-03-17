package eventhandler

import (
	"context"
	"fmt"

	"github.com/redis/go-redis/v9"
	"github.com/rs/zerolog/log"

	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

type CDNCacheHandler struct {
	cache *redis.Client
}

func NewCDNCacheHandler(cache *redis.Client) *CDNCacheHandler {
	return &CDNCacheHandler{cache: cache}
}

func (h *CDNCacheHandler) HandlePageEvent(ctx context.Context, event eventbus.DomainEvent) error {
	log.Ctx(ctx).Info().
		Str("event", event.EventName()).
		Msg("invalidating CDN cache for page")

	patterns := []string{"page:*"}
	return h.invalidateCache(ctx, patterns)
}

func (h *CDNCacheHandler) HandleContentCategoryEvent(ctx context.Context, event eventbus.DomainEvent) error {
	log.Ctx(ctx).Info().
		Str("event", event.EventName()).
		Msg("invalidating CDN cache for content category")

	patterns := []string{"content_category:*"}
	return h.invalidateCache(ctx, patterns)
}

func (h *CDNCacheHandler) HandleContentEvent(ctx context.Context, event eventbus.DomainEvent) error {
	log.Ctx(ctx).Info().
		Str("event", event.EventName()).
		Msg("invalidating CDN cache for content")

	patterns := []string{"content:*"}
	return h.invalidateCache(ctx, patterns)
}

func (h *CDNCacheHandler) HandleUserEvent(ctx context.Context, event eventbus.DomainEvent) error {
	log.Ctx(ctx).Info().
		Str("event", event.EventName()).
		Msg("invalidating CDN cache for user")

	patterns := []string{"user:*"}
	return h.invalidateCache(ctx, patterns)
}

func (h *CDNCacheHandler) invalidateCache(ctx context.Context, patterns []string) error {
	for _, pattern := range patterns {
		iter := h.cache.Scan(ctx, 0, pattern, 100).Iterator()
		for iter.Next(ctx) {
			if err := h.cache.Del(ctx, iter.Val()).Err(); err != nil {
				return fmt.Errorf("failed to delete cache key %s: %w", iter.Val(), err)
			}
		}
		if err := iter.Err(); err != nil {
			return fmt.Errorf("failed to scan cache keys with pattern %s: %w", pattern, err)
		}
	}
	return nil
}

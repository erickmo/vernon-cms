package cache

import (
	"github.com/redis/go-redis/v9"

	"github.com/erickmo/vernon-cms/infrastructure/config"
)

func NewRedisClient(cfg *config.Config) (*redis.Client, error) {
	opts, err := redis.ParseURL(cfg.Redis.URL)
	if err != nil {
		return nil, err
	}

	return redis.NewClient(opts), nil
}

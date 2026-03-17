package config

import (
	"time"

	"github.com/spf13/viper"
)

type Config struct {
	App      AppConfig
	HTTP     HTTPConfig
	JWT      JWTConfig
	Database DatabaseConfig
	Redis    RedisConfig
	NATS     NATSConfig
	OTel     OTelConfig
}

type JWTConfig struct {
	Secret        string        `mapstructure:"JWT_SECRET"`
	AccessExpiry  time.Duration `mapstructure:"JWT_ACCESS_EXPIRY"`
	RefreshExpiry time.Duration `mapstructure:"JWT_REFRESH_EXPIRY"`
}

type AppConfig struct {
	Name        string `mapstructure:"APP_NAME"`
	Env         string `mapstructure:"APP_ENV"`
	CORSOrigins string `mapstructure:"CORS_ALLOWED_ORIGINS"`
}

type HTTPConfig struct {
	Port         string        `mapstructure:"HTTP_PORT"`
	ReadTimeout  time.Duration `mapstructure:"HTTP_READ_TIMEOUT"`
	WriteTimeout time.Duration `mapstructure:"HTTP_WRITE_TIMEOUT"`
}

type DatabaseConfig struct {
	URL             string        `mapstructure:"DATABASE_URL"`
	MaxOpenConns    int           `mapstructure:"DB_MAX_OPEN_CONNS"`
	MaxIdleConns    int           `mapstructure:"DB_MAX_IDLE_CONNS"`
	ConnMaxLifetime time.Duration `mapstructure:"DB_CONN_MAX_LIFETIME"`
}

type RedisConfig struct {
	URL        string `mapstructure:"REDIS_URL"`
	TTLSeconds int    `mapstructure:"REDIS_TTL_SECONDS"`
}

type NATSConfig struct {
	URL        string `mapstructure:"NATS_URL"`
	StreamName string `mapstructure:"NATS_STREAM_NAME"`
}

type OTelConfig struct {
	Endpoint       string `mapstructure:"OTEL_EXPORTER_OTLP_ENDPOINT"`
	PrometheusPort string `mapstructure:"PROMETHEUS_PORT"`
}

func Load() (*Config, error) {
	viper.SetConfigFile(".env")
	viper.AutomaticEnv()

	_ = viper.ReadInConfig()

	viper.SetDefault("APP_NAME", "vernon-cms")
	viper.SetDefault("APP_ENV", "development")
	viper.SetDefault("HTTP_PORT", "8080")
	viper.SetDefault("HTTP_READ_TIMEOUT", "15s")
	viper.SetDefault("HTTP_WRITE_TIMEOUT", "15s")
	viper.SetDefault("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/vernon_cms_db?sslmode=disable")
	viper.SetDefault("DB_MAX_OPEN_CONNS", 25)
	viper.SetDefault("DB_MAX_IDLE_CONNS", 5)
	viper.SetDefault("DB_CONN_MAX_LIFETIME", "5m")
	viper.SetDefault("REDIS_URL", "redis://localhost:6379/0")
	viper.SetDefault("REDIS_TTL_SECONDS", 300)
	viper.SetDefault("NATS_URL", "nats://localhost:4222")
	viper.SetDefault("NATS_STREAM_NAME", "VERNON_CMS_EVENTS")
	viper.SetDefault("JWT_SECRET", "change-me-in-production-minimum-32-chars!")
	viper.SetDefault("JWT_ACCESS_EXPIRY", "15m")
	viper.SetDefault("JWT_REFRESH_EXPIRY", "168h")
	viper.SetDefault("CORS_ALLOWED_ORIGINS", "http://localhost:3000")
	viper.SetDefault("MAX_BODY_SIZE", 1048576)
	viper.SetDefault("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4318")
	viper.SetDefault("PROMETHEUS_PORT", "9090")

	cfg := &Config{
		App: AppConfig{
			Name:        viper.GetString("APP_NAME"),
			Env:         viper.GetString("APP_ENV"),
			CORSOrigins: viper.GetString("CORS_ALLOWED_ORIGINS"),
		},
		HTTP: HTTPConfig{
			Port:         viper.GetString("HTTP_PORT"),
			ReadTimeout:  viper.GetDuration("HTTP_READ_TIMEOUT"),
			WriteTimeout: viper.GetDuration("HTTP_WRITE_TIMEOUT"),
		},
		Database: DatabaseConfig{
			URL:             viper.GetString("DATABASE_URL"),
			MaxOpenConns:    viper.GetInt("DB_MAX_OPEN_CONNS"),
			MaxIdleConns:    viper.GetInt("DB_MAX_IDLE_CONNS"),
			ConnMaxLifetime: viper.GetDuration("DB_CONN_MAX_LIFETIME"),
		},
		JWT: JWTConfig{
			Secret:        viper.GetString("JWT_SECRET"),
			AccessExpiry:  viper.GetDuration("JWT_ACCESS_EXPIRY"),
			RefreshExpiry: viper.GetDuration("JWT_REFRESH_EXPIRY"),
		},
		Redis: RedisConfig{
			URL:        viper.GetString("REDIS_URL"),
			TTLSeconds: viper.GetInt("REDIS_TTL_SECONDS"),
		},
		NATS: NATSConfig{
			URL:        viper.GetString("NATS_URL"),
			StreamName: viper.GetString("NATS_STREAM_NAME"),
		},
		OTel: OTelConfig{
			Endpoint:       viper.GetString("OTEL_EXPORTER_OTLP_ENDPOINT"),
			PrometheusPort: viper.GetString("PROMETHEUS_PORT"),
		},
	}

	return cfg, nil
}

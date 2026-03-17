package telemetry

import (
	"go.opentelemetry.io/otel/exporters/prometheus"
	"go.opentelemetry.io/otel/metric"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
)

type Metrics struct {
	CommandDuration  metric.Float64Histogram
	CommandCount     metric.Int64Counter
	QueryDuration    metric.Float64Histogram
	QueryCount       metric.Int64Counter
	CacheHitCount    metric.Int64Counter
	CacheMissCount   metric.Int64Counter
	HTTPRequestCount metric.Int64Counter
	HTTPDuration     metric.Float64Histogram
}

func InitMetrics() (*Metrics, *prometheus.Exporter, error) {
	exporter, err := prometheus.New()
	if err != nil {
		return nil, nil, err
	}

	provider := sdkmetric.NewMeterProvider(sdkmetric.WithReader(exporter))
	meter := provider.Meter("vernon-cms")

	m := &Metrics{}

	m.CommandDuration, err = meter.Float64Histogram("cms.command.duration",
		metric.WithDescription("Command execution duration in seconds"),
		metric.WithUnit("s"),
	)
	if err != nil {
		return nil, nil, err
	}

	m.CommandCount, err = meter.Int64Counter("cms.command.count",
		metric.WithDescription("Total commands executed"),
	)
	if err != nil {
		return nil, nil, err
	}

	m.QueryDuration, err = meter.Float64Histogram("cms.query.duration",
		metric.WithDescription("Query execution duration in seconds"),
		metric.WithUnit("s"),
	)
	if err != nil {
		return nil, nil, err
	}

	m.QueryCount, err = meter.Int64Counter("cms.query.count",
		metric.WithDescription("Total queries executed"),
	)
	if err != nil {
		return nil, nil, err
	}

	m.CacheHitCount, err = meter.Int64Counter("cms.cache.hit",
		metric.WithDescription("Cache hit count"),
	)
	if err != nil {
		return nil, nil, err
	}

	m.CacheMissCount, err = meter.Int64Counter("cms.cache.miss",
		metric.WithDescription("Cache miss count"),
	)
	if err != nil {
		return nil, nil, err
	}

	m.HTTPRequestCount, err = meter.Int64Counter("cms.http.request.count",
		metric.WithDescription("Total HTTP requests"),
	)
	if err != nil {
		return nil, nil, err
	}

	m.HTTPDuration, err = meter.Float64Histogram("cms.http.duration",
		metric.WithDescription("HTTP request duration in seconds"),
		metric.WithUnit("s"),
	)
	if err != nil {
		return nil, nil, err
	}

	return m, exporter, nil
}

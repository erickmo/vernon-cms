package querybus

import (
	"context"
	"fmt"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/infrastructure/telemetry"
)

type Query interface {
	QueryName() string
}

type QueryHandler interface {
	Handle(ctx context.Context, q Query) (interface{}, error)
}

type QueryHandlerFunc func(ctx context.Context, q Query) (interface{}, error)

func (f QueryHandlerFunc) Handle(ctx context.Context, q Query) (interface{}, error) {
	return f(ctx, q)
}

type QueryBus struct {
	handlers map[string]QueryHandler
	metrics  *telemetry.Metrics
	tracer   trace.Tracer
}

func New(metrics *telemetry.Metrics) *QueryBus {
	return &QueryBus{
		handlers: make(map[string]QueryHandler),
		metrics:  metrics,
		tracer:   otel.Tracer("querybus"),
	}
}

func (b *QueryBus) Register(name string, handler QueryHandler) {
	b.handlers[name] = handler
}

func (b *QueryBus) Dispatch(ctx context.Context, q Query) (interface{}, error) {
	handler, ok := b.handlers[q.QueryName()]
	if !ok {
		return nil, fmt.Errorf("no handler registered for query: %s", q.QueryName())
	}

	ctx, span := b.tracer.Start(ctx, "query."+q.QueryName(),
		trace.WithAttributes(attribute.String("query.name", q.QueryName())),
	)
	defer span.End()

	start := time.Now()
	result, err := handler.Handle(ctx, q)
	duration := time.Since(start).Seconds()

	if b.metrics != nil {
		b.metrics.QueryDuration.Record(ctx, duration,
			telemetry.QueryAttrSet(q.QueryName(), err))
		b.metrics.QueryCount.Add(ctx, 1,
			telemetry.QueryAttrSet(q.QueryName(), err))
	}

	if err != nil {
		span.RecordError(err)
	}

	return result, err
}

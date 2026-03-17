package commandbus

import (
	"context"
	"fmt"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/infrastructure/telemetry"
)

type Command interface {
	CommandName() string
}

type CommandHandler interface {
	Handle(ctx context.Context, cmd Command) error
}

type CommandHandlerFunc func(ctx context.Context, cmd Command) error

func (f CommandHandlerFunc) Handle(ctx context.Context, cmd Command) error {
	return f(ctx, cmd)
}

type Hook interface {
	Before(ctx context.Context, cmd Command) error
	After(ctx context.Context, cmd Command, err error)
}

type CommandBus struct {
	handlers map[string]CommandHandler
	hooks    []Hook
	metrics  *telemetry.Metrics
	tracer   trace.Tracer
}

func New(metrics *telemetry.Metrics) *CommandBus {
	return &CommandBus{
		handlers: make(map[string]CommandHandler),
		metrics:  metrics,
		tracer:   otel.Tracer("commandbus"),
	}
}

func (b *CommandBus) Register(name string, handler CommandHandler) {
	b.handlers[name] = handler
}

func (b *CommandBus) Use(hook Hook) {
	b.hooks = append(b.hooks, hook)
}

func (b *CommandBus) Dispatch(ctx context.Context, cmd Command) error {
	handler, ok := b.handlers[cmd.CommandName()]
	if !ok {
		return fmt.Errorf("no handler registered for command: %s", cmd.CommandName())
	}

	ctx, span := b.tracer.Start(ctx, "command."+cmd.CommandName(),
		trace.WithAttributes(attribute.String("command.name", cmd.CommandName())),
	)
	defer span.End()

	start := time.Now()

	for _, h := range b.hooks {
		if err := h.Before(ctx, cmd); err != nil {
			span.RecordError(err)
			return fmt.Errorf("pre-hook failed: %w", err)
		}
	}

	err := handler.Handle(ctx, cmd)

	for i := len(b.hooks) - 1; i >= 0; i-- {
		b.hooks[i].After(ctx, cmd, err)
	}

	duration := time.Since(start).Seconds()
	if b.metrics != nil {
		b.metrics.CommandDuration.Record(ctx, duration,
			telemetry.CommandAttrSet(cmd.CommandName(), err))
		b.metrics.CommandCount.Add(ctx, 1,
			telemetry.CommandAttrSet(cmd.CommandName(), err))
	}

	if err != nil {
		span.RecordError(err)
	}

	return err
}

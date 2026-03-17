package eventbus

import (
	"context"
	"encoding/json"
	"sync"
	"time"

	"github.com/ThreeDotsLabs/watermill"
	"github.com/ThreeDotsLabs/watermill/message"
	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
)

type DomainEvent interface {
	EventName() string
	OccurredAt() time.Time
}

type EventHandler func(ctx context.Context, event DomainEvent) error

type EventBus interface {
	Publish(ctx context.Context, event DomainEvent) error
	Subscribe(eventName string, handler EventHandler)
}

type WatermillEventBus struct {
	publisher  message.Publisher
	subscriber message.Subscriber
	handlers   map[string][]EventHandler
	mu         sync.RWMutex
}

func NewWatermillEventBus(publisher message.Publisher, subscriber message.Subscriber) *WatermillEventBus {
	return &WatermillEventBus{
		publisher:  publisher,
		subscriber: subscriber,
		handlers:   make(map[string][]EventHandler),
	}
}

func (b *WatermillEventBus) Publish(ctx context.Context, event DomainEvent) error {
	payload, err := json.Marshal(event)
	if err != nil {
		return err
	}

	msg := message.NewMessage(uuid.New().String(), payload)
	msg.Metadata.Set("event_name", event.EventName())
	msg.Metadata.Set("occurred_at", event.OccurredAt().Format(time.RFC3339))

	log.Ctx(ctx).Info().
		Str("event", event.EventName()).
		Str("message_id", msg.UUID).
		Msg("publishing domain event")

	return b.publisher.Publish(event.EventName(), msg)
}

func (b *WatermillEventBus) Subscribe(eventName string, handler EventHandler) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.handlers[eventName] = append(b.handlers[eventName], handler)
}

func (b *WatermillEventBus) StartSubscribers(ctx context.Context) error {
	b.mu.RLock()
	defer b.mu.RUnlock()

	for eventName, handlers := range b.handlers {
		messages, err := b.subscriber.Subscribe(ctx, eventName)
		if err != nil {
			return err
		}

		for _, h := range handlers {
			go b.processMessages(ctx, eventName, messages, h)
		}
	}

	return nil
}

func (b *WatermillEventBus) processMessages(ctx context.Context, eventName string, messages <-chan *message.Message, handler EventHandler) {
	for msg := range messages {
		if err := handler(ctx, &RawEvent{
			Name:    eventName,
			Payload: msg.Payload,
			Time:    time.Now(),
		}); err != nil {
			log.Error().Err(err).Str("event", eventName).Msg("event handler failed")
			msg.Nack()
			continue
		}
		msg.Ack()
	}
}

type RawEvent struct {
	Name    string
	Payload []byte
	Time    time.Time
}

func (e *RawEvent) EventName() string    { return e.Name }
func (e *RawEvent) OccurredAt() time.Time { return e.Time }

type InMemoryEventBus struct {
	handlers map[string][]EventHandler
	mu       sync.RWMutex
}

func NewInMemoryEventBus() *InMemoryEventBus {
	return &InMemoryEventBus{
		handlers: make(map[string][]EventHandler),
	}
}

func (b *InMemoryEventBus) Publish(ctx context.Context, event DomainEvent) error {
	b.mu.RLock()
	handlers := b.handlers[event.EventName()]
	b.mu.RUnlock()

	for _, h := range handlers {
		if err := h(ctx, event); err != nil {
			log.Ctx(ctx).Error().Err(err).
				Str("event", event.EventName()).
				Msg("in-memory event handler failed")
		}
	}
	return nil
}

func (b *InMemoryEventBus) Subscribe(eventName string, handler EventHandler) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.handlers[eventName] = append(b.handlers[eventName], handler)
}

func NewWatermillLogger() watermill.LoggerAdapter {
	return watermill.NewStdLogger(false, false)
}

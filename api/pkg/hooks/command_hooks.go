package hooks

import (
	"context"

	"github.com/rs/zerolog/log"

	"github.com/erickmo/vernon-cms/pkg/commandbus"
)

type LoggingHook struct{}

func (h *LoggingHook) Before(ctx context.Context, cmd commandbus.Command) error {
	log.Ctx(ctx).Info().
		Str("command", cmd.CommandName()).
		Msg("executing command")
	return nil
}

func (h *LoggingHook) After(ctx context.Context, cmd commandbus.Command, err error) {
	if err != nil {
		log.Ctx(ctx).Error().Err(err).
			Str("command", cmd.CommandName()).
			Msg("command failed")
		return
	}
	log.Ctx(ctx).Info().
		Str("command", cmd.CommandName()).
		Msg("command completed")
}

type ValidationHook struct{}

func (h *ValidationHook) Before(ctx context.Context, cmd commandbus.Command) error {
	if v, ok := cmd.(interface{ Validate() error }); ok {
		return v.Validate()
	}
	return nil
}

func (h *ValidationHook) After(_ context.Context, _ commandbus.Command, _ error) {}

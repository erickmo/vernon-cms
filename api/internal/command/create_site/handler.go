package createsite

import (
	"context"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/site"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	Name         string `json:"name" validate:"required"`
	Slug         string `json:"slug" validate:"required"`
	CustomDomain string `json:"custom_domain" validate:"required"`
}

func (c Command) CommandName() string { return "CreateSite" }

type Handler struct {
	repo     site.WriteRepository
	eventBus eventbus.EventBus
	tracer   trace.Tracer
}

func NewHandler(repo site.WriteRepository, eventBus eventbus.EventBus) *Handler {
	return &Handler{
		repo:     repo,
		eventBus: eventBus,
		tracer:   otel.Tracer("command.create_site"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)

	ctx, span := h.tracer.Start(ctx, "CreateSite.Handle")
	defer span.End()

	claims := middleware.GetClaims(ctx)
	if claims == nil {
		return &unauthorizedError{}
	}

	s, err := site.NewSite(c.Name, c.Slug, c.CustomDomain, claims.UserID)
	if err != nil {
		return err
	}

	if err := h.repo.Save(s); err != nil {
		return err
	}

	// Add owner as admin member
	member, err := site.NewSiteMember(s.ID, claims.UserID, site.SiteRoleAdmin, nil)
	if err != nil {
		return err
	}
	if err := h.repo.SaveMember(member); err != nil {
		return err
	}

	return h.eventBus.Publish(ctx, site.SiteCreated{
		SiteID:  s.ID,
		Name:    s.Name,
		Slug:    s.Slug,
		Domain:  s.CustomDomain,
		OwnerID: s.OwnerID,
		Time:    time.Now(),
	})
}

type unauthorizedError struct{}

func (e *unauthorizedError) Error() string { return "unauthorized" }

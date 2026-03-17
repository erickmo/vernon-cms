package eventhandler

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/rs/zerolog/log"

	"github.com/erickmo/vernon-cms/internal/domain/content"
	"github.com/erickmo/vernon-cms/internal/domain/page"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
)

// ActivityLogHandler listens to domain events and persists activity log records.
// Errors are swallowed to avoid disrupting the main request flow.
type ActivityLogHandler struct {
	db *sqlx.DB
}

func NewActivityLogHandler(db *sqlx.DB) *ActivityLogHandler {
	return &ActivityLogHandler{db: db}
}

func (h *ActivityLogHandler) HandleContentEvent(ctx context.Context, event eventbus.DomainEvent) error {
	var action string
	var entityID *uuid.UUID
	var entityTitle *string
	var userID *uuid.UUID
	var siteID uuid.UUID

	switch e := event.(type) {
	case content.ContentCreated:
		action = "created"
		entityID = &e.ContentID
		entityTitle = &e.Title
		userID = &e.AuthorID
		siteID, _ = h.getSiteIDFromContent(ctx, e.ContentID)
	case content.ContentUpdated:
		action = "updated"
		entityID = &e.ContentID
		entityTitle = &e.Title
		siteID, _ = h.getSiteIDFromContent(ctx, e.ContentID)
	case content.ContentPublished:
		action = "published"
		entityID = &e.ContentID
		entityTitle = &e.Title
		siteID, _ = h.getSiteIDFromContent(ctx, e.ContentID)
	case content.ContentDeleted:
		action = "deleted"
		entityID = &e.ContentID
		siteID, _ = h.getSiteIDFromContent(ctx, e.ContentID)
	default:
		return nil
	}

	if siteID == uuid.Nil {
		return nil
	}

	h.insertLog(ctx, siteID, userID, action, "content", entityID, entityTitle)
	return nil
}

func (h *ActivityLogHandler) HandlePageEvent(ctx context.Context, event eventbus.DomainEvent) error {
	var action string
	var entityID *uuid.UUID
	var entityTitle *string
	var siteID uuid.UUID

	switch e := event.(type) {
	case page.PageCreated:
		action = "created"
		entityID = &e.PageID
		entityTitle = &e.Name
		siteID, _ = h.getSiteIDFromPage(ctx, e.PageID)
	case page.PageUpdated:
		action = "updated"
		entityID = &e.PageID
		entityTitle = &e.Name
		siteID, _ = h.getSiteIDFromPage(ctx, e.PageID)
	case page.PageDeleted:
		action = "deleted"
		entityID = &e.PageID
		siteID, _ = h.getSiteIDFromPage(ctx, e.PageID)
	default:
		return nil
	}

	if siteID == uuid.Nil {
		return nil
	}

	h.insertLog(ctx, siteID, nil, action, "page", entityID, entityTitle)
	return nil
}

func (h *ActivityLogHandler) getSiteIDFromContent(ctx context.Context, contentID uuid.UUID) (uuid.UUID, error) {
	var siteID uuid.UUID
	err := h.db.GetContext(ctx, &siteID, `SELECT site_id FROM contents WHERE id = $1`, contentID)
	return siteID, err
}

func (h *ActivityLogHandler) getSiteIDFromPage(ctx context.Context, pageID uuid.UUID) (uuid.UUID, error) {
	var siteID uuid.UUID
	err := h.db.GetContext(ctx, &siteID, `SELECT site_id FROM pages WHERE id = $1`, pageID)
	return siteID, err
}

func (h *ActivityLogHandler) insertLog(
	ctx context.Context,
	siteID uuid.UUID,
	userID *uuid.UUID,
	action, entityType string,
	entityID *uuid.UUID,
	entityTitle *string,
) {
	userName := "System"
	if userID != nil {
		var name string
		if err := h.db.GetContext(ctx, &name, `SELECT name FROM users WHERE id = $1`, *userID); err == nil {
			userName = name
		}
	}

	_, err := h.db.ExecContext(ctx, `
		INSERT INTO activity_logs (
			id, site_id, user_id, user_name, action, entity_type,
			entity_id, entity_title, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`,
		uuid.New(), siteID, userID, userName, action, entityType,
		entityID, entityTitle, time.Now(),
	)
	if err != nil {
		log.Ctx(ctx).Error().Err(err).
			Str("action", action).
			Str("entity_type", entityType).
			Msg("failed to insert activity log")
	}
}

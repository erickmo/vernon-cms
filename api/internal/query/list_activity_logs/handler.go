package listactivitylogs

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID     uuid.UUID
	Search     string
	Action     string
	EntityType string
	UserID     string
	DateFrom   string
	DateTo     string
	Page       int
	PerPage    int
}

func (q Query) QueryName() string { return "ListActivityLogs" }

type ActivityLogItem struct {
	ID           uuid.UUID  `json:"id" db:"id"`
	Action       string     `json:"action" db:"action"`
	EntityType   string     `json:"entity_type" db:"entity_type"`
	EntityID     *uuid.UUID `json:"entity_id,omitempty" db:"entity_id"`
	EntityTitle  *string    `json:"entity_title,omitempty" db:"entity_title"`
	UserID       *uuid.UUID `json:"user_id" db:"user_id"`
	UserName     string     `json:"user_name" db:"user_name"`
	UserAvatarURL *string   `json:"user_avatar_url,omitempty" db:"user_avatar_url"`
	Details      *string    `json:"details,omitempty" db:"details"`
	IPAddress    *string    `json:"ip_address,omitempty" db:"ip_address"`
	CreatedAt    time.Time  `json:"created_at" db:"created_at"`
}

type Handler struct {
	db *sqlx.DB
}

func NewHandler(db *sqlx.DB) *Handler {
	return &Handler{db: db}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	limit := query.PerPage
	if limit <= 0 {
		limit = 20
	}
	offset := 0
	if query.Page > 1 {
		offset = (query.Page - 1) * limit
	}

	var items []*ActivityLogItem
	err := h.db.SelectContext(ctx, &items, `
		SELECT
			al.id, al.action, al.entity_type, al.entity_id, al.entity_title,
			al.user_id, al.user_name, al.details,
			CAST(al.ip_address AS TEXT) AS ip_address,
			NULL::TEXT AS user_avatar_url,
			al.created_at
		FROM activity_logs al
		WHERE al.site_id = $1
		ORDER BY al.created_at DESC
		LIMIT $2 OFFSET $3`,
		query.SiteID, limit, offset,
	)
	if err != nil {
		return []*ActivityLogItem{}, nil
	}
	return items, nil
}

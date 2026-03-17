package getdailycontentstats

import (
	"context"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID uuid.UUID
	Days   int
}

func (q Query) QueryName() string { return "GetDailyContentStats" }

type DayItem struct {
	Date  string `json:"date" db:"date"`
	Count int    `json:"count" db:"count"`
}

type Handler struct {
	db *sqlx.DB
}

func NewHandler(db *sqlx.DB) *Handler {
	return &Handler{db: db}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)
	days := query.Days
	if days <= 0 {
		days = 7
	}

	var items []*DayItem
	err := h.db.SelectContext(ctx, &items, `
		SELECT
			TO_CHAR(gs.day, 'YYYY-MM-DD') AS date,
			COALESCE(COUNT(c.id), 0)::int AS count
		FROM generate_series(
			NOW() - ($2 || ' days')::interval,
			NOW(),
			INTERVAL '1 day'
		) AS gs(day)
		LEFT JOIN contents c
			ON DATE_TRUNC('day', c.created_at) = DATE_TRUNC('day', gs.day)
			AND c.site_id = $1
		GROUP BY gs.day
		ORDER BY gs.day ASC`,
		query.SiteID,
		days,
	)
	if err != nil {
		return []*DayItem{}, nil
	}
	return items, nil
}

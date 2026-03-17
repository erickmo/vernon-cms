package getdashboardstats

import (
	"context"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type Query struct {
	SiteID uuid.UUID
}

func (q Query) QueryName() string { return "GetDashboardStats" }

type Result struct {
	TotalPosts          int     `json:"total_posts"`
	TotalVisits         int     `json:"total_visits"`
	TodayVisits         int     `json:"today_visits"`
	VisitGrowthPercent  float64 `json:"visit_growth_percent"`
}

type Handler struct {
	db *sqlx.DB
}

func NewHandler(db *sqlx.DB) *Handler {
	return &Handler{db: db}
}

func (h *Handler) Handle(ctx context.Context, q querybus.Query) (interface{}, error) {
	query := q.(Query)

	var totalPosts int
	if err := h.db.GetContext(ctx, &totalPosts,
		`SELECT COUNT(*) FROM contents WHERE site_id = $1 AND status = 'published'`,
		query.SiteID,
	); err != nil {
		totalPosts = 0
	}

	return &Result{
		TotalPosts:         totalPosts,
		TotalVisits:        0,
		TodayVisits:        0,
		VisitGrowthPercent: 0,
	}, nil
}

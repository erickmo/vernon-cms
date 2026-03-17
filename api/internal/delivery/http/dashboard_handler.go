package http

import (
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	getdailycontentstats "github.com/erickmo/vernon-cms/internal/query/get_daily_content_stats"
	getdashboardstats "github.com/erickmo/vernon-cms/internal/query/get_dashboard_stats"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type DashboardHandler struct {
	queryBus *querybus.QueryBus
}

func NewDashboardHandler(queryBus *querybus.QueryBus) *DashboardHandler {
	return &DashboardHandler{queryBus: queryBus}
}

func (h *DashboardHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/dashboard", func(r chi.Router) {
		r.Get("/stats", h.GetStats)
		r.Get("/daily-content", h.GetDailyContent)
	})
}

func (h *DashboardHandler) GetStats(w http.ResponseWriter, r *http.Request) {
	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), getdashboardstats.Query{SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

func (h *DashboardHandler) GetDailyContent(w http.ResponseWriter, r *http.Request) {
	days, _ := strconv.Atoi(r.URL.Query().Get("days"))
	if days <= 0 {
		days = 7
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), getdailycontentstats.Query{SiteID: siteID, Days: days})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

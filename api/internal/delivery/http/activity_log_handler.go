package http

import (
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	listactivitylogs "github.com/erickmo/vernon-cms/internal/query/list_activity_logs"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type ActivityLogHandler struct {
	queryBus *querybus.QueryBus
}

func NewActivityLogHandler(queryBus *querybus.QueryBus) *ActivityLogHandler {
	return &ActivityLogHandler{queryBus: queryBus}
}

func (h *ActivityLogHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/activity-logs", func(r chi.Router) {
		r.Get("/", h.List)
	})
}

func (h *ActivityLogHandler) List(w http.ResponseWriter, r *http.Request) {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	perPage, _ := strconv.Atoi(r.URL.Query().Get("per_page"))
	if page <= 0 {
		page = 1
	}
	if perPage <= 0 {
		perPage = 20
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), listactivitylogs.Query{
		SiteID:     siteID,
		Search:     r.URL.Query().Get("search"),
		Action:     r.URL.Query().Get("action"),
		EntityType: r.URL.Query().Get("entity_type"),
		UserID:     r.URL.Query().Get("user_id"),
		DateFrom:   r.URL.Query().Get("date_from"),
		DateTo:     r.URL.Query().Get("date_to"),
		Page:       page,
		PerPage:    perPage,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

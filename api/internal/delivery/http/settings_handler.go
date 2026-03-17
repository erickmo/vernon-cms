package http

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"

	updatesettings "github.com/erickmo/vernon-cms/internal/command/update_settings"
	getsettings "github.com/erickmo/vernon-cms/internal/query/get_settings"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type SettingsHandler struct {
	cmdBus   *commandbus.CommandBus
	queryBus *querybus.QueryBus
	validate *validator.Validate
}

func NewSettingsHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *SettingsHandler {
	return &SettingsHandler{
		cmdBus:   cmdBus,
		queryBus: queryBus,
		validate: validator.New(),
	}
}

func (h *SettingsHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/settings", func(r chi.Router) {
		r.Get("/", h.Get)
		r.Put("/", h.Update)
	})
}

func (h *SettingsHandler) Get(w http.ResponseWriter, r *http.Request) {
	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), getsettings.Query{SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

func (h *SettingsHandler) Update(w http.ResponseWriter, r *http.Request) {
	var cmd updatesettings.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	// Return updated settings
	siteID := middleware.GetSiteID(r.Context())
	result, err := h.queryBus.Dispatch(r.Context(), getsettings.Query{SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

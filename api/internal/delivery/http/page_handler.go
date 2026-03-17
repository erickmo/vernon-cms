package http

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	createpage "github.com/erickmo/vernon-cms/internal/command/create_page"
	deletepage "github.com/erickmo/vernon-cms/internal/command/delete_page"
	updatepage "github.com/erickmo/vernon-cms/internal/command/update_page"
	getpage "github.com/erickmo/vernon-cms/internal/query/get_page"
	listpage "github.com/erickmo/vernon-cms/internal/query/list_page"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type PageHandler struct {
	cmdBus   *commandbus.CommandBus
	queryBus *querybus.QueryBus
	validate *validator.Validate
}

func NewPageHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *PageHandler {
	return &PageHandler{
		cmdBus:   cmdBus,
		queryBus: queryBus,
		validate: validator.New(),
	}
}

func (h *PageHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/pages", func(r chi.Router) {
		r.Post("/", h.Create)
		r.Get("/", h.List)
		r.Get("/{id}", h.GetByID)
		r.Put("/{id}", h.Update)
		r.Delete("/{id}", h.Delete)
	})
}

func (h *PageHandler) Create(w http.ResponseWriter, r *http.Request) {
	var cmd createpage.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.validate.Struct(cmd); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusCreated, map[string]string{"status": "created"})
}

func (h *PageHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid page id")
		return
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), getpage.Query{ID: id, SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *PageHandler) List(w http.ResponseWriter, r *http.Request) {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), listpage.Query{SiteID: siteID, Page: page, Limit: limit})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *PageHandler) Update(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid page id")
		return
	}

	var cmd updatepage.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	cmd.ID = id

	if err := h.validate.Struct(cmd); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "updated"})
}

func (h *PageHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid page id")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), deletepage.Command{ID: id}); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "deleted"})
}

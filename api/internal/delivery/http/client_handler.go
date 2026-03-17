package http

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	createclient "github.com/erickmo/vernon-cms/internal/command/create_client"
	deleteclient "github.com/erickmo/vernon-cms/internal/command/delete_client"
	toggleclient "github.com/erickmo/vernon-cms/internal/command/toggle_client"
	updateclient "github.com/erickmo/vernon-cms/internal/command/update_client"
	getclient "github.com/erickmo/vernon-cms/internal/query/get_client"
	listclients "github.com/erickmo/vernon-cms/internal/query/list_clients"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type ClientHandler struct {
	cmdBus   *commandbus.CommandBus
	queryBus *querybus.QueryBus
	validate *validator.Validate
}

func NewClientHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *ClientHandler {
	return &ClientHandler{
		cmdBus:   cmdBus,
		queryBus: queryBus,
		validate: validator.New(),
	}
}

func (h *ClientHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/clients", func(r chi.Router) {
		r.Get("/", h.List)
		r.Post("/", h.Create)
		r.Get("/{id}", h.GetByID)
		r.Put("/{id}", h.Update)
		r.Delete("/{id}", h.Delete)
		r.Patch("/{id}/toggle-active", h.ToggleActive)
	})
}

func (h *ClientHandler) List(w http.ResponseWriter, r *http.Request) {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	perPage, _ := strconv.Atoi(r.URL.Query().Get("per_page"))

	var isActive *bool
	if v := r.URL.Query().Get("is_active"); v != "" {
		b := v == "true"
		isActive = &b
	}

	result, err := h.queryBus.Dispatch(r.Context(), listclients.Query{
		Search:   r.URL.Query().Get("search"),
		IsActive: isActive,
		Page:     page,
		PerPage:  perPage,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *ClientHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid client id")
		return
	}

	result, err := h.queryBus.Dispatch(r.Context(), getclient.Query{ID: id})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *ClientHandler) Create(w http.ResponseWriter, r *http.Request) {
	var cmd createclient.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.validate.Struct(cmd); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	result := &createclient.Result{}
	ctx := createclient.WithResult(r.Context(), result)

	if err := h.cmdBus.Dispatch(ctx, cmd); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusCreated, result.Client)
}

func (h *ClientHandler) Update(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid client id")
		return
	}

	var cmd updateclient.Command
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

	result, err := h.queryBus.Dispatch(r.Context(), getclient.Query{ID: id})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *ClientHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid client id")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), deleteclient.Command{ID: id}); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *ClientHandler) ToggleActive(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid client id")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), toggleclient.Command{ID: id}); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	result, err := h.queryBus.Dispatch(r.Context(), getclient.Query{ID: id})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

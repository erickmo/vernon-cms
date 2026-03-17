package http

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	createuser "github.com/erickmo/vernon-cms/internal/command/create_user"
	deleteuser "github.com/erickmo/vernon-cms/internal/command/delete_user"
	updateuser "github.com/erickmo/vernon-cms/internal/command/update_user"
	getuser "github.com/erickmo/vernon-cms/internal/query/get_user"
	listuser "github.com/erickmo/vernon-cms/internal/query/list_user"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type UserHandler struct {
	cmdBus   *commandbus.CommandBus
	queryBus *querybus.QueryBus
	validate *validator.Validate
}

func NewUserHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *UserHandler {
	return &UserHandler{
		cmdBus:   cmdBus,
		queryBus: queryBus,
		validate: validator.New(),
	}
}

func (h *UserHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/users", func(r chi.Router) {
		r.Post("/", h.Create)
		r.Get("/", h.List)
		r.Get("/{id}", h.GetByID)
		r.Put("/{id}", h.Update)
		r.Delete("/{id}", h.Delete)
	})
}

func (h *UserHandler) Create(w http.ResponseWriter, r *http.Request) {
	var cmd createuser.Command
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

func (h *UserHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	result, err := h.queryBus.Dispatch(r.Context(), getuser.Query{ID: id})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *UserHandler) List(w http.ResponseWriter, r *http.Request) {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}

	result, err := h.queryBus.Dispatch(r.Context(), listuser.Query{Page: page, Limit: limit})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *UserHandler) Update(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	var cmd updateuser.Command
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

func (h *UserHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), deleteuser.Command{ID: id}); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "deleted"})
}

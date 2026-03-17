package http

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	createapitoken "github.com/erickmo/vernon-cms/internal/command/create_api_token"
	deleteapitoken "github.com/erickmo/vernon-cms/internal/command/delete_api_token"
	toggleapitoken "github.com/erickmo/vernon-cms/internal/command/toggle_api_token"
	updateapitoken "github.com/erickmo/vernon-cms/internal/command/update_api_token"
	listapitoken "github.com/erickmo/vernon-cms/internal/query/list_api_tokens"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type APITokenHandler struct {
	cmdBus   *commandbus.CommandBus
	queryBus *querybus.QueryBus
	validate *validator.Validate
}

func NewAPITokenHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *APITokenHandler {
	return &APITokenHandler{
		cmdBus:   cmdBus,
		queryBus: queryBus,
		validate: validator.New(),
	}
}

func (h *APITokenHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/tokens", func(r chi.Router) {
		r.Get("/", h.List)
		r.Post("/", h.Create)
		r.Put("/{id}", h.Update)
		r.Delete("/{id}", h.Delete)
		r.Put("/{id}/toggle-active", h.ToggleActive)
	})
}

func (h *APITokenHandler) List(w http.ResponseWriter, r *http.Request) {
	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), listapitoken.Query{SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

func (h *APITokenHandler) Create(w http.ResponseWriter, r *http.Request) {
	var cmd createapitoken.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.validate.Struct(cmd); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	result := &createapitoken.Result{}
	ctx := createapitoken.WithResult(r.Context(), result)

	if err := h.cmdBus.Dispatch(ctx, cmd); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	if result.Token == nil {
		writeError(w, http.StatusInternalServerError, "failed to create token")
		return
	}

	writeFlatJSON(w, http.StatusCreated, map[string]interface{}{
		"id":          result.Token.ID,
		"name":        result.Token.Name,
		"token":       result.Plain,
		"prefix":      result.Token.Prefix,
		"permissions": result.Token.Permissions,
		"expires_at":  result.Token.ExpiresAt,
		"is_active":   result.Token.IsActive,
		"created_at":  result.Token.CreatedAt,
	})
}

func (h *APITokenHandler) Update(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid token id")
		return
	}

	var cmd updateapitoken.Command
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

func (h *APITokenHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid token id")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), deleteapitoken.Command{ID: id}); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *APITokenHandler) ToggleActive(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid token id")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), toggleapitoken.Command{ID: id}); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "toggled"})
}

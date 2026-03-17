package http

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	addsitemember "github.com/erickmo/vernon-cms/internal/command/add_site_member"
	createsite "github.com/erickmo/vernon-cms/internal/command/create_site"
	deletesite "github.com/erickmo/vernon-cms/internal/command/delete_site"
	removesitemember "github.com/erickmo/vernon-cms/internal/command/remove_site_member"
	updatesite "github.com/erickmo/vernon-cms/internal/command/update_site"
	updatesitememberrole "github.com/erickmo/vernon-cms/internal/command/update_site_member_role"
	getsite "github.com/erickmo/vernon-cms/internal/query/get_site"
	listsite "github.com/erickmo/vernon-cms/internal/query/list_site"
	listsitemember "github.com/erickmo/vernon-cms/internal/query/list_site_member"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type SiteHandler struct {
	cmdBus   *commandbus.CommandBus
	queryBus *querybus.QueryBus
	validate *validator.Validate
}

func NewSiteHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *SiteHandler {
	return &SiteHandler{
		cmdBus:   cmdBus,
		queryBus: queryBus,
		validate: validator.New(),
	}
}

func (h *SiteHandler) Create(w http.ResponseWriter, r *http.Request) {
	var cmd createsite.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.validate.Struct(cmd); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeAppError(w, err)
		return
	}

	writeJSON(w, http.StatusCreated, map[string]string{"status": "created"})
}

func (h *SiteHandler) ListMySites(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetClaims(r.Context())
	if claims == nil {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}

	result, err := h.queryBus.Dispatch(r.Context(), listsite.Query{UserID: claims.UserID, Page: page, Limit: limit})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *SiteHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid site id")
		return
	}

	result, err := h.queryBus.Dispatch(r.Context(), getsite.Query{ID: id})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *SiteHandler) Update(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid site id")
		return
	}

	var cmd updatesite.Command
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
		writeAppError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "updated"})
}

func (h *SiteHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid site id")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), deletesite.Command{ID: id}); err != nil {
		writeAppError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "deleted"})
}

func (h *SiteHandler) ListMembers(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid site id")
		return
	}

	result, err := h.queryBus.Dispatch(r.Context(), listsitemember.Query{SiteID: id})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *SiteHandler) AddMember(w http.ResponseWriter, r *http.Request) {
	siteID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid site id")
		return
	}

	var body struct {
		UserID uuid.UUID `json:"user_id" validate:"required"`
		Role   string    `json:"role" validate:"required,oneof=admin editor viewer"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := h.validate.Struct(body); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	claims := middleware.GetClaims(r.Context())
	invitedBy := uuid.Nil
	if claims != nil {
		invitedBy = claims.UserID
	}

	cmd := addsitemember.Command{
		SiteID:    siteID,
		UserID:    body.UserID,
		Role:      body.Role,
		InvitedBy: invitedBy,
	}

	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeAppError(w, err)
		return
	}

	writeJSON(w, http.StatusCreated, map[string]string{"status": "member added"})
}

func (h *SiteHandler) UpdateMemberRole(w http.ResponseWriter, r *http.Request) {
	siteID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid site id")
		return
	}

	userID, err := uuid.Parse(chi.URLParam(r, "userID"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	var body struct {
		Role string `json:"role" validate:"required,oneof=admin editor viewer"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := h.validate.Struct(body); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	cmd := updatesitememberrole.Command{
		SiteID: siteID,
		UserID: userID,
		Role:   body.Role,
	}

	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeAppError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "role updated"})
}

func (h *SiteHandler) RemoveMember(w http.ResponseWriter, r *http.Request) {
	siteID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid site id")
		return
	}

	userID, err := uuid.Parse(chi.URLParam(r, "userID"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	cmd := removesitemember.Command{SiteID: siteID, UserID: userID}
	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeAppError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "member removed"})
}

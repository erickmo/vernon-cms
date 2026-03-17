package http

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	createdata "github.com/erickmo/vernon-cms/internal/command/create_data"
	createdatarecord "github.com/erickmo/vernon-cms/internal/command/create_data_record"
	deletedata "github.com/erickmo/vernon-cms/internal/command/delete_data"
	deletedatarecord "github.com/erickmo/vernon-cms/internal/command/delete_data_record"
	updatedata "github.com/erickmo/vernon-cms/internal/command/update_data"
	updatedatarecord "github.com/erickmo/vernon-cms/internal/command/update_data_record"
	getdata "github.com/erickmo/vernon-cms/internal/query/get_data"
	getdatarecord "github.com/erickmo/vernon-cms/internal/query/get_data_record"
	listdata "github.com/erickmo/vernon-cms/internal/query/list_data"
	listdatarecord "github.com/erickmo/vernon-cms/internal/query/list_data_record"
	listdatarecordoptions "github.com/erickmo/vernon-cms/internal/query/list_data_record_options"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type DataHandler struct {
	cmdBus   *commandbus.CommandBus
	queryBus *querybus.QueryBus
	validate *validator.Validate
}

func NewDataHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *DataHandler {
	return &DataHandler{cmdBus: cmdBus, queryBus: queryBus, validate: validator.New()}
}

func (h *DataHandler) RegisterRoutes(r chi.Router) {
	// These are registered in main.go with proper RBAC groups
}

// --- Data Type Handlers ---

func (h *DataHandler) ListDataTypes(w http.ResponseWriter, r *http.Request) {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), listdata.Query{SiteID: siteID, Page: page, Limit: limit})
	if err != nil {
		writeAppError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, result)
}

func (h *DataHandler) GetDataType(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid data id")
		return
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), getdata.Query{ID: id, SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, result)
}

func (h *DataHandler) CreateDataType(w http.ResponseWriter, r *http.Request) {
	var cmd createdata.Command
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

func (h *DataHandler) UpdateDataType(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid data id")
		return
	}

	var cmd updatedata.Command
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

func (h *DataHandler) DeleteDataType(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid data id")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), deletedata.Command{ID: id}); err != nil {
		writeAppError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "deleted"})
}

// --- Data Record Handlers ---

func (h *DataHandler) ListRecords(w http.ResponseWriter, r *http.Request) {
	dataSlug := chi.URLParam(r, "data_slug")
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	search := r.URL.Query().Get("search")
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), listdatarecord.Query{
		SiteID: siteID, DataSlug: dataSlug, Search: search, Page: page, Limit: limit,
	})
	if err != nil {
		writeAppError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, result)
}

func (h *DataHandler) GetRecord(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid record id")
		return
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), getdatarecord.Query{ID: id, SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, result)
}

func (h *DataHandler) CreateRecord(w http.ResponseWriter, r *http.Request) {
	dataSlug := chi.URLParam(r, "data_slug")

	var body struct {
		Data json.RawMessage `json:"data" validate:"required"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	cmd := createdatarecord.Command{DataSlug: dataSlug, Data: body.Data}
	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeAppError(w, err)
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"status": "created"})
}

func (h *DataHandler) UpdateRecord(w http.ResponseWriter, r *http.Request) {
	dataSlug := chi.URLParam(r, "data_slug")
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid record id")
		return
	}

	var body struct {
		Data json.RawMessage `json:"data" validate:"required"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	cmd := updatedatarecord.Command{ID: id, DataSlug: dataSlug, Data: body.Data}
	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeAppError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "updated"})
}

func (h *DataHandler) DeleteRecord(w http.ResponseWriter, r *http.Request) {
	dataSlug := chi.URLParam(r, "data_slug")
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid record id")
		return
	}

	cmd := deletedatarecord.Command{ID: id, DataSlug: dataSlug}
	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeAppError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "deleted"})
}

func (h *DataHandler) ListRecordOptions(w http.ResponseWriter, r *http.Request) {
	dataSlug := chi.URLParam(r, "data_slug")
	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), listdatarecordoptions.Query{DataSlug: dataSlug, SiteID: siteID})
	if err != nil {
		writeAppError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, result)
}

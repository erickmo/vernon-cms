package http

import (
	"encoding/json"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	deletemedia "github.com/erickmo/vernon-cms/internal/command/delete_media"
	updatemedia "github.com/erickmo/vernon-cms/internal/command/update_media"
	uploadmedia "github.com/erickmo/vernon-cms/internal/command/upload_media"
	getmedia "github.com/erickmo/vernon-cms/internal/query/get_media"
	listmedia "github.com/erickmo/vernon-cms/internal/query/list_media"
	listmediafolders "github.com/erickmo/vernon-cms/internal/query/list_media_folders"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type MediaHandler struct {
	cmdBus        *commandbus.CommandBus
	queryBus      *querybus.QueryBus
	validate      *validator.Validate
	uploadDir     string
	uploadBaseURL string
}

func NewMediaHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus, uploadDir, uploadBaseURL string) *MediaHandler {
	return &MediaHandler{
		cmdBus:        cmdBus,
		queryBus:      queryBus,
		validate:      validator.New(),
		uploadDir:     uploadDir,
		uploadBaseURL: uploadBaseURL,
	}
}

func (h *MediaHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/media", func(r chi.Router) {
		r.Get("/", h.List)
		// Static routes must be before parameterized routes
		r.Get("/folders", h.ListFolders)
		r.Post("/upload", h.Upload)
		r.Get("/{id}", h.GetByID)
		r.Put("/{id}", h.Update)
		r.Delete("/{id}", h.Delete)
	})
}

func (h *MediaHandler) List(w http.ResponseWriter, r *http.Request) {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	perPage, _ := strconv.Atoi(r.URL.Query().Get("per_page"))
	if page <= 0 {
		page = 1
	}
	if perPage <= 0 {
		perPage = 20
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), listmedia.Query{
		SiteID:   siteID,
		Search:   r.URL.Query().Get("search"),
		MimeType: r.URL.Query().Get("mime_type"),
		Folder:   r.URL.Query().Get("folder"),
		Page:     page,
		PerPage:  perPage,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

func (h *MediaHandler) ListFolders(w http.ResponseWriter, r *http.Request) {
	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), listmediafolders.Query{SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

func (h *MediaHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid media id")
		return
	}

	siteID := middleware.GetSiteID(r.Context())

	result, err := h.queryBus.Dispatch(r.Context(), getmedia.Query{ID: id, SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

// Upload handles both multipart/form-data (direct file) and application/json (URL-based).
func (h *MediaHandler) Upload(w http.ResponseWriter, r *http.Request) {
	contentType := r.Header.Get("Content-Type")
	if strings.Contains(contentType, "multipart/form-data") {
		h.uploadMultipart(w, r)
		return
	}
	h.uploadJSON(w, r)
}

func (h *MediaHandler) uploadJSON(w http.ResponseWriter, r *http.Request) {
	var cmd uploadmedia.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.validate.Struct(cmd); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	result := &uploadmedia.Result{}
	ctx := uploadmedia.WithResult(r.Context(), result)

	if err := h.cmdBus.Dispatch(ctx, cmd); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	if result.File == nil {
		writeError(w, http.StatusInternalServerError, "failed to upload media")
		return
	}

	writeFlatJSON(w, http.StatusCreated, result.File)
}

func (h *MediaHandler) uploadMultipart(w http.ResponseWriter, r *http.Request) {
	// Parse multipart form (max 50MB in memory; rest on disk)
	if err := r.ParseMultipartForm(50 << 20); err != nil {
		writeError(w, http.StatusBadRequest, "failed to parse multipart form")
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		writeError(w, http.StatusBadRequest, "file field is required")
		return
	}
	defer file.Close()

	// Create unique subdirectory to avoid filename collisions
	dirID := uuid.New().String()
	uploadDir := filepath.Join(h.uploadDir, dirID)
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create upload directory")
		return
	}

	// Sanitize filename
	fileName := filepath.Base(header.Filename)
	dstPath := filepath.Join(uploadDir, fileName)

	dst, err := os.Create(dstPath)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to save file")
		return
	}
	defer dst.Close()

	fileSize, err := io.Copy(dst, file)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to write file")
		return
	}

	// Detect MIME type
	mimeType := header.Header.Get("Content-Type")
	if mimeType == "" {
		mimeType = "application/octet-stream"
	}

	// Build public URL
	fileURL := h.uploadBaseURL + "/uploads/" + dirID + "/" + fileName

	// Optional fields from form values
	cmd := uploadmedia.Command{
		FileName: fileName,
		FileURL:  fileURL,
		MimeType: mimeType,
		FileSize: fileSize,
	}
	if v := r.FormValue("alt"); v != "" {
		cmd.Alt = &v
	}
	if v := r.FormValue("caption"); v != "" {
		cmd.Caption = &v
	}
	if v := r.FormValue("folder"); v != "" {
		cmd.Folder = &v
	}

	result := &uploadmedia.Result{}
	ctx := uploadmedia.WithResult(r.Context(), result)

	if err := h.cmdBus.Dispatch(ctx, cmd); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	if result.File == nil {
		writeError(w, http.StatusInternalServerError, "failed to upload media")
		return
	}

	writeFlatJSON(w, http.StatusCreated, result.File)
}

func (h *MediaHandler) Update(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid media id")
		return
	}

	var cmd updatemedia.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	cmd.ID = id

	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	// Return updated media
	siteID := middleware.GetSiteID(r.Context())
	result, err := h.queryBus.Dispatch(r.Context(), getmedia.Query{ID: id, SiteID: siteID})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeFlatJSON(w, http.StatusOK, result)
}

func (h *MediaHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid media id")
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), deletemedia.Command{ID: id}); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

package uploadmedia

import (
	"context"

	"github.com/erickmo/vernon-cms/internal/domain/media"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	FileName     string  `json:"file_name" validate:"required"`
	FileURL      string  `json:"file_url" validate:"required"`
	ThumbnailURL *string `json:"thumbnail_url"`
	MimeType     string  `json:"mime_type" validate:"required"`
	FileSize     int64   `json:"file_size"`
	Width        *int    `json:"width"`
	Height       *int    `json:"height"`
	Alt          *string `json:"alt"`
	Caption      *string `json:"caption"`
	Folder       *string `json:"folder"`
}

func (c Command) CommandName() string { return "UploadMedia" }

// Result carries the created media file back to the HTTP handler.
type Result struct {
	File *media.MediaFile
}

type resultKey struct{}

// WithResult injects a result container into ctx so the HTTP layer can retrieve the created file.
func WithResult(ctx context.Context, r *Result) context.Context {
	return context.WithValue(ctx, resultKey{}, r)
}

func getResult(ctx context.Context) *Result {
	r, _ := ctx.Value(resultKey{}).(*Result)
	return r
}

type Handler struct {
	repo media.WriteRepository
}

func NewHandler(repo media.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	siteID := middleware.GetSiteID(ctx)

	m, err := media.NewMediaFile(siteID, c.FileName, c.FileURL, c.MimeType, c.FileSize)
	if err != nil {
		return err
	}
	m.ThumbnailURL = c.ThumbnailURL
	m.Width = c.Width
	m.Height = c.Height
	m.Alt = c.Alt
	m.Caption = c.Caption
	m.Folder = c.Folder

	claims := middleware.GetClaims(ctx)
	if claims != nil {
		uid := claims.UserID
		m.UploadedBy = &uid
	}

	if err := h.repo.Save(m); err != nil {
		return err
	}

	if res := getResult(ctx); res != nil {
		res.File = m
	}
	return nil
}

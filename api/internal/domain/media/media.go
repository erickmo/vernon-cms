package media

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

type MediaFile struct {
	ID             uuid.UUID  `db:"id"`
	SiteID         uuid.UUID  `db:"site_id"`
	FileName       string     `db:"file_name"`
	FileURL        string     `db:"file_url"`
	ThumbnailURL   *string    `db:"thumbnail_url"`
	MimeType       string     `db:"mime_type"`
	FileSize       int64      `db:"file_size"`
	Width          *int       `db:"width"`
	Height         *int       `db:"height"`
	Alt            *string    `db:"alt"`
	Caption        *string    `db:"caption"`
	Folder         *string    `db:"folder"`
	UploadedBy     *uuid.UUID `db:"uploaded_by"`
	CreatedAt      time.Time  `db:"created_at"`
	UpdatedAt      time.Time  `db:"updated_at"`
}

func NewMediaFile(siteID uuid.UUID, fileName, fileURL, mimeType string, fileSize int64) (*MediaFile, error) {
	if fileName == "" {
		return nil, errors.New("file name is required")
	}
	if fileURL == "" {
		return nil, errors.New("file URL is required")
	}
	return &MediaFile{
		ID:        uuid.New(),
		SiteID:    siteID,
		FileName:  fileName,
		FileURL:   fileURL,
		MimeType:  mimeType,
		FileSize:  fileSize,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}, nil
}

type WriteRepository interface {
	Save(m *MediaFile) error
	Update(m *MediaFile) error
	Delete(id, siteID uuid.UUID) error
	FindByID(id, siteID uuid.UUID) (*MediaFile, error)
}

type ReadRepository interface {
	FindByID(id, siteID uuid.UUID) (*MediaFile, error)
	FindAll(siteID uuid.UUID, search, mimeType, folder string, offset, limit int) ([]*MediaFile, int, error)
	FindFolders(siteID uuid.UUID) ([]string, error)
}

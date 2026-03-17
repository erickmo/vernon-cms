package database

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/media"
)

type MediaRepository struct {
	db *sqlx.DB
}

func NewMediaRepository(db *sqlx.DB) *MediaRepository {
	return &MediaRepository{db: db}
}

func (r *MediaRepository) Save(m *media.MediaFile) error {
	_, err := r.db.NamedExec(`
		INSERT INTO media_files (
			id, site_id, file_name, file_url, thumbnail_url,
			mime_type, file_size, width, height,
			alt, caption, folder, uploaded_by, created_at, updated_at
		) VALUES (
			:id, :site_id, :file_name, :file_url, :thumbnail_url,
			:mime_type, :file_size, :width, :height,
			:alt, :caption, :folder, :uploaded_by, :created_at, :updated_at
		)
	`, m)
	return err
}

func (r *MediaRepository) Update(m *media.MediaFile) error {
	m.UpdatedAt = time.Now()
	result, err := r.db.Exec(`
		UPDATE media_files
		SET alt = $1, caption = $2, folder = $3, updated_at = $4
		WHERE id = $5 AND site_id = $6
	`, m.Alt, m.Caption, m.Folder, m.UpdatedAt, m.ID, m.SiteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("media file not found: %s", m.ID)
	}
	return nil
}

func (r *MediaRepository) Delete(id, siteID uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM media_files WHERE id = $1 AND site_id = $2`, id, siteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("media file not found: %s", id)
	}
	return nil
}

func (r *MediaRepository) FindByID(id, siteID uuid.UUID) (*media.MediaFile, error) {
	var m media.MediaFile
	err := r.db.Get(&m, `SELECT * FROM media_files WHERE id = $1 AND site_id = $2`, id, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("media file not found: %s", id)
	}
	return &m, err
}

func (r *MediaRepository) FindAll(siteID uuid.UUID, search, mimeType, folder string, offset, limit int) ([]*media.MediaFile, int, error) {
	args := []interface{}{siteID}
	where := []string{"site_id = $1"}
	i := 2

	if search != "" {
		where = append(where, fmt.Sprintf("file_name ILIKE $%d", i))
		args = append(args, "%"+search+"%")
		i++
	}
	if mimeType != "" {
		where = append(where, fmt.Sprintf("mime_type ILIKE $%d", i))
		args = append(args, mimeType+"%")
		i++
	}
	if folder != "" {
		where = append(where, fmt.Sprintf("folder = $%d", i))
		args = append(args, folder)
		i++
	}

	whereClause := "WHERE " + strings.Join(where, " AND ")

	var total int
	if err := r.db.Get(&total, `SELECT COUNT(*) FROM media_files `+whereClause, args...); err != nil {
		return nil, 0, err
	}

	args = append(args, limit, offset)
	query := fmt.Sprintf(`SELECT * FROM media_files %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`, whereClause, i, i+1)

	var files []*media.MediaFile
	if err := r.db.Select(&files, query, args...); err != nil {
		return nil, 0, err
	}

	return files, total, nil
}

func (r *MediaRepository) FindFolders(siteID uuid.UUID) ([]string, error) {
	var folders []string
	err := r.db.Select(&folders, `
		SELECT DISTINCT folder FROM media_files
		WHERE site_id = $1 AND folder IS NOT NULL AND folder != ''
		ORDER BY folder ASC
	`, siteID)
	if err != nil {
		return []string{}, nil
	}
	return folders, nil
}

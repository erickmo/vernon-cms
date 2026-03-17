package database

import (
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/content"
)

type ContentRepository struct {
	db *sqlx.DB
}

func NewContentRepository(db *sqlx.DB) *ContentRepository {
	return &ContentRepository{db: db}
}

// --- WriteRepository ---

func (r *ContentRepository) Save(c *content.Content) error {
	query := `INSERT INTO contents (id, site_id, title, slug, body, excerpt, status, page_id, category_id, author_id, metadata, published_at, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`
	_, err := r.db.Exec(query, c.ID, c.SiteID, c.Title, c.Slug, c.Body, c.Excerpt, c.Status,
		c.PageID, c.CategoryID, c.AuthorID, c.Metadata, c.PublishedAt, c.CreatedAt, c.UpdatedAt)
	return err
}

func (r *ContentRepository) Update(c *content.Content) error {
	query := `UPDATE contents SET title = $1, slug = $2, body = $3, excerpt = $4, status = $5,
		metadata = $6, published_at = $7, updated_at = $8 WHERE id = $9`
	result, err := r.db.Exec(query, c.Title, c.Slug, c.Body, c.Excerpt, c.Status,
		c.Metadata, c.PublishedAt, c.UpdatedAt, c.ID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("content not found: %s", c.ID)
	}
	return nil
}

func (r *ContentRepository) Delete(id, siteID uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM contents WHERE id = $1 AND site_id = $2`, id, siteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("content not found: %s", id)
	}
	return nil
}

func (r *ContentRepository) FindByID(id, siteID uuid.UUID) (*content.Content, error) {
	return r.FindByIDScoped(id, siteID)
}

// --- ReadRepository helpers (site-scoped) ---

func (r *ContentRepository) FindByIDScoped(id, siteID uuid.UUID) (*content.Content, error) {
	var c content.Content
	err := r.db.Get(&c, `SELECT * FROM contents WHERE id = $1 AND site_id = $2`, id, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("content not found: %s", id)
	}
	return &c, err
}

func (r *ContentRepository) FindBySlug(slug string, siteID uuid.UUID) (*content.Content, error) {
	var c content.Content
	err := r.db.Get(&c, `SELECT * FROM contents WHERE slug = $1 AND site_id = $2`, slug, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("content not found with slug: %s", slug)
	}
	return &c, err
}

func (r *ContentRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*content.Content, int, error) {
	var total int
	err := r.db.Get(&total, `SELECT COUNT(*) FROM contents WHERE site_id = $1`, siteID)
	if err != nil {
		return nil, 0, err
	}

	var contents []*content.Content
	err = r.db.Select(&contents, `SELECT * FROM contents WHERE site_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`, siteID, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	return contents, total, nil
}

func (r *ContentRepository) FindByPageID(pageID, siteID uuid.UUID, offset, limit int) ([]*content.Content, int, error) {
	var total int
	err := r.db.Get(&total, `SELECT COUNT(*) FROM contents WHERE page_id = $1 AND site_id = $2`, pageID, siteID)
	if err != nil {
		return nil, 0, err
	}

	var contents []*content.Content
	err = r.db.Select(&contents, `SELECT * FROM contents WHERE page_id = $1 AND site_id = $2 ORDER BY created_at DESC LIMIT $3 OFFSET $4`, pageID, siteID, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	return contents, total, nil
}

func (r *ContentRepository) FindByCategoryID(categoryID, siteID uuid.UUID, offset, limit int) ([]*content.Content, int, error) {
	var total int
	err := r.db.Get(&total, `SELECT COUNT(*) FROM contents WHERE category_id = $1 AND site_id = $2`, categoryID, siteID)
	if err != nil {
		return nil, 0, err
	}

	var contents []*content.Content
	err = r.db.Select(&contents, `SELECT * FROM contents WHERE category_id = $1 AND site_id = $2 ORDER BY created_at DESC LIMIT $3 OFFSET $4`, categoryID, siteID, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	return contents, total, nil
}

// ContentReadRepository wraps ContentRepository and implements content.ReadRepository.
type ContentReadRepository struct {
	repo *ContentRepository
}

func NewContentReadRepository(repo *ContentRepository) *ContentReadRepository {
	return &ContentReadRepository{repo: repo}
}

func (r *ContentReadRepository) FindByID(id, siteID uuid.UUID) (*content.Content, error) {
	return r.repo.FindByIDScoped(id, siteID)
}

func (r *ContentReadRepository) FindBySlug(slug string, siteID uuid.UUID) (*content.Content, error) {
	return r.repo.FindBySlug(slug, siteID)
}

func (r *ContentReadRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*content.Content, int, error) {
	return r.repo.FindAll(siteID, offset, limit)
}

func (r *ContentReadRepository) FindByPageID(pageID, siteID uuid.UUID, offset, limit int) ([]*content.Content, int, error) {
	return r.repo.FindByPageID(pageID, siteID, offset, limit)
}

func (r *ContentReadRepository) FindByCategoryID(categoryID, siteID uuid.UUID, offset, limit int) ([]*content.Content, int, error) {
	return r.repo.FindByCategoryID(categoryID, siteID, offset, limit)
}

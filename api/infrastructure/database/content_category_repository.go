package database

import (
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	contentcategory "github.com/erickmo/vernon-cms/internal/domain/content_category"
)

type ContentCategoryRepository struct {
	db *sqlx.DB
}

func NewContentCategoryRepository(db *sqlx.DB) *ContentCategoryRepository {
	return &ContentCategoryRepository{db: db}
}

// --- WriteRepository ---

func (r *ContentCategoryRepository) Save(c *contentcategory.ContentCategory) error {
	query := `INSERT INTO content_categories (id, site_id, name, slug, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)`
	_, err := r.db.Exec(query, c.ID, c.SiteID, c.Name, c.Slug, c.CreatedAt, c.UpdatedAt)
	return err
}

func (r *ContentCategoryRepository) Update(c *contentcategory.ContentCategory) error {
	query := `UPDATE content_categories SET name = $1, slug = $2, updated_at = $3 WHERE id = $4`
	result, err := r.db.Exec(query, c.Name, c.Slug, c.UpdatedAt, c.ID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("content category not found: %s", c.ID)
	}
	return nil
}

func (r *ContentCategoryRepository) Delete(id, siteID uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM content_categories WHERE id = $1 AND site_id = $2`, id, siteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("content category not found: %s", id)
	}
	return nil
}

func (r *ContentCategoryRepository) FindByID(id, siteID uuid.UUID) (*contentcategory.ContentCategory, error) {
	return r.FindByIDScoped(id, siteID)
}

// --- ReadRepository helpers (site-scoped) ---

func (r *ContentCategoryRepository) FindByIDScoped(id, siteID uuid.UUID) (*contentcategory.ContentCategory, error) {
	var c contentcategory.ContentCategory
	err := r.db.Get(&c, `SELECT * FROM content_categories WHERE id = $1 AND site_id = $2`, id, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("content category not found: %s", id)
	}
	return &c, err
}

func (r *ContentCategoryRepository) FindBySlug(slug string, siteID uuid.UUID) (*contentcategory.ContentCategory, error) {
	var c contentcategory.ContentCategory
	err := r.db.Get(&c, `SELECT * FROM content_categories WHERE slug = $1 AND site_id = $2`, slug, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("content category not found with slug: %s", slug)
	}
	return &c, err
}

func (r *ContentCategoryRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*contentcategory.ContentCategory, int, error) {
	var total int
	err := r.db.Get(&total, `SELECT COUNT(*) FROM content_categories WHERE site_id = $1`, siteID)
	if err != nil {
		return nil, 0, err
	}

	var categories []*contentcategory.ContentCategory
	err = r.db.Select(&categories, `SELECT * FROM content_categories WHERE site_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`, siteID, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	return categories, total, nil
}

// ContentCategoryReadRepository wraps ContentCategoryRepository and implements contentcategory.ReadRepository.
type ContentCategoryReadRepository struct {
	repo *ContentCategoryRepository
}

func NewContentCategoryReadRepository(repo *ContentCategoryRepository) *ContentCategoryReadRepository {
	return &ContentCategoryReadRepository{repo: repo}
}

func (r *ContentCategoryReadRepository) FindByID(id, siteID uuid.UUID) (*contentcategory.ContentCategory, error) {
	return r.repo.FindByIDScoped(id, siteID)
}

func (r *ContentCategoryReadRepository) FindBySlug(slug string, siteID uuid.UUID) (*contentcategory.ContentCategory, error) {
	return r.repo.FindBySlug(slug, siteID)
}

func (r *ContentCategoryReadRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*contentcategory.ContentCategory, int, error) {
	return r.repo.FindAll(siteID, offset, limit)
}

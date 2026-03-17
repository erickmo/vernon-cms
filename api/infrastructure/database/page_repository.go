package database

import (
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/page"
)

// PageRepository implements both page.WriteRepository and page.ReadRepository.
// WriteRepository.FindByID is unscoped (for internal fetch-then-update flows).
// ReadRepository methods are site-scoped.
type PageRepository struct {
	db *sqlx.DB
}

func NewPageRepository(db *sqlx.DB) *PageRepository {
	return &PageRepository{db: db}
}

// --- WriteRepository ---

func (r *PageRepository) Save(p *page.Page) error {
	query := `INSERT INTO pages (id, site_id, name, slug, variables, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err := r.db.Exec(query, p.ID, p.SiteID, p.Name, p.Slug, p.Variables, p.IsActive, p.CreatedAt, p.UpdatedAt)
	return err
}

func (r *PageRepository) Update(p *page.Page) error {
	query := `UPDATE pages SET name = $1, slug = $2, variables = $3, is_active = $4, updated_at = $5 WHERE id = $6`
	result, err := r.db.Exec(query, p.Name, p.Slug, p.Variables, p.IsActive, p.UpdatedAt, p.ID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("page not found: %s", p.ID)
	}
	return nil
}

func (r *PageRepository) Delete(id, siteID uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM pages WHERE id = $1 AND site_id = $2`, id, siteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("page not found: %s", id)
	}
	return nil
}

// FindByID is site-scoped — used by WriteRepository for fetch-before-update.
func (r *PageRepository) FindByID(id, siteID uuid.UUID) (*page.Page, error) {
	return r.FindByIDScoped(id, siteID)
}

// --- ReadRepository (site-scoped) ---

// FindByIDScoped implements page.ReadRepository.FindByID (scoped to siteID).
func (r *PageRepository) FindByIDScoped(id, siteID uuid.UUID) (*page.Page, error) {
	var p page.Page
	err := r.db.Get(&p, `SELECT * FROM pages WHERE id = $1 AND site_id = $2`, id, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("page not found: %s", id)
	}
	return &p, err
}

func (r *PageRepository) FindBySlug(slug string, siteID uuid.UUID) (*page.Page, error) {
	var p page.Page
	err := r.db.Get(&p, `SELECT * FROM pages WHERE slug = $1 AND site_id = $2`, slug, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("page not found with slug: %s", slug)
	}
	return &p, err
}

func (r *PageRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*page.Page, int, error) {
	var total int
	err := r.db.Get(&total, `SELECT COUNT(*) FROM pages WHERE site_id = $1`, siteID)
	if err != nil {
		return nil, 0, err
	}

	var pages []*page.Page
	err = r.db.Select(&pages, `SELECT * FROM pages WHERE site_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`, siteID, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	return pages, total, nil
}

// PageReadRepository wraps PageRepository and implements page.ReadRepository.
type PageReadRepository struct {
	repo *PageRepository
}

func NewPageReadRepository(repo *PageRepository) *PageReadRepository {
	return &PageReadRepository{repo: repo}
}

func (r *PageReadRepository) FindByID(id, siteID uuid.UUID) (*page.Page, error) {
	return r.repo.FindByIDScoped(id, siteID)
}

func (r *PageReadRepository) FindBySlug(slug string, siteID uuid.UUID) (*page.Page, error) {
	return r.repo.FindBySlug(slug, siteID)
}

func (r *PageReadRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*page.Page, int, error) {
	return r.repo.FindAll(siteID, offset, limit)
}

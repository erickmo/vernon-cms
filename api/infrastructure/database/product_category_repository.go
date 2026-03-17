package database

import (
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	productcategory "github.com/erickmo/vernon-cms/internal/domain/product_category"
)

type ProductCategoryRepository struct {
	db *sqlx.DB
}

func NewProductCategoryRepository(db *sqlx.DB) *ProductCategoryRepository {
	return &ProductCategoryRepository{db: db}
}

// --- WriteRepository ---

func (r *ProductCategoryRepository) Save(c *productcategory.ProductCategory) error {
	query := `INSERT INTO product_categories (id, site_id, parent_id, name, slug, description, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err := r.db.Exec(query, c.ID, c.SiteID, c.ParentID, c.Name, c.Slug, c.Description, c.CreatedAt, c.UpdatedAt)
	return err
}

func (r *ProductCategoryRepository) Update(c *productcategory.ProductCategory) error {
	query := `UPDATE product_categories SET parent_id = $1, name = $2, slug = $3, description = $4, updated_at = $5 WHERE id = $6`
	result, err := r.db.Exec(query, c.ParentID, c.Name, c.Slug, c.Description, c.UpdatedAt, c.ID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("product category not found: %s", c.ID)
	}
	return nil
}

func (r *ProductCategoryRepository) Delete(id, siteID uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM product_categories WHERE id = $1 AND site_id = $2`, id, siteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("product category not found: %s", id)
	}
	return nil
}

func (r *ProductCategoryRepository) FindByID(id, siteID uuid.UUID) (*productcategory.ProductCategory, error) {
	var c productcategory.ProductCategory
	err := r.db.Get(&c, `SELECT * FROM product_categories WHERE id = $1 AND site_id = $2`, id, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("product category not found: %s", id)
	}
	return &c, err
}

// --- ReadRepository ---

func (r *ProductCategoryRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*productcategory.ProductCategory, int, error) {
	var total int
	err := r.db.Get(&total, `SELECT COUNT(*) FROM product_categories WHERE site_id = $1`, siteID)
	if err != nil {
		return nil, 0, err
	}

	var categories []*productcategory.ProductCategory
	err = r.db.Select(&categories,
		`SELECT * FROM product_categories WHERE site_id = $1 ORDER BY name ASC LIMIT $2 OFFSET $3`,
		siteID, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	return categories, total, nil
}

// ProductCategoryReadRepository wraps ProductCategoryRepository and implements productcategory.ReadRepository.
type ProductCategoryReadRepository struct {
	repo *ProductCategoryRepository
}

func NewProductCategoryReadRepository(repo *ProductCategoryRepository) *ProductCategoryReadRepository {
	return &ProductCategoryReadRepository{repo: repo}
}

func (r *ProductCategoryReadRepository) FindByID(id, siteID uuid.UUID) (*productcategory.ProductCategory, error) {
	return r.repo.FindByID(id, siteID)
}

func (r *ProductCategoryReadRepository) FindAll(siteID uuid.UUID, offset, limit int) ([]*productcategory.ProductCategory, int, error) {
	return r.repo.FindAll(siteID, offset, limit)
}

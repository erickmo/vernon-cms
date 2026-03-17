package database

import (
	"database/sql"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/product"
)

type ProductRepository struct {
	db *sqlx.DB
}

func NewProductRepository(db *sqlx.DB) *ProductRepository {
	return &ProductRepository{db: db}
}

// --- WriteRepository ---

func (r *ProductRepository) Save(p *product.Product) error {
	query := `INSERT INTO products
		(id, site_id, category_id, name, slug, description, price, stock, images, metadata, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`
	_, err := r.db.Exec(query,
		p.ID, p.SiteID, p.CategoryID, p.Name, p.Slug, p.Description,
		p.Price, p.Stock, p.Images, p.Metadata, p.IsActive, p.CreatedAt, p.UpdatedAt)
	return err
}

func (r *ProductRepository) Update(p *product.Product) error {
	query := `UPDATE products SET
		category_id = $1, name = $2, slug = $3, description = $4, price = $5,
		stock = $6, images = $7, metadata = $8, is_active = $9, updated_at = $10
		WHERE id = $11`
	result, err := r.db.Exec(query,
		p.CategoryID, p.Name, p.Slug, p.Description, p.Price,
		p.Stock, p.Images, p.Metadata, p.IsActive, p.UpdatedAt, p.ID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("product not found: %s", p.ID)
	}
	return nil
}

func (r *ProductRepository) Delete(id, siteID uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM products WHERE id = $1 AND site_id = $2`, id, siteID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("product not found: %s", id)
	}
	return nil
}

func (r *ProductRepository) FindByID(id, siteID uuid.UUID) (*product.Product, error) {
	var p product.Product
	err := r.db.Get(&p, `SELECT * FROM products WHERE id = $1 AND site_id = $2`, id, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("product not found: %s", id)
	}
	return &p, err
}

// --- ReadRepository ---

func (r *ProductRepository) FindBySlug(slug string, siteID uuid.UUID) (*product.Product, error) {
	var p product.Product
	err := r.db.Get(&p, `SELECT * FROM products WHERE slug = $1 AND site_id = $2`, slug, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("product not found with slug: %s", slug)
	}
	return &p, err
}

func (r *ProductRepository) FindAll(siteID uuid.UUID, search string, categoryID *uuid.UUID, offset, limit int) ([]*product.Product, int, error) {
	conditions := []string{"site_id = $1"}
	args := []interface{}{siteID}
	idx := 2

	if search != "" {
		conditions = append(conditions, fmt.Sprintf("LOWER(name) LIKE $%d", idx))
		args = append(args, "%"+strings.ToLower(search)+"%")
		idx++
	}
	if categoryID != nil {
		conditions = append(conditions, fmt.Sprintf("category_id = $%d", idx))
		args = append(args, *categoryID)
		idx++
	}

	where := "WHERE " + strings.Join(conditions, " AND ")

	var total int
	countArgs := make([]interface{}, len(args))
	copy(countArgs, args)
	if err := r.db.Get(&total, fmt.Sprintf("SELECT COUNT(*) FROM products %s", where), countArgs...); err != nil {
		return nil, 0, err
	}

	args = append(args, limit, offset)
	rows, err := r.db.Queryx(
		fmt.Sprintf("SELECT * FROM products %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d", where, idx, idx+1),
		args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var products []*product.Product
	for rows.Next() {
		var p product.Product
		if err := rows.StructScan(&p); err != nil {
			return nil, 0, err
		}
		products = append(products, &p)
	}

	return products, total, nil
}

// ProductReadRepository wraps ProductRepository and implements product.ReadRepository.
type ProductReadRepository struct {
	repo *ProductRepository
}

func NewProductReadRepository(repo *ProductRepository) *ProductReadRepository {
	return &ProductReadRepository{repo: repo}
}

func (r *ProductReadRepository) FindByID(id, siteID uuid.UUID) (*product.Product, error) {
	return r.repo.FindByID(id, siteID)
}

func (r *ProductReadRepository) FindBySlug(slug string, siteID uuid.UUID) (*product.Product, error) {
	return r.repo.FindBySlug(slug, siteID)
}

func (r *ProductReadRepository) FindAll(siteID uuid.UUID, search string, categoryID *uuid.UUID, offset, limit int) ([]*product.Product, int, error) {
	return r.repo.FindAll(siteID, search, categoryID, offset, limit)
}

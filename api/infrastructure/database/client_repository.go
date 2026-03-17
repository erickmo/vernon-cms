package database

import (
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/client"
)

type ClientRepository struct {
	db *sqlx.DB
}

func NewClientRepository(db *sqlx.DB) *ClientRepository {
	return &ClientRepository{db: db}
}

// WriteRepository implementation

func (r *ClientRepository) Save(c *client.Client) error {
	_, err := r.db.NamedExec(`
		INSERT INTO clients (id, name, email, phone, company, address, is_active, created_at, updated_at)
		VALUES (:id, :name, :email, :phone, :company, :address, :is_active, :created_at, :updated_at)
	`, c)
	return err
}

func (r *ClientRepository) Update(c *client.Client) error {
	_, err := r.db.NamedExec(`
		UPDATE clients
		SET name=:name, email=:email, phone=:phone, company=:company, address=:address,
		    is_active=:is_active, updated_at=:updated_at
		WHERE id=:id
	`, c)
	return err
}

func (r *ClientRepository) Delete(id uuid.UUID) error {
	_, err := r.db.Exec(`DELETE FROM clients WHERE id=$1`, id)
	return err
}

func (r *ClientRepository) FindByID(id uuid.UUID) (*client.Client, error) {
	var c client.Client
	err := r.db.Get(&c, `SELECT * FROM clients WHERE id=$1`, id)
	if err != nil {
		return nil, fmt.Errorf("client not found: %w", err)
	}
	return &c, nil
}

// ReadRepository implementation

func (r *ClientRepository) FindAll(search string, isActive *bool, offset, limit int) ([]*client.Client, int, error) {
	args := []interface{}{}
	conditions := []string{}
	idx := 1

	if search != "" {
		conditions = append(conditions, fmt.Sprintf(
			"(LOWER(name) LIKE $%d OR LOWER(email) LIKE $%d OR LOWER(COALESCE(company, '')) LIKE $%d)",
			idx, idx+1, idx+2,
		))
		like := "%" + strings.ToLower(search) + "%"
		args = append(args, like, like, like)
		idx += 3
	}

	if isActive != nil {
		conditions = append(conditions, fmt.Sprintf("is_active=$%d", idx))
		args = append(args, *isActive)
		idx++
	}

	where := ""
	if len(conditions) > 0 {
		where = "WHERE " + strings.Join(conditions, " AND ")
	}

	var total int
	countSQL := fmt.Sprintf("SELECT COUNT(*) FROM clients %s", where)
	if err := r.db.QueryRow(countSQL, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	querySQL := fmt.Sprintf("SELECT * FROM clients %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d", where, idx, idx+1)
	args = append(args, limit, offset)

	rows, err := r.db.Queryx(querySQL, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	clients := make([]*client.Client, 0)
	for rows.Next() {
		var c client.Client
		if err := rows.StructScan(&c); err != nil {
			return nil, 0, err
		}
		clients = append(clients, &c)
	}

	return clients, total, nil
}

package database

import (
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/payment"
)

type PaymentRepository struct {
	db *sqlx.DB
}

func NewPaymentRepository(db *sqlx.DB) *PaymentRepository {
	return &PaymentRepository{db: db}
}

// WriteRepository implementation

func (r *PaymentRepository) Save(p *payment.Payment) error {
	_, err := r.db.NamedExec(`
		INSERT INTO payments (id, client_id, amount, status, description, method, due_date, paid_at, created_at, updated_at)
		VALUES (:id, :client_id, :amount, :status, :description, :method, :due_date, :paid_at, :created_at, :updated_at)
	`, p)
	return err
}

// ReadRepository implementation — returns PaymentWithClient (includes client_name via JOIN)

func (r *PaymentRepository) FindByID(id uuid.UUID) (*payment.PaymentWithClient, error) {
	var p payment.PaymentWithClient
	err := r.db.Get(&p, `
		SELECT p.*, c.name AS client_name
		FROM payments p
		JOIN clients c ON c.id = p.client_id
		WHERE p.id = $1
	`, id)
	if err != nil {
		return nil, fmt.Errorf("payment not found: %w", err)
	}
	return &p, nil
}

func (r *PaymentRepository) FindAll(clientID *uuid.UUID, status *payment.Status, offset, limit int) ([]*payment.PaymentWithClient, int, error) {
	args := []interface{}{}
	conditions := []string{}
	idx := 1

	if clientID != nil {
		conditions = append(conditions, fmt.Sprintf("p.client_id=$%d", idx))
		args = append(args, *clientID)
		idx++
	}

	if status != nil {
		conditions = append(conditions, fmt.Sprintf("p.status=$%d", idx))
		args = append(args, string(*status))
		idx++
	}

	where := ""
	if len(conditions) > 0 {
		where = "WHERE " + strings.Join(conditions, " AND ")
	}

	var total int
	countSQL := fmt.Sprintf("SELECT COUNT(*) FROM payments p %s", where)
	if err := r.db.QueryRow(countSQL, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	querySQL := fmt.Sprintf(`
		SELECT p.*, c.name AS client_name
		FROM payments p
		JOIN clients c ON c.id = p.client_id
		%s
		ORDER BY p.created_at DESC
		LIMIT $%d OFFSET $%d
	`, where, idx, idx+1)
	args = append(args, limit, offset)

	rows, err := r.db.Queryx(querySQL, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	payments := make([]*payment.PaymentWithClient, 0)
	for rows.Next() {
		var p payment.PaymentWithClient
		if err := rows.StructScan(&p); err != nil {
			return nil, 0, err
		}
		payments = append(payments, &p)
	}

	return payments, total, nil
}

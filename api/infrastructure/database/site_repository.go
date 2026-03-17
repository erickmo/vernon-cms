package database

import (
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/site"
)

type SiteRepository struct {
	db *sqlx.DB
}

func NewSiteRepository(db *sqlx.DB) *SiteRepository {
	return &SiteRepository{db: db}
}

// --- WriteRepository ---

func (r *SiteRepository) Save(s *site.Site) error {
	query := `INSERT INTO sites (id, name, slug, custom_domain, owner_id, is_active, settings, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`
	_, err := r.db.Exec(query, s.ID, s.Name, s.Slug, s.CustomDomain, s.OwnerID, s.IsActive, s.Settings, s.CreatedAt, s.UpdatedAt)
	return err
}

func (r *SiteRepository) Update(s *site.Site) error {
	query := `UPDATE sites SET name=$1, custom_domain=$2, is_active=$3, settings=$4, updated_at=$5 WHERE id=$6`
	result, err := r.db.Exec(query, s.Name, s.CustomDomain, s.IsActive, s.Settings, s.UpdatedAt, s.ID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("site not found: %s", s.ID)
	}
	return nil
}

func (r *SiteRepository) Delete(id uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM sites WHERE id = $1`, id)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("site not found: %s", id)
	}
	return nil
}

func (r *SiteRepository) FindByID(id uuid.UUID) (*site.Site, error) {
	var s site.Site
	err := r.db.Get(&s, `SELECT * FROM sites WHERE id = $1`, id)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("site not found: %s", id)
	}
	return &s, err
}

func (r *SiteRepository) SaveMember(member *site.SiteMember) error {
	query := `INSERT INTO site_members (id, site_id, user_id, role, invited_by, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`
	_, err := r.db.Exec(query, member.ID, member.SiteID, member.UserID, member.Role, member.InvitedBy, member.CreatedAt, member.UpdatedAt)
	return err
}

func (r *SiteRepository) UpdateMemberRole(siteID, userID uuid.UUID, role site.SiteRole) error {
	query := `UPDATE site_members SET role=$1, updated_at=NOW() WHERE site_id=$2 AND user_id=$3`
	result, err := r.db.Exec(query, role, siteID, userID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("site member not found for site %s user %s", siteID, userID)
	}
	return nil
}

func (r *SiteRepository) RemoveMember(siteID, userID uuid.UUID) error {
	result, err := r.db.Exec(`DELETE FROM site_members WHERE site_id=$1 AND user_id=$2`, siteID, userID)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("site member not found for site %s user %s", siteID, userID)
	}
	return nil
}

func (r *SiteRepository) FindMemberByIDs(siteID, userID uuid.UUID) (*site.SiteMember, error) {
	var m site.SiteMember
	err := r.db.Get(&m, `SELECT * FROM site_members WHERE site_id=$1 AND user_id=$2`, siteID, userID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("site member not found")
	}
	return &m, err
}

// --- ReadRepository ---

func (r *SiteRepository) FindByCustomDomain(domain string) (*site.Site, error) {
	var s site.Site
	err := r.db.Get(&s, `SELECT * FROM sites WHERE custom_domain = $1`, domain)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("site not found for domain: %s", domain)
	}
	return &s, err
}

func (r *SiteRepository) FindBySlug(slug string) (*site.Site, error) {
	var s site.Site
	err := r.db.Get(&s, `SELECT * FROM sites WHERE slug = $1`, slug)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("site not found with slug: %s", slug)
	}
	return &s, err
}

func (r *SiteRepository) FindByUserID(userID uuid.UUID, offset, limit int) ([]*site.Site, int, error) {
	var total int
	err := r.db.Get(&total, `SELECT COUNT(*) FROM sites s INNER JOIN site_members sm ON s.id = sm.site_id WHERE sm.user_id = $1`, userID)
	if err != nil {
		return nil, 0, err
	}

	var sites []*site.Site
	err = r.db.Select(&sites, `SELECT s.* FROM sites s INNER JOIN site_members sm ON s.id = sm.site_id WHERE sm.user_id = $1 ORDER BY s.created_at DESC LIMIT $2 OFFSET $3`, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	return sites, total, nil
}

func (r *SiteRepository) FindMembersBySiteID(siteID uuid.UUID) ([]*site.SiteMember, error) {
	var members []*site.SiteMember
	err := r.db.Select(&members, `SELECT * FROM site_members WHERE site_id = $1 ORDER BY created_at`, siteID)
	if err != nil {
		return nil, err
	}
	if members == nil {
		members = make([]*site.SiteMember, 0)
	}
	return members, nil
}

func (r *SiteRepository) CountAdminsBySiteID(siteID uuid.UUID) (int, error) {
	var count int
	err := r.db.Get(&count, `SELECT COUNT(*) FROM site_members WHERE site_id = $1 AND role = 'admin'`, siteID)
	return count, err
}

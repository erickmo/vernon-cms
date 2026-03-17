package site

import (
	"encoding/json"
	"errors"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"
)

var slugRegex = regexp.MustCompile(`^[a-z0-9]+(?:-[a-z0-9]+)*$`)

type SiteRole string

const (
	SiteRoleAdmin  SiteRole = "admin"
	SiteRoleEditor SiteRole = "editor"
	SiteRoleViewer SiteRole = "viewer"
)

func (r SiteRole) IsValid() bool {
	return r == SiteRoleAdmin || r == SiteRoleEditor || r == SiteRoleViewer
}

type Site struct {
	ID           uuid.UUID       `json:"id" db:"id"`
	Name         string          `json:"name" db:"name"`
	Slug         string          `json:"slug" db:"slug"`
	CustomDomain string          `json:"custom_domain" db:"custom_domain"`
	OwnerID      uuid.UUID       `json:"owner_id" db:"owner_id"`
	IsActive     bool            `json:"is_active" db:"is_active"`
	Settings     json.RawMessage `json:"settings" db:"settings"`
	CreatedAt    time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time       `json:"updated_at" db:"updated_at"`
}

func NewSite(name, slug, customDomain string, ownerID uuid.UUID) (*Site, error) {
	if name == "" {
		return nil, errors.New("site name is required")
	}
	if slug == "" {
		return nil, errors.New("site slug is required")
	}
	slug = strings.ToLower(slug)
	if !slugRegex.MatchString(slug) {
		return nil, errors.New("site slug must be lowercase alphanumeric with dashes only")
	}
	if customDomain == "" {
		return nil, errors.New("site custom_domain is required")
	}
	if strings.Contains(customDomain, "://") {
		return nil, errors.New("site custom_domain must not contain protocol")
	}
	if strings.Contains(customDomain, "/") {
		return nil, errors.New("site custom_domain must not contain path")
	}

	now := time.Now()
	return &Site{
		ID:           uuid.New(),
		Name:         name,
		Slug:         slug,
		CustomDomain: customDomain,
		OwnerID:      ownerID,
		IsActive:     true,
		Settings:     json.RawMessage(`{}`),
		CreatedAt:    now,
		UpdatedAt:    now,
	}, nil
}

type SiteMember struct {
	ID        uuid.UUID  `json:"id" db:"id"`
	SiteID    uuid.UUID  `json:"site_id" db:"site_id"`
	UserID    uuid.UUID  `json:"user_id" db:"user_id"`
	Role      SiteRole   `json:"role" db:"role"`
	InvitedBy *uuid.UUID `json:"invited_by,omitempty" db:"invited_by"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt time.Time  `json:"updated_at" db:"updated_at"`
}

func NewSiteMember(siteID, userID uuid.UUID, role SiteRole, invitedBy *uuid.UUID) (*SiteMember, error) {
	if !role.IsValid() {
		return nil, errors.New("invalid site role: " + string(role))
	}
	now := time.Now()
	return &SiteMember{
		ID:        uuid.New(),
		SiteID:    siteID,
		UserID:    userID,
		Role:      role,
		InvitedBy: invitedBy,
		CreatedAt: now,
		UpdatedAt: now,
	}, nil
}

type WriteRepository interface {
	Save(site *Site) error
	Update(site *Site) error
	Delete(id uuid.UUID) error
	FindByID(id uuid.UUID) (*Site, error)
	SaveMember(member *SiteMember) error
	UpdateMemberRole(siteID, userID uuid.UUID, role SiteRole) error
	RemoveMember(siteID, userID uuid.UUID) error
	FindMemberByIDs(siteID, userID uuid.UUID) (*SiteMember, error)
}

type ReadRepository interface {
	FindByID(id uuid.UUID) (*Site, error)
	FindByCustomDomain(domain string) (*Site, error)
	FindBySlug(slug string) (*Site, error)
	FindByUserID(userID uuid.UUID, offset, limit int) ([]*Site, int, error)
	FindMemberByIDs(siteID, userID uuid.UUID) (*SiteMember, error)
	FindMembersBySiteID(siteID uuid.UUID) ([]*SiteMember, error)
	CountAdminsBySiteID(siteID uuid.UUID) (int, error)
}

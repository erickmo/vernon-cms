package site

import (
	"time"

	"github.com/google/uuid"
)

type SiteCreated struct {
	SiteID   uuid.UUID `json:"site_id"`
	Name     string    `json:"name"`
	Slug     string    `json:"slug"`
	Domain   string    `json:"domain"`
	OwnerID  uuid.UUID `json:"owner_id"`
	Time     time.Time `json:"time"`
}

func (e SiteCreated) EventName() string     { return "site.created" }
func (e SiteCreated) OccurredAt() time.Time { return e.Time }

type SiteUpdated struct {
	SiteID uuid.UUID `json:"site_id"`
	Name   string    `json:"name"`
	Domain string    `json:"domain"`
	Time   time.Time `json:"time"`
}

func (e SiteUpdated) EventName() string     { return "site.updated" }
func (e SiteUpdated) OccurredAt() time.Time { return e.Time }

type SiteDeleted struct {
	SiteID uuid.UUID `json:"site_id"`
	Time   time.Time `json:"time"`
}

func (e SiteDeleted) EventName() string     { return "site.deleted" }
func (e SiteDeleted) OccurredAt() time.Time { return e.Time }

type SiteMemberAdded struct {
	SiteID uuid.UUID `json:"site_id"`
	UserID uuid.UUID `json:"user_id"`
	Role   SiteRole  `json:"role"`
	Time   time.Time `json:"time"`
}

func (e SiteMemberAdded) EventName() string     { return "site.member_added" }
func (e SiteMemberAdded) OccurredAt() time.Time { return e.Time }

type SiteMemberRemoved struct {
	SiteID uuid.UUID `json:"site_id"`
	UserID uuid.UUID `json:"user_id"`
	Time   time.Time `json:"time"`
}

func (e SiteMemberRemoved) EventName() string     { return "site.member_removed" }
func (e SiteMemberRemoved) OccurredAt() time.Time { return e.Time }

type SiteMemberRoleUpdated struct {
	SiteID uuid.UUID `json:"site_id"`
	UserID uuid.UUID `json:"user_id"`
	Role   SiteRole  `json:"role"`
	Time   time.Time `json:"time"`
}

func (e SiteMemberRoleUpdated) EventName() string     { return "site.member_role_updated" }
func (e SiteMemberRoleUpdated) OccurredAt() time.Time { return e.Time }

package settings

import (
	"time"

	"github.com/google/uuid"
)

type Settings struct {
	ID                     uuid.UUID `db:"id"`
	SiteID                 uuid.UUID `db:"site_id"`
	SiteName               string    `db:"site_name"`
	SiteDescription        *string   `db:"site_description"`
	SiteURL                *string   `db:"site_url"`
	LogoURL                *string   `db:"logo_url"`
	FaviconURL             *string   `db:"favicon_url"`
	DefaultMetaTitle       *string   `db:"default_meta_title"`
	DefaultMetaDescription *string   `db:"default_meta_description"`
	DefaultOGImage         *string   `db:"default_og_image"`
	PrimaryColor           *string   `db:"primary_color"`
	SecondaryColor         *string   `db:"secondary_color"`
	FooterText             *string   `db:"footer_text"`
	GoogleAnalyticsID      *string   `db:"google_analytics_id"`
	CustomHeadCode         *string   `db:"custom_head_code"`
	CustomBodyCode         *string   `db:"custom_body_code"`
	MaintenanceMode        bool      `db:"maintenance_mode"`
	MaintenanceMessage     *string   `db:"maintenance_message"`
	UpdatedAt              time.Time `db:"updated_at"`
}

type WriteRepository interface {
	Upsert(s *Settings) error
}

type ReadRepository interface {
	FindBySiteID(siteID uuid.UUID) (*Settings, error)
}

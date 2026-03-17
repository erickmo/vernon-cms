package database

import (
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"github.com/erickmo/vernon-cms/internal/domain/settings"
)

type SettingsRepository struct {
	db *sqlx.DB
}

func NewSettingsRepository(db *sqlx.DB) *SettingsRepository {
	return &SettingsRepository{db: db}
}

func (r *SettingsRepository) Upsert(s *settings.Settings) error {
	if s.ID == uuid.Nil {
		s.ID = uuid.New()
	}
	_, err := r.db.NamedExec(`
		INSERT INTO site_settings (
			id, site_id, site_name, site_description, site_url, logo_url, favicon_url,
			default_meta_title, default_meta_description, default_og_image,
			primary_color, secondary_color, footer_text,
			google_analytics_id, custom_head_code, custom_body_code,
			maintenance_mode, maintenance_message, updated_at
		) VALUES (
			:id, :site_id, :site_name, :site_description, :site_url, :logo_url, :favicon_url,
			:default_meta_title, :default_meta_description, :default_og_image,
			:primary_color, :secondary_color, :footer_text,
			:google_analytics_id, :custom_head_code, :custom_body_code,
			:maintenance_mode, :maintenance_message, :updated_at
		)
		ON CONFLICT (site_id) DO UPDATE SET
			site_name = EXCLUDED.site_name,
			site_description = EXCLUDED.site_description,
			site_url = EXCLUDED.site_url,
			logo_url = EXCLUDED.logo_url,
			favicon_url = EXCLUDED.favicon_url,
			default_meta_title = EXCLUDED.default_meta_title,
			default_meta_description = EXCLUDED.default_meta_description,
			default_og_image = EXCLUDED.default_og_image,
			primary_color = EXCLUDED.primary_color,
			secondary_color = EXCLUDED.secondary_color,
			footer_text = EXCLUDED.footer_text,
			google_analytics_id = EXCLUDED.google_analytics_id,
			custom_head_code = EXCLUDED.custom_head_code,
			custom_body_code = EXCLUDED.custom_body_code,
			maintenance_mode = EXCLUDED.maintenance_mode,
			maintenance_message = EXCLUDED.maintenance_message,
			updated_at = EXCLUDED.updated_at
	`, s)
	return err
}

func (r *SettingsRepository) FindBySiteID(siteID uuid.UUID) (*settings.Settings, error) {
	var s settings.Settings
	err := r.db.Get(&s, `SELECT * FROM site_settings WHERE site_id = $1`, siteID)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("settings not found for site: %s", siteID)
	}
	return &s, err
}

package updatesettings

import (
	"context"
	"time"

	"github.com/erickmo/vernon-cms/internal/domain/settings"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	SiteName               string  `json:"site_name"`
	SiteDescription        *string `json:"site_description"`
	SiteURL                *string `json:"site_url"`
	LogoURL                *string `json:"logo_url"`
	FaviconURL             *string `json:"favicon_url"`
	DefaultMetaTitle       *string `json:"default_meta_title"`
	DefaultMetaDescription *string `json:"default_meta_description"`
	DefaultOGImage         *string `json:"default_og_image"`
	PrimaryColor           *string `json:"primary_color"`
	SecondaryColor         *string `json:"secondary_color"`
	FooterText             *string `json:"footer_text"`
	GoogleAnalyticsID      *string `json:"google_analytics_id"`
	CustomHeadCode         *string `json:"custom_head_code"`
	CustomBodyCode         *string `json:"custom_body_code"`
	MaintenanceMode        bool    `json:"maintenance_mode"`
	MaintenanceMessage     *string `json:"maintenance_message"`
}

func (c Command) CommandName() string { return "UpdateSettings" }

type Handler struct {
	repo settings.WriteRepository
}

func NewHandler(repo settings.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	siteID := middleware.GetSiteID(ctx)

	s := &settings.Settings{
		SiteID:                 siteID,
		SiteName:               c.SiteName,
		SiteDescription:        c.SiteDescription,
		SiteURL:                c.SiteURL,
		LogoURL:                c.LogoURL,
		FaviconURL:             c.FaviconURL,
		DefaultMetaTitle:       c.DefaultMetaTitle,
		DefaultMetaDescription: c.DefaultMetaDescription,
		DefaultOGImage:         c.DefaultOGImage,
		PrimaryColor:           c.PrimaryColor,
		SecondaryColor:         c.SecondaryColor,
		FooterText:             c.FooterText,
		GoogleAnalyticsID:      c.GoogleAnalyticsID,
		CustomHeadCode:         c.CustomHeadCode,
		CustomBodyCode:         c.CustomBodyCode,
		MaintenanceMode:        c.MaintenanceMode,
		MaintenanceMessage:     c.MaintenanceMessage,
		UpdatedAt:              time.Now(),
	}

	return h.repo.Upsert(s)
}

package unit

import (
	"context"
	"fmt"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	updatesettings "github.com/erickmo/vernon-cms/internal/command/update_settings"
	"github.com/erickmo/vernon-cms/pkg/middleware"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func ctxWithSite(siteID uuid.UUID) context.Context {
	return context.WithValue(context.Background(), middleware.TenantKey, siteID)
}

func TestUpdateSettingsHandler(t *testing.T) {
	t.Log("=== Scenario: UpdateSettings Command Handler ===")
	t.Log("Goal: Verify settings upsert for a given site")

	repo := mocks.NewMockSettingsWriteRepository()
	handler := updatesettings.NewHandler(repo)
	siteID := uuid.New()
	ctx := ctxWithSite(siteID)

	t.Run("success - creates settings for site", func(t *testing.T) {
		repo.Reset()

		desc := "A great site"
		cmd := updatesettings.Command{
			SiteName:        "My Site",
			SiteDescription: &desc,
			MaintenanceMode: false,
		}

		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		saved := repo.Get(siteID)
		require.NotNil(t, saved)
		assert.Equal(t, "My Site", saved.SiteName)
		assert.Equal(t, siteID, saved.SiteID)
		assert.Equal(t, &desc, saved.SiteDescription)
		t.Log("Result: Settings upserted with correct site_id and values")
		t.Log("Status: PASSED")
	})

	t.Run("success - updates existing settings (upsert)", func(t *testing.T) {
		repo.Reset()

		cmd1 := updatesettings.Command{SiteName: "Old Name"}
		_ = handler.Handle(ctx, cmd1)

		cmd2 := updatesettings.Command{SiteName: "New Name", MaintenanceMode: true}
		err := handler.Handle(ctx, cmd2)

		require.NoError(t, err)
		saved := repo.Get(siteID)
		require.NotNil(t, saved)
		assert.Equal(t, "New Name", saved.SiteName)
		assert.True(t, saved.MaintenanceMode)
		t.Log("Result: Settings replaced by upsert — last write wins")
		t.Log("Status: PASSED")
	})

	t.Run("success - maintenance mode on/off", func(t *testing.T) {
		repo.Reset()

		msg := "Under maintenance"
		cmd := updatesettings.Command{
			SiteName:           "Site",
			MaintenanceMode:    true,
			MaintenanceMessage: &msg,
		}

		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		saved := repo.Get(siteID)
		require.NotNil(t, saved)
		assert.True(t, saved.MaintenanceMode)
		assert.Equal(t, &msg, saved.MaintenanceMessage)
		t.Log("Result: Maintenance mode saved correctly")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repository upsert error", func(t *testing.T) {
		repo.Reset()
		repo.UpsertErr = fmt.Errorf("database write error")

		cmd := updatesettings.Command{SiteName: "Site"}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "database write error")
		t.Log("Result: Repository error propagated correctly")
		t.Log("Status: PASSED")
	})

	t.Run("success - different sites are isolated", func(t *testing.T) {
		repo.Reset()

		siteA := uuid.New()
		siteB := uuid.New()

		ctxA := ctxWithSite(siteA)
		ctxB := ctxWithSite(siteB)

		_ = handler.Handle(ctxA, updatesettings.Command{SiteName: "Site A"})
		_ = handler.Handle(ctxB, updatesettings.Command{SiteName: "Site B"})

		savedA := repo.Get(siteA)
		savedB := repo.Get(siteB)

		require.NotNil(t, savedA)
		require.NotNil(t, savedB)
		assert.Equal(t, "Site A", savedA.SiteName)
		assert.Equal(t, "Site B", savedB.SiteName)
		t.Log("Result: Different sites have independent settings")
		t.Log("Status: PASSED")
	})
}

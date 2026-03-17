package unit

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	createapitoken "github.com/erickmo/vernon-cms/internal/command/create_api_token"
	deleteapitoken "github.com/erickmo/vernon-cms/internal/command/delete_api_token"
	toggleapitoken "github.com/erickmo/vernon-cms/internal/command/toggle_api_token"
	updateapitoken "github.com/erickmo/vernon-cms/internal/command/update_api_token"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func TestCreateAPITokenHandler(t *testing.T) {
	t.Log("=== Scenario: CreateAPIToken Command Handler ===")
	t.Log("Goal: Verify API token creation with SHA-256 hashing and plain token returned via context")

	repo := mocks.NewMockAPITokenWriteRepository()
	handler := createapitoken.NewHandler(repo)
	siteID := uuid.New()
	ctx := ctxWithSite(siteID)

	t.Run("success - creates token and returns plain via context result", func(t *testing.T) {
		repo.Reset()

		cmd := createapitoken.Command{
			Name:        "My API Key",
			Permissions: []string{"read:content", "write:content"},
		}

		result := &createapitoken.Result{}
		ctxWithResult := createapitoken.WithResult(ctx, result)

		err := handler.Handle(ctxWithResult, cmd)

		require.NoError(t, err)
		assert.Equal(t, 1, repo.Count())
		require.NotNil(t, result.Token)
		assert.NotEmpty(t, result.Plain)
		assert.Equal(t, "My API Key", result.Token.Name)
		assert.Equal(t, siteID, result.Token.SiteID)
		assert.True(t, result.Token.IsActive)
		assert.NotEmpty(t, result.Token.TokenHash)
		assert.NotEmpty(t, result.Token.Prefix)
		assert.Equal(t, result.Token.Prefix, result.Plain[:8])
		assert.Len(t, result.Token.Permissions, 2)
		t.Log("Result: Token created, SHA-256 hash stored, plain token returned")
		t.Log("Status: PASSED")
	})

	t.Run("success - creates token with expiry", func(t *testing.T) {
		repo.Reset()

		expiresAt := time.Now().Add(30 * 24 * time.Hour)
		cmd := createapitoken.Command{
			Name:      "Expiring Token",
			ExpiresAt: &expiresAt,
		}

		result := &createapitoken.Result{}
		err := handler.Handle(createapitoken.WithResult(ctx, result), cmd)

		require.NoError(t, err)
		require.NotNil(t, result.Token.ExpiresAt)
		assert.WithinDuration(t, expiresAt, *result.Token.ExpiresAt, time.Second)
		t.Log("Result: Token with expiry created correctly")
		t.Log("Status: PASSED")
	})

	t.Run("success - empty permissions defaults to empty slice", func(t *testing.T) {
		repo.Reset()

		cmd := createapitoken.Command{
			Name:        "Token Without Perms",
			Permissions: nil,
		}

		result := &createapitoken.Result{}
		err := handler.Handle(createapitoken.WithResult(ctx, result), cmd)

		require.NoError(t, err)
		assert.NotNil(t, result.Token.Permissions)
		assert.Len(t, result.Token.Permissions, 0)
		t.Log("Result: Nil permissions defaults to empty slice")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name returns domain error", func(t *testing.T) {
		repo.Reset()

		cmd := createapitoken.Command{Name: ""}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "token name is required")
		assert.Equal(t, 0, repo.Count())
		t.Log("Result: Domain validation rejects empty name")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repository save error", func(t *testing.T) {
		repo.Reset()
		repo.SaveErr = fmt.Errorf("connection refused")

		cmd := createapitoken.Command{Name: "Token"}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "connection refused")
		t.Log("Result: Repository error propagated correctly")
		t.Log("Status: PASSED")
	})

	t.Run("success - plain token is not stored (only hash)", func(t *testing.T) {
		repo.Reset()

		result := &createapitoken.Result{}
		cmd := createapitoken.Command{Name: "Secure Token"}
		err := handler.Handle(createapitoken.WithResult(ctx, result), cmd)

		require.NoError(t, err)
		// hash should NOT equal plain
		assert.NotEqual(t, result.Plain, result.Token.TokenHash)
		// hash should be 64-char hex (SHA-256)
		assert.Len(t, result.Token.TokenHash, 64)
		t.Log("Result: Token hash is SHA-256, different from plain token")
		t.Log("Status: PASSED")
	})
}

func TestUpdateAPITokenHandler(t *testing.T) {
	t.Log("=== Scenario: UpdateAPIToken Command Handler ===")
	t.Log("Goal: Verify API token update with not-found guard")

	repo := mocks.NewMockAPITokenWriteRepository()
	handler := updateapitoken.NewHandler(repo)
	siteID := uuid.New()
	ctx := ctxWithSite(siteID)

	t.Run("success - updates name and permissions", func(t *testing.T) {
		repo.Reset()

		// Seed a token
		createHandler := createapitoken.NewHandler(repo)
		result := &createapitoken.Result{}
		_ = createHandler.Handle(createapitoken.WithResult(ctx, result), createapitoken.Command{
			Name:        "Old Name",
			Permissions: []string{"read:content"},
		})

		newPerms := []string{"read:content", "write:media"}
		cmd := updateapitoken.Command{
			ID:          result.Token.ID,
			Name:        "New Name",
			Permissions: newPerms,
		}

		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		updated, _ := repo.FindByID(result.Token.ID, siteID)
		require.NotNil(t, updated)
		assert.Equal(t, "New Name", updated.Name)
		assert.Equal(t, newPerms, updated.Permissions)
		t.Log("Result: Token name and permissions updated correctly")
		t.Log("Status: PASSED")
	})

	t.Run("fail - token not found", func(t *testing.T) {
		repo.Reset()

		cmd := updateapitoken.Command{
			ID:   uuid.New(), // non-existent
			Name: "Name",
		}

		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Result: Not-found error returned for unknown token ID")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repository update error", func(t *testing.T) {
		repo.Reset()

		createHandler := createapitoken.NewHandler(repo)
		result := &createapitoken.Result{}
		_ = createHandler.Handle(createapitoken.WithResult(ctx, result), createapitoken.Command{Name: "Token"})

		repo.UpdateErr = fmt.Errorf("write failed")
		cmd := updateapitoken.Command{ID: result.Token.ID, Name: "New Name"}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "write failed")
		t.Log("Status: PASSED")
	})
}

func TestDeleteAPITokenHandler(t *testing.T) {
	t.Log("=== Scenario: DeleteAPIToken Command Handler ===")
	t.Log("Goal: Verify API token deletion with not-found guard")

	repo := mocks.NewMockAPITokenWriteRepository()
	handler := deleteapitoken.NewHandler(repo)
	siteID := uuid.New()
	ctx := ctxWithSite(siteID)

	t.Run("success - deletes existing token", func(t *testing.T) {
		repo.Reset()

		createHandler := createapitoken.NewHandler(repo)
		result := &createapitoken.Result{}
		_ = createHandler.Handle(createapitoken.WithResult(ctx, result), createapitoken.Command{Name: "Token"})
		require.Equal(t, 1, repo.Count())

		err := handler.Handle(ctx, deleteapitoken.Command{ID: result.Token.ID})

		require.NoError(t, err)
		assert.Equal(t, 0, repo.Count())
		t.Log("Result: Token deleted successfully")
		t.Log("Status: PASSED")
	})

	t.Run("fail - token not found", func(t *testing.T) {
		repo.Reset()

		err := handler.Handle(ctx, deleteapitoken.Command{ID: uuid.New()})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})

	t.Run("fail - delete same token twice", func(t *testing.T) {
		repo.Reset()

		createHandler := createapitoken.NewHandler(repo)
		result := &createapitoken.Result{}
		_ = createHandler.Handle(createapitoken.WithResult(ctx, result), createapitoken.Command{Name: "Token"})

		id := result.Token.ID
		_ = handler.Handle(ctx, deleteapitoken.Command{ID: id})
		err := handler.Handle(ctx, deleteapitoken.Command{ID: id})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Result: Second delete returns not-found error")
		t.Log("Status: PASSED")
	})
}

func TestToggleAPITokenHandler(t *testing.T) {
	t.Log("=== Scenario: ToggleAPIToken Command Handler ===")
	t.Log("Goal: Verify API token active state toggling")

	repo := mocks.NewMockAPITokenWriteRepository()
	handler := toggleapitoken.NewHandler(repo)
	siteID := uuid.New()
	ctx := ctxWithSite(siteID)

	t.Run("success - active token becomes inactive", func(t *testing.T) {
		repo.Reset()

		createHandler := createapitoken.NewHandler(repo)
		result := &createapitoken.Result{}
		_ = createHandler.Handle(createapitoken.WithResult(ctx, result), createapitoken.Command{Name: "Token"})
		require.True(t, result.Token.IsActive)

		err := handler.Handle(ctx, toggleapitoken.Command{ID: result.Token.ID})

		require.NoError(t, err)
		token, _ := repo.FindByID(result.Token.ID, siteID)
		assert.False(t, token.IsActive)
		t.Log("Result: Token deactivated (active → inactive)")
		t.Log("Status: PASSED")
	})

	t.Run("success - inactive token becomes active", func(t *testing.T) {
		repo.Reset()

		createHandler := createapitoken.NewHandler(repo)
		result := &createapitoken.Result{}
		_ = createHandler.Handle(createapitoken.WithResult(ctx, result), createapitoken.Command{Name: "Token"})

		// Toggle once (active → inactive)
		_ = handler.Handle(ctx, toggleapitoken.Command{ID: result.Token.ID})

		// Toggle again (inactive → active)
		err := handler.Handle(ctx, toggleapitoken.Command{ID: result.Token.ID})

		require.NoError(t, err)
		token, _ := repo.FindByID(result.Token.ID, siteID)
		assert.True(t, token.IsActive)
		t.Log("Result: Token re-activated (inactive → active)")
		t.Log("Status: PASSED")
	})

	t.Run("fail - token not found", func(t *testing.T) {
		repo.Reset()

		err := handler.Handle(ctx, toggleapitoken.Command{ID: uuid.New()})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})

	t.Run("success - multiple sites: toggle one does not affect another", func(t *testing.T) {
		repo.Reset()

		siteA := uuid.New()
		siteB := uuid.New()
		ctxA := ctxWithSite(siteA)
		ctxB := ctxWithSite(siteB)

		createHandler := createapitoken.NewHandler(repo)
		rA := &createapitoken.Result{}
		rB := &createapitoken.Result{}
		_ = createHandler.Handle(createapitoken.WithResult(ctxA, rA), createapitoken.Command{Name: "Token A"})
		_ = createHandler.Handle(createapitoken.WithResult(ctxB, rB), createapitoken.Command{Name: "Token B"})

		// Toggle only site A's token
		_ = handler.Handle(context.Background(), toggleapitoken.Command{ID: rA.Token.ID})

		tokenA, _ := repo.FindByID(rA.Token.ID, siteA)
		tokenB, _ := repo.FindByID(rB.Token.ID, siteB)

		assert.False(t, tokenA.IsActive)
		assert.True(t, tokenB.IsActive)
		t.Log("Result: Toggle is scoped to specific token ID — other tokens unaffected")
		t.Log("Status: PASSED")
	})
}

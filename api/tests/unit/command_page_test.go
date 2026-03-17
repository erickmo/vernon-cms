package unit

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	createpage "github.com/erickmo/vernon-cms/internal/command/create_page"
	deletepage "github.com/erickmo/vernon-cms/internal/command/delete_page"
	updatepage "github.com/erickmo/vernon-cms/internal/command/update_page"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func TestCreatePageHandler(t *testing.T) {
	t.Log("=== Scenario: CreatePage Command Handler ===")
	t.Log("Goal: Verify page creation through command handler with event publishing")

	repo := mocks.NewMockPageRepository()
	eb := mocks.NewMockEventBus()
	handler := createpage.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - creates page and publishes event", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createpage.Command{
			Name:      "Home Page",
			Slug:      "home-page",
			Variables: json.RawMessage(`{"title":""}`),
		}

		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, 1, repo.Count())
		assert.Equal(t, 1, eb.EventCount())
		assert.Equal(t, "page.created", eb.LastEvent().EventName())
		t.Log("Result: Page saved and page.created event published")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name validation", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createpage.Command{
			Name: "",
			Slug: "slug",
		}

		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Equal(t, 0, repo.Count())
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Result: Domain validation failed, nothing saved, no event published")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repository save error", func(t *testing.T) {
		repo.Reset()
		eb.Reset()
		repo.SaveErr = fmt.Errorf("database connection lost")

		cmd := createpage.Command{
			Name: "Page",
			Slug: "page",
		}

		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "database connection lost")
		assert.Equal(t, 0, eb.EventCount()) // no event on failure
		t.Log("Result: Repo error propagated, no event published")
		t.Log("Status: PASSED")
	})

	t.Run("fail - duplicate slug", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createpage.Command{Name: "Page 1", Slug: "same-slug"}
		_ = handler.Handle(ctx, cmd)

		cmd2 := createpage.Command{Name: "Page 2", Slug: "same-slug"}
		err := handler.Handle(ctx, cmd2)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "duplicate")
		t.Log("Result: Duplicate slug rejected")
		t.Log("Status: PASSED")
	})

	t.Run("fail - event bus failure does not rollback but returns error", func(t *testing.T) {
		repo.Reset()
		eb.Reset()
		eb.ShouldFail = true
		eb.FailErr = fmt.Errorf("event bus unavailable")

		cmd := createpage.Command{Name: "Page", Slug: "page"}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "event bus unavailable")
		assert.Equal(t, 1, repo.Count()) // saved but event failed
		t.Log("Result: Page saved but event publish error returned")
		t.Log("Status: PASSED")
	})
}

func TestUpdatePageHandler(t *testing.T) {
	t.Log("=== Scenario: UpdatePage Command Handler ===")
	t.Log("Goal: Verify page update with not-found guard and event publishing")

	repo := mocks.NewMockPageRepository()
	eb := mocks.NewMockEventBus()
	handler := updatepage.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - updates existing page", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		// Seed a page
		createHandler := createpage.NewHandler(repo, eb)
		_ = createHandler.Handle(ctx, createpage.Command{Name: "Old", Slug: "old-slug"})
		eb.Reset()

		pages, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		require.Len(t, pages, 1)

		isActive := true
		cmd := updatepage.Command{
			ID:        pages[0].ID,
			Name:      "Updated Name",
			Slug:      "updated-slug",
			Variables: json.RawMessage(`{"new_var":"value"}`),
			IsActive:  &isActive,
		}

		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, 1, eb.EventCount())
		assert.Equal(t, "page.updated", eb.LastEvent().EventName())

		updated, _ := repo.FindByID(pages[0].ID, uuid.UUID{})
		assert.Equal(t, "Updated Name", updated.Name)
		assert.Equal(t, "updated-slug", updated.Slug)
		t.Log("Status: PASSED")
	})

	t.Run("fail - page not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := updatepage.Command{
			ID:   uuid.New(), // non-existent
			Name: "Name",
			Slug: "slug",
		}

		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Result: Not found error, no event published")
		t.Log("Status: PASSED")
	})

	t.Run("fail - update with empty name", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		createHandler := createpage.NewHandler(repo, eb)
		_ = createHandler.Handle(ctx, createpage.Command{Name: "Page", Slug: "slug"})
		eb.Reset()

		pages, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)

		cmd := updatepage.Command{
			ID:   pages[0].ID,
			Name: "",
			Slug: "slug",
		}

		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Result: Domain validation caught empty name")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repository update error", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		createHandler := createpage.NewHandler(repo, eb)
		_ = createHandler.Handle(ctx, createpage.Command{Name: "Page", Slug: "slug"})
		eb.Reset()

		pages, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		repo.UpdateErr = fmt.Errorf("disk full")

		cmd := updatepage.Command{
			ID:   pages[0].ID,
			Name: "New",
			Slug: "new-slug",
		}

		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "disk full")
		t.Log("Status: PASSED")
	})
}

func TestDeletePageHandler(t *testing.T) {
	t.Log("=== Scenario: DeletePage Command Handler ===")
	t.Log("Goal: Verify page deletion with not-found guard and event publishing")

	repo := mocks.NewMockPageRepository()
	eb := mocks.NewMockEventBus()
	handler := deletepage.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - deletes existing page", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		createHandler := createpage.NewHandler(repo, eb)
		_ = createHandler.Handle(ctx, createpage.Command{Name: "Page", Slug: "slug"})
		eb.Reset()

		pages, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)

		cmd := deletepage.Command{ID: pages[0].ID}
		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, 0, repo.Count())
		assert.Equal(t, 1, eb.EventCount())
		assert.Equal(t, "page.deleted", eb.LastEvent().EventName())
		t.Log("Status: PASSED")
	})

	t.Run("fail - page not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := deletepage.Command{ID: uuid.New()}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Status: PASSED")
	})

	t.Run("fail - delete same page twice", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		createHandler := createpage.NewHandler(repo, eb)
		_ = createHandler.Handle(ctx, createpage.Command{Name: "Page", Slug: "slug"})
		eb.Reset()

		pages, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		id := pages[0].ID

		_ = handler.Handle(ctx, deletepage.Command{ID: id})
		err := handler.Handle(ctx, deletepage.Command{ID: id})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Result: Second delete returns not found")
		t.Log("Status: PASSED")
	})
}

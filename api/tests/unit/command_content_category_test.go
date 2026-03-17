package unit

import (
	"context"
	"fmt"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	createcontentcategory "github.com/erickmo/vernon-cms/internal/command/create_content_category"
	deletecontentcategory "github.com/erickmo/vernon-cms/internal/command/delete_content_category"
	updatecontentcategory "github.com/erickmo/vernon-cms/internal/command/update_content_category"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func TestCreateContentCategoryHandler(t *testing.T) {
	t.Log("=== Scenario: CreateContentCategory Command Handler ===")

	repo := mocks.NewMockContentCategoryRepository()
	eb := mocks.NewMockEventBus()
	handler := createcontentcategory.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - creates category and publishes event", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createcontentcategory.Command{Name: "Technology", Slug: "technology"}
		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, 1, eb.EventCount())
		assert.Equal(t, "content_category.created", eb.LastEvent().EventName())
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createcontentcategory.Command{Name: "", Slug: "slug"}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty slug", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createcontentcategory.Command{Name: "Name", Slug: ""}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		t.Log("Status: PASSED")
	})

	t.Run("fail - duplicate slug", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = handler.Handle(ctx, createcontentcategory.Command{Name: "Cat 1", Slug: "same"})
		err := handler.Handle(ctx, createcontentcategory.Command{Name: "Cat 2", Slug: "same"})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "duplicate")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repo error", func(t *testing.T) {
		repo.Reset()
		eb.Reset()
		repo.SaveErr = fmt.Errorf("timeout")

		cmd := createcontentcategory.Command{Name: "Cat", Slug: "cat"}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		t.Log("Status: PASSED")
	})
}

func TestUpdateContentCategoryHandler(t *testing.T) {
	t.Log("=== Scenario: UpdateContentCategory Command Handler ===")

	repo := mocks.NewMockContentCategoryRepository()
	eb := mocks.NewMockEventBus()
	createHandler := createcontentcategory.NewHandler(repo, eb)
	updateHandler := updatecontentcategory.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - updates category", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createcontentcategory.Command{Name: "Old", Slug: "old"})
		eb.Reset()

		cats, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		cmd := updatecontentcategory.Command{ID: cats[0].ID, Name: "New", Slug: "new"}
		err := updateHandler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, "content_category.updated", eb.LastEvent().EventName())

		updated, _ := repo.FindByID(cats[0].ID, uuid.UUID{})
		assert.Equal(t, "New", updated.Name)
		t.Log("Status: PASSED")
	})

	t.Run("fail - not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := updatecontentcategory.Command{ID: uuid.New(), Name: "N", Slug: "s"}
		err := updateHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name on update", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createcontentcategory.Command{Name: "Cat", Slug: "cat"})
		eb.Reset()

		cats, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		cmd := updatecontentcategory.Command{ID: cats[0].ID, Name: "", Slug: "cat"}
		err := updateHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		t.Log("Status: PASSED")
	})
}

func TestDeleteContentCategoryHandler(t *testing.T) {
	t.Log("=== Scenario: DeleteContentCategory Command Handler ===")

	repo := mocks.NewMockContentCategoryRepository()
	eb := mocks.NewMockEventBus()
	createHandler := createcontentcategory.NewHandler(repo, eb)
	deleteHandler := deletecontentcategory.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - deletes category", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createcontentcategory.Command{Name: "Cat", Slug: "cat"})
		eb.Reset()

		cats, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		err := deleteHandler.Handle(ctx, deletecontentcategory.Command{ID: cats[0].ID})

		require.NoError(t, err)
		assert.Equal(t, "content_category.deleted", eb.LastEvent().EventName())
		t.Log("Status: PASSED")
	})

	t.Run("fail - not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		err := deleteHandler.Handle(ctx, deletecontentcategory.Command{ID: uuid.New()})
		assert.Error(t, err)
		t.Log("Status: PASSED")
	})
}

package unit

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	createcontent "github.com/erickmo/vernon-cms/internal/command/create_content"
	deletecontent "github.com/erickmo/vernon-cms/internal/command/delete_content"
	publishcontent "github.com/erickmo/vernon-cms/internal/command/publish_content"
	updatecontent "github.com/erickmo/vernon-cms/internal/command/update_content"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func TestCreateContentHandler(t *testing.T) {
	t.Log("=== Scenario: CreateContent Command Handler ===")
	t.Log("Goal: Verify content creation with FK references and event publishing")

	repo := mocks.NewMockContentRepository()
	eb := mocks.NewMockEventBus()
	handler := createcontent.NewHandler(repo, eb)
	ctx := context.Background()

	pageID := uuid.New()
	catID := uuid.New()
	authorID := uuid.New()

	t.Run("success - creates content with draft status", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createcontent.Command{
			Title:      "My Article",
			Slug:       "my-article",
			Body:       "Article body",
			Excerpt:    "Short excerpt",
			PageID:     pageID,
			CategoryID: catID,
			AuthorID:   authorID,
			Metadata:   json.RawMessage(`{"tags":["go"]}`),
		}

		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, 1, eb.EventCount())
		assert.Equal(t, "content.created", eb.LastEvent().EventName())
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty title", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createcontent.Command{
			Title:      "",
			Slug:       "slug",
			PageID:     pageID,
			CategoryID: catID,
			AuthorID:   authorID,
		}

		err := handler.Handle(ctx, cmd)
		assert.Error(t, err)
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Status: PASSED")
	})

	t.Run("fail - duplicate slug", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createcontent.Command{
			Title: "First", Slug: "same", PageID: pageID, CategoryID: catID, AuthorID: authorID,
		}
		_ = handler.Handle(ctx, cmd)

		cmd2 := createcontent.Command{
			Title: "Second", Slug: "same", PageID: pageID, CategoryID: catID, AuthorID: authorID,
		}
		err := handler.Handle(ctx, cmd2)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "duplicate")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repo save error", func(t *testing.T) {
		repo.Reset()
		eb.Reset()
		repo.SaveErr = fmt.Errorf("connection refused")

		cmd := createcontent.Command{
			Title: "Title", Slug: "slug", PageID: pageID, CategoryID: catID, AuthorID: authorID,
		}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Status: PASSED")
	})
}

func TestUpdateContentHandler(t *testing.T) {
	t.Log("=== Scenario: UpdateContent Command Handler ===")

	repo := mocks.NewMockContentRepository()
	eb := mocks.NewMockEventBus()
	createHandler := createcontent.NewHandler(repo, eb)
	updateHandler := updatecontent.NewHandler(repo, eb)
	ctx := context.Background()

	pageID := uuid.New()
	catID := uuid.New()
	authorID := uuid.New()

	t.Run("success - updates content", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createcontent.Command{
			Title: "Old", Slug: "old-slug", PageID: pageID, CategoryID: catID, AuthorID: authorID,
		})
		eb.Reset()

		contents, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		cmd := updatecontent.Command{
			ID:    contents[0].ID,
			Title: "New Title",
			Slug:  "new-slug",
			Body:  "Updated body",
		}

		err := updateHandler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, "content.updated", eb.LastEvent().EventName())

		updated, _ := repo.FindByID(contents[0].ID, uuid.UUID{})
		assert.Equal(t, "New Title", updated.Title)
		assert.Equal(t, "Updated body", updated.Body)
		t.Log("Status: PASSED")
	})

	t.Run("fail - content not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := updatecontent.Command{ID: uuid.New(), Title: "T", Slug: "s"}
		err := updateHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty title on update", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createcontent.Command{
			Title: "Title", Slug: "slug", PageID: pageID, CategoryID: catID, AuthorID: authorID,
		})
		eb.Reset()

		contents, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		cmd := updatecontent.Command{ID: contents[0].ID, Title: "", Slug: "slug"}
		err := updateHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		t.Log("Status: PASSED")
	})
}

func TestPublishContentHandler(t *testing.T) {
	t.Log("=== Scenario: PublishContent Command Handler ===")
	t.Log("Goal: Verify publish lifecycle through command handler")

	repo := mocks.NewMockContentRepository()
	eb := mocks.NewMockEventBus()
	createHandler := createcontent.NewHandler(repo, eb)
	publishHandler := publishcontent.NewHandler(repo, eb)
	ctx := context.Background()

	pageID := uuid.New()
	catID := uuid.New()
	authorID := uuid.New()

	t.Run("success - publish draft content", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createcontent.Command{
			Title: "Article", Slug: "article", Body: "Body",
			PageID: pageID, CategoryID: catID, AuthorID: authorID,
		})
		eb.Reset()

		contents, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		err := publishHandler.Handle(ctx, publishcontent.Command{ID: contents[0].ID})

		require.NoError(t, err)
		assert.Equal(t, "content.published", eb.LastEvent().EventName())

		published, _ := repo.FindByID(contents[0].ID, uuid.UUID{})
		assert.Equal(t, "published", string(published.Status))
		assert.NotNil(t, published.PublishedAt)
		t.Log("Status: PASSED")
	})

	t.Run("fail - double publish", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createcontent.Command{
			Title: "Article", Slug: "article", PageID: pageID, CategoryID: catID, AuthorID: authorID,
		})
		eb.Reset()

		contents, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		_ = publishHandler.Handle(ctx, publishcontent.Command{ID: contents[0].ID})
		eb.Reset()

		err := publishHandler.Handle(ctx, publishcontent.Command{ID: contents[0].ID})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "already published")
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Result: Double publish blocked, no event published")
		t.Log("Status: PASSED")
	})

	t.Run("fail - publish non-existent content", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		err := publishHandler.Handle(ctx, publishcontent.Command{ID: uuid.New()})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})
}

func TestDeleteContentHandler(t *testing.T) {
	t.Log("=== Scenario: DeleteContent Command Handler ===")

	repo := mocks.NewMockContentRepository()
	eb := mocks.NewMockEventBus()
	createHandler := createcontent.NewHandler(repo, eb)
	deleteHandler := deletecontent.NewHandler(repo, eb)
	ctx := context.Background()

	pageID := uuid.New()
	catID := uuid.New()
	authorID := uuid.New()

	t.Run("success - deletes content", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createcontent.Command{
			Title: "Article", Slug: "article", PageID: pageID, CategoryID: catID, AuthorID: authorID,
		})
		eb.Reset()

		contents, _, _ := repo.FindAll(uuid.UUID{}, 0, 1)
		err := deleteHandler.Handle(ctx, deletecontent.Command{ID: contents[0].ID})

		require.NoError(t, err)
		assert.Equal(t, "content.deleted", eb.LastEvent().EventName())
		t.Log("Status: PASSED")
	})

	t.Run("fail - delete non-existent", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		err := deleteHandler.Handle(ctx, deletecontent.Command{ID: uuid.New()})
		assert.Error(t, err)
		t.Log("Status: PASSED")
	})
}

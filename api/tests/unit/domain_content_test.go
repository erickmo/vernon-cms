package unit

import (
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/erickmo/vernon-cms/internal/domain/content"
)

func TestNewContent(t *testing.T) {
	t.Log("=== Scenario: Content Entity Creation ===")
	t.Log("Goal: Verify factory validates input and creates entity with correct defaults")

	pageID := uuid.New()
	catID := uuid.New()
	authorID := uuid.New()

	t.Run("success - valid input with default status draft", func(t *testing.T) {
		c, err := content.NewContent(uuid.UUID{}, "Title", "title-slug", "Body text", "Excerpt",
			pageID, catID, authorID, nil)

		require.NoError(t, err)
		assert.NotEmpty(t, c.ID)
		assert.Equal(t, "Title", c.Title)
		assert.Equal(t, "title-slug", c.Slug)
		assert.Equal(t, "Body text", c.Body)
		assert.Equal(t, "Excerpt", c.Excerpt)
		assert.Equal(t, content.StatusDraft, c.Status)
		assert.Equal(t, pageID, c.PageID)
		assert.Equal(t, catID, c.CategoryID)
		assert.Equal(t, authorID, c.AuthorID)
		assert.Nil(t, c.PublishedAt)
		assert.JSONEq(t, `{}`, string(c.Metadata))
		t.Log("Result: Content created with status=draft, published_at=nil, metadata={}")
		t.Log("Status: PASSED")
	})

	t.Run("success - with custom metadata", func(t *testing.T) {
		meta := json.RawMessage(`{"seo_title":"Custom","og_image":"img.jpg"}`)
		c, err := content.NewContent(uuid.UUID{}, "Title", "slug", "", "", pageID, catID, authorID, meta)

		require.NoError(t, err)
		assert.JSONEq(t, `{"seo_title":"Custom","og_image":"img.jpg"}`, string(c.Metadata))
		t.Log("Status: PASSED")
	})

	t.Run("success - empty body and excerpt allowed", func(t *testing.T) {
		c, err := content.NewContent(uuid.UUID{}, "Title", "slug2", "", "", pageID, catID, authorID, nil)

		require.NoError(t, err)
		assert.Empty(t, c.Body)
		assert.Empty(t, c.Excerpt)
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty title", func(t *testing.T) {
		c, err := content.NewContent(uuid.UUID{}, "", "slug", "body", "excerpt", pageID, catID, authorID, nil)

		assert.Nil(t, c)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "title")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty slug", func(t *testing.T) {
		c, err := content.NewContent(uuid.UUID{}, "Title", "", "body", "excerpt", pageID, catID, authorID, nil)

		assert.Nil(t, c)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "slug")
		t.Log("Status: PASSED")
	})
}

func TestContentPublish(t *testing.T) {
	t.Log("=== Scenario: Content Publishing Lifecycle ===")
	t.Log("Goal: Verify publish state transitions and guard against double-publish")

	pageID := uuid.New()
	catID := uuid.New()
	authorID := uuid.New()

	t.Run("success - draft → published", func(t *testing.T) {
		c, _ := content.NewContent(uuid.UUID{}, "Title", "slug", "body", "excerpt", pageID, catID, authorID, nil)
		assert.Equal(t, content.StatusDraft, c.Status)
		assert.Nil(t, c.PublishedAt)

		err := c.Publish()

		assert.NoError(t, err)
		assert.Equal(t, content.StatusPublished, c.Status)
		assert.NotNil(t, c.PublishedAt)
		t.Log("Result: Status changed to published, published_at set")
		t.Log("Status: PASSED")
	})

	t.Run("fail - published → published (double publish)", func(t *testing.T) {
		c, _ := content.NewContent(uuid.UUID{}, "Title", "slug2", "body", "excerpt", pageID, catID, authorID, nil)
		_ = c.Publish()

		err := c.Publish()

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "already published")
		t.Log("Result: Double publish blocked with error")
		t.Log("Status: PASSED")
	})

	t.Run("success - published → archived", func(t *testing.T) {
		c, _ := content.NewContent(uuid.UUID{}, "Title", "slug3", "body", "excerpt", pageID, catID, authorID, nil)
		_ = c.Publish()

		c.Archive()

		assert.Equal(t, content.StatusArchived, c.Status)
		t.Log("Result: Archived from published state")
		t.Log("Status: PASSED")
	})

	t.Run("success - archived → draft (revert to draft)", func(t *testing.T) {
		c, _ := content.NewContent(uuid.UUID{}, "Title", "slug4", "body", "excerpt", pageID, catID, authorID, nil)
		_ = c.Publish()
		c.Archive()

		c.ToDraft()

		assert.Equal(t, content.StatusDraft, c.Status)
		assert.Nil(t, c.PublishedAt) // reset
		t.Log("Result: Reverted to draft, published_at cleared")
		t.Log("Status: PASSED")
	})

	t.Run("success - draft → archived", func(t *testing.T) {
		c, _ := content.NewContent(uuid.UUID{}, "Title", "slug5", "body", "excerpt", pageID, catID, authorID, nil)

		c.Archive()

		assert.Equal(t, content.StatusArchived, c.Status)
		t.Log("Result: Can archive from draft state")
		t.Log("Status: PASSED")
	})

	t.Run("success - archived → published (re-publish after archive)", func(t *testing.T) {
		c, _ := content.NewContent(uuid.UUID{}, "Title", "slug6", "body", "excerpt", pageID, catID, authorID, nil)
		c.Archive()

		err := c.Publish()

		assert.NoError(t, err)
		assert.Equal(t, content.StatusPublished, c.Status)
		assert.NotNil(t, c.PublishedAt)
		t.Log("Result: Can publish from archived state")
		t.Log("Status: PASSED")
	})
}

func TestContentUpdateTitle(t *testing.T) {
	t.Log("=== Scenario: Content Title Update ===")

	c, _ := content.NewContent(uuid.UUID{}, "Old", "slug", "", "", uuid.New(), uuid.New(), uuid.New(), nil)

	t.Run("success - valid title", func(t *testing.T) {
		err := c.UpdateTitle("New Title")
		assert.NoError(t, err)
		assert.Equal(t, "New Title", c.Title)
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty title", func(t *testing.T) {
		err := c.UpdateTitle("")
		assert.Error(t, err)
		assert.Equal(t, "New Title", c.Title) // unchanged
		t.Log("Status: PASSED")
	})
}

func TestContentUpdateSlug(t *testing.T) {
	t.Log("=== Scenario: Content Slug Update ===")

	c, _ := content.NewContent(uuid.UUID{}, "Title", "old-slug", "", "", uuid.New(), uuid.New(), uuid.New(), nil)

	t.Run("success - valid slug", func(t *testing.T) {
		err := c.UpdateSlug("new-slug")
		assert.NoError(t, err)
		assert.Equal(t, "new-slug", c.Slug)
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty slug", func(t *testing.T) {
		err := c.UpdateSlug("")
		assert.Error(t, err)
		assert.Equal(t, "new-slug", c.Slug) // unchanged
		t.Log("Status: PASSED")
	})
}

func TestContentUpdateBody(t *testing.T) {
	t.Log("=== Scenario: Content Body & Excerpt Update ===")

	c, _ := content.NewContent(uuid.UUID{}, "Title", "slug", "", "", uuid.New(), uuid.New(), uuid.New(), nil)
	originalUpdatedAt := c.UpdatedAt

	c.UpdateBody("New body content", "New excerpt")

	assert.Equal(t, "New body content", c.Body)
	assert.Equal(t, "New excerpt", c.Excerpt)
	assert.True(t, c.UpdatedAt.After(originalUpdatedAt) || c.UpdatedAt.Equal(originalUpdatedAt))
	t.Log("Status: PASSED")
}

func TestContentUpdateMetadata(t *testing.T) {
	t.Log("=== Scenario: Content Metadata Update ===")

	c, _ := content.NewContent(uuid.UUID{}, "Title", "slug", "", "", uuid.New(), uuid.New(), uuid.New(), nil)

	t.Run("update with valid JSON", func(t *testing.T) {
		meta := json.RawMessage(`{"seo":"test","tags":["go","cms"]}`)
		c.UpdateMetadata(meta)

		assert.JSONEq(t, `{"seo":"test","tags":["go","cms"]}`, string(c.Metadata))
		t.Log("Status: PASSED")
	})
}

func TestContentStatusConstants(t *testing.T) {
	t.Log("=== Scenario: Status Constants Validity ===")

	assert.Equal(t, content.Status("draft"), content.StatusDraft)
	assert.Equal(t, content.Status("published"), content.StatusPublished)
	assert.Equal(t, content.Status("archived"), content.StatusArchived)
	t.Log("Status: PASSED")
}

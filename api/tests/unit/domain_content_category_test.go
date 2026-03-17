package unit

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	contentcategory "github.com/erickmo/vernon-cms/internal/domain/content_category"
)

func TestNewContentCategory(t *testing.T) {
	t.Log("=== Scenario: ContentCategory Entity Creation ===")
	t.Log("Goal: Verify factory validates input and creates entity correctly")

	t.Run("success - valid input", func(t *testing.T) {
		c, err := contentcategory.NewContentCategory(uuid.UUID{}, "Technology", "technology")

		require.NoError(t, err)
		assert.NotEmpty(t, c.ID)
		assert.Equal(t, "Technology", c.Name)
		assert.Equal(t, "technology", c.Slug)
		assert.False(t, c.CreatedAt.IsZero())
		assert.False(t, c.UpdatedAt.IsZero())
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name", func(t *testing.T) {
		c, err := contentcategory.NewContentCategory(uuid.UUID{}, "", "slug")

		assert.Nil(t, c)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "name")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty slug", func(t *testing.T) {
		c, err := contentcategory.NewContentCategory(uuid.UUID{}, "Name", "")

		assert.Nil(t, c)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "slug")
		t.Log("Status: PASSED")
	})

	t.Run("fail - both empty", func(t *testing.T) {
		c, err := contentcategory.NewContentCategory(uuid.UUID{}, "", "")

		assert.Nil(t, c)
		assert.Error(t, err)
		t.Log("Status: PASSED")
	})
}

func TestContentCategoryUpdateName(t *testing.T) {
	t.Log("=== Scenario: ContentCategory Name Update ===")

	c, _ := contentcategory.NewContentCategory(uuid.UUID{}, "Old", "slug")

	t.Run("success - valid update", func(t *testing.T) {
		err := c.UpdateName("New Name")
		assert.NoError(t, err)
		assert.Equal(t, "New Name", c.Name)
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name", func(t *testing.T) {
		err := c.UpdateName("")
		assert.Error(t, err)
		assert.Equal(t, "New Name", c.Name) // unchanged
		t.Log("Status: PASSED")
	})
}

func TestContentCategoryUpdateSlug(t *testing.T) {
	t.Log("=== Scenario: ContentCategory Slug Update ===")

	c, _ := contentcategory.NewContentCategory(uuid.UUID{}, "Name", "old-slug")

	t.Run("success - valid update", func(t *testing.T) {
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

func TestContentCategoryUniqueIDs(t *testing.T) {
	t.Log("=== Scenario: ContentCategory UUID Uniqueness ===")

	c1, _ := contentcategory.NewContentCategory(uuid.UUID{}, "Cat 1", "cat-1")
	c2, _ := contentcategory.NewContentCategory(uuid.UUID{}, "Cat 2", "cat-2")

	assert.NotEqual(t, c1.ID, c2.ID)
	t.Log("Status: PASSED")
}

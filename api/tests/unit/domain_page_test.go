package unit

import (
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/erickmo/vernon-cms/internal/domain/page"
)

func TestNewPage(t *testing.T) {
	t.Log("=== Scenario: Page Entity Creation ===")
	t.Log("Goal: Verify factory function validates input and creates Page correctly")

	t.Run("success - valid input creates page", func(t *testing.T) {
		t.Log("Flow: NewPage with valid name, slug, variables")
		vars := json.RawMessage(`{"hero_title":"","hero_subtitle":""}`)
		p, err := page.NewPage(uuid.UUID{}, "Home Page", "home-page", vars)

		require.NoError(t, err)
		assert.NotEmpty(t, p.ID)
		assert.Equal(t, "Home Page", p.Name)
		assert.Equal(t, "home-page", p.Slug)
		assert.JSONEq(t, `{"hero_title":"","hero_subtitle":""}`, string(p.Variables))
		assert.True(t, p.IsActive)
		assert.False(t, p.CreatedAt.IsZero())
		assert.False(t, p.UpdatedAt.IsZero())
		t.Log("Result: Page created successfully with all fields populated")
		t.Log("Status: PASSED")
	})

	t.Run("success - nil variables defaults to empty object", func(t *testing.T) {
		t.Log("Flow: NewPage with nil variables → should default to {}")
		p, err := page.NewPage(uuid.UUID{}, "About", "about", nil)

		require.NoError(t, err)
		assert.JSONEq(t, `{}`, string(p.Variables))
		t.Log("Result: Variables defaulted to empty JSON object")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name returns error", func(t *testing.T) {
		t.Log("Flow: NewPage with empty name → should fail validation")
		p, err := page.NewPage(uuid.UUID{}, "", "slug", nil)

		assert.Nil(t, p)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "name")
		t.Log("Result: Error returned for empty name")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty slug returns error", func(t *testing.T) {
		t.Log("Flow: NewPage with empty slug → should fail validation")
		p, err := page.NewPage(uuid.UUID{}, "Name", "", nil)

		assert.Nil(t, p)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "slug")
		t.Log("Result: Error returned for empty slug")
		t.Log("Status: PASSED")
	})

	t.Run("fail - both empty returns first error (name)", func(t *testing.T) {
		t.Log("Flow: NewPage with both empty → should fail on name first")
		p, err := page.NewPage(uuid.UUID{}, "", "", nil)

		assert.Nil(t, p)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "name")
		t.Log("Result: First validation (name) caught")
		t.Log("Status: PASSED")
	})
}

func TestPageUpdateName(t *testing.T) {
	t.Log("=== Scenario: Page Name Update ===")
	t.Log("Goal: Verify name update validates and mutates correctly")

	p, _ := page.NewPage(uuid.UUID{}, "Old", "slug", nil)
	originalUpdatedAt := p.UpdatedAt

	t.Run("success - valid name update", func(t *testing.T) {
		err := p.UpdateName("New Name")

		assert.NoError(t, err)
		assert.Equal(t, "New Name", p.Name)
		assert.True(t, p.UpdatedAt.After(originalUpdatedAt) || p.UpdatedAt.Equal(originalUpdatedAt))
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name rejected", func(t *testing.T) {
		err := p.UpdateName("")

		assert.Error(t, err)
		assert.Equal(t, "New Name", p.Name) // unchanged
		t.Log("Status: PASSED")
	})
}

func TestPageUpdateSlug(t *testing.T) {
	t.Log("=== Scenario: Page Slug Update ===")
	t.Log("Goal: Verify slug update validates and mutates correctly")

	p, _ := page.NewPage(uuid.UUID{}, "Name", "old-slug", nil)

	t.Run("success - valid slug update", func(t *testing.T) {
		err := p.UpdateSlug("new-slug")

		assert.NoError(t, err)
		assert.Equal(t, "new-slug", p.Slug)
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty slug rejected", func(t *testing.T) {
		err := p.UpdateSlug("")

		assert.Error(t, err)
		assert.Equal(t, "new-slug", p.Slug) // unchanged
		t.Log("Status: PASSED")
	})
}

func TestPageUpdateVariables(t *testing.T) {
	t.Log("=== Scenario: Page Variables Update ===")
	t.Log("Goal: Verify JSON variables can be updated")

	p, _ := page.NewPage(uuid.UUID{}, "Name", "slug", nil)

	t.Run("success - update with valid JSON", func(t *testing.T) {
		vars := json.RawMessage(`{"title":"Hello","count":5}`)
		p.UpdateVariables(vars)

		assert.JSONEq(t, `{"title":"Hello","count":5}`, string(p.Variables))
		t.Log("Status: PASSED")
	})

	t.Run("success - update with complex nested JSON", func(t *testing.T) {
		vars := json.RawMessage(`{"sections":[{"type":"hero","fields":{"title":"","image":""}}]}`)
		p.UpdateVariables(vars)

		assert.Contains(t, string(p.Variables), "sections")
		t.Log("Status: PASSED")
	})
}

func TestPageSetActive(t *testing.T) {
	t.Log("=== Scenario: Page Active Status Toggle ===")
	t.Log("Goal: Verify page can be activated/deactivated")

	p, _ := page.NewPage(uuid.UUID{}, "Name", "slug", nil)
	assert.True(t, p.IsActive) // default active

	t.Run("deactivate page", func(t *testing.T) {
		p.SetActive(false)
		assert.False(t, p.IsActive)
		t.Log("Status: PASSED")
	})

	t.Run("reactivate page", func(t *testing.T) {
		p.SetActive(true)
		assert.True(t, p.IsActive)
		t.Log("Status: PASSED")
	})
}

func TestPageUniqueIDs(t *testing.T) {
	t.Log("=== Scenario: Page UUID Uniqueness ===")
	t.Log("Goal: Verify each page gets a unique UUID")

	p1, _ := page.NewPage(uuid.UUID{}, "Page 1", "page-1", nil)
	p2, _ := page.NewPage(uuid.UUID{}, "Page 2", "page-2", nil)

	assert.NotEqual(t, p1.ID, p2.ID)
	t.Log("Status: PASSED")
}

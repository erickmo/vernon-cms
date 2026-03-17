package unit

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"

	"github.com/erickmo/vernon-cms/internal/domain/content"
	contentcategory "github.com/erickmo/vernon-cms/internal/domain/content_category"
	"github.com/erickmo/vernon-cms/internal/domain/page"
	"github.com/erickmo/vernon-cms/internal/domain/user"
)

func TestPageEvents(t *testing.T) {
	t.Log("=== Scenario: Page Domain Events ===")
	t.Log("Goal: Verify all page events implement DomainEvent interface correctly")

	now := time.Now()
	id := uuid.New()

	t.Run("PageCreated", func(t *testing.T) {
		e := page.PageCreated{PageID: id, Name: "Test", Slug: "test", Time: now}
		assert.Equal(t, "page.created", e.EventName())
		assert.Equal(t, now, e.OccurredAt())
		t.Log("Status: PASSED")
	})

	t.Run("PageUpdated", func(t *testing.T) {
		e := page.PageUpdated{PageID: id, Name: "Test", Slug: "test", Time: now}
		assert.Equal(t, "page.updated", e.EventName())
		assert.Equal(t, now, e.OccurredAt())
		t.Log("Status: PASSED")
	})

	t.Run("PageDeleted", func(t *testing.T) {
		e := page.PageDeleted{PageID: id, Time: now}
		assert.Equal(t, "page.deleted", e.EventName())
		assert.Equal(t, now, e.OccurredAt())
		t.Log("Status: PASSED")
	})
}

func TestContentCategoryEvents(t *testing.T) {
	t.Log("=== Scenario: ContentCategory Domain Events ===")

	now := time.Now()
	id := uuid.New()

	t.Run("ContentCategoryCreated", func(t *testing.T) {
		e := contentcategory.ContentCategoryCreated{CategoryID: id, Name: "N", Slug: "s", Time: now}
		assert.Equal(t, "content_category.created", e.EventName())
		assert.Equal(t, now, e.OccurredAt())
		t.Log("Status: PASSED")
	})

	t.Run("ContentCategoryUpdated", func(t *testing.T) {
		e := contentcategory.ContentCategoryUpdated{CategoryID: id, Name: "N", Slug: "s", Time: now}
		assert.Equal(t, "content_category.updated", e.EventName())
		t.Log("Status: PASSED")
	})

	t.Run("ContentCategoryDeleted", func(t *testing.T) {
		e := contentcategory.ContentCategoryDeleted{CategoryID: id, Time: now}
		assert.Equal(t, "content_category.deleted", e.EventName())
		t.Log("Status: PASSED")
	})
}

func TestContentEvents(t *testing.T) {
	t.Log("=== Scenario: Content Domain Events ===")

	now := time.Now()
	id := uuid.New()

	t.Run("ContentCreated", func(t *testing.T) {
		e := content.ContentCreated{ContentID: id, Title: "T", Slug: "s", Time: now}
		assert.Equal(t, "content.created", e.EventName())
		assert.Equal(t, now, e.OccurredAt())
		t.Log("Status: PASSED")
	})

	t.Run("ContentUpdated", func(t *testing.T) {
		e := content.ContentUpdated{ContentID: id, Title: "T", Slug: "s", Time: now}
		assert.Equal(t, "content.updated", e.EventName())
		t.Log("Status: PASSED")
	})

	t.Run("ContentPublished", func(t *testing.T) {
		e := content.ContentPublished{ContentID: id, Title: "T", Slug: "s", Time: now}
		assert.Equal(t, "content.published", e.EventName())
		t.Log("Status: PASSED")
	})

	t.Run("ContentDeleted", func(t *testing.T) {
		e := content.ContentDeleted{ContentID: id, Time: now}
		assert.Equal(t, "content.deleted", e.EventName())
		t.Log("Status: PASSED")
	})
}

func TestUserEvents(t *testing.T) {
	t.Log("=== Scenario: User Domain Events ===")

	now := time.Now()
	id := uuid.New()

	t.Run("UserCreated", func(t *testing.T) {
		e := user.UserCreated{UserID: id, Email: "e", Name: "n", Role: user.RoleAdmin, Time: now}
		assert.Equal(t, "user.created", e.EventName())
		assert.Equal(t, now, e.OccurredAt())
		t.Log("Status: PASSED")
	})

	t.Run("UserUpdated", func(t *testing.T) {
		e := user.UserUpdated{UserID: id, Email: "e", Name: "n", Time: now}
		assert.Equal(t, "user.updated", e.EventName())
		t.Log("Status: PASSED")
	})

	t.Run("UserDeleted", func(t *testing.T) {
		e := user.UserDeleted{UserID: id, Time: now}
		assert.Equal(t, "user.deleted", e.EventName())
		t.Log("Status: PASSED")
	})
}

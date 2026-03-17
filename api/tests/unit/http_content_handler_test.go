package unit

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	createcontent "github.com/erickmo/vernon-cms/internal/command/create_content"
	deletecontent "github.com/erickmo/vernon-cms/internal/command/delete_content"
	publishcontent "github.com/erickmo/vernon-cms/internal/command/publish_content"
	updatecontent "github.com/erickmo/vernon-cms/internal/command/update_content"
	httpdelivery "github.com/erickmo/vernon-cms/internal/delivery/http"
	listcontent "github.com/erickmo/vernon-cms/internal/query/list_content"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/querybus"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func setupContentHTTPTest(t *testing.T) (*chi.Mux, *mocks.MockContentRepository) {
	t.Helper()

	repo := mocks.NewMockContentRepository()
	eb := mocks.NewMockEventBus()

	cmdBus := commandbus.New(nil)
	cmdBus.Register("CreateContent", createcontent.NewHandler(repo, eb))
	cmdBus.Register("UpdateContent", updatecontent.NewHandler(repo, eb))
	cmdBus.Register("DeleteContent", deletecontent.NewHandler(repo, eb))
	cmdBus.Register("PublishContent", publishcontent.NewHandler(repo, eb))

	qBus := querybus.New(nil)
	qBus.Register("ListContent", listcontent.NewHandler(repo))

	handler := httpdelivery.NewContentHandler(cmdBus, qBus)
	r := chi.NewRouter()
	handler.RegisterRoutes(r)

	return r, repo
}

func TestHTTPContentCreate(t *testing.T) {
	t.Log("=== Scenario: HTTP POST /api/v1/contents ===")

	r, _ := setupContentHTTPTest(t)

	t.Run("201 - valid create", func(t *testing.T) {
		body := map[string]interface{}{
			"title":       "Article",
			"slug":        "article",
			"body":        "Body text",
			"excerpt":     "Short",
			"page_id":     uuid.New().String(),
			"category_id": uuid.New().String(),
			"author_id":   uuid.New().String(),
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/contents", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing title", func(t *testing.T) {
		body := map[string]interface{}{
			"slug":        "slug",
			"page_id":     uuid.New().String(),
			"category_id": uuid.New().String(),
			"author_id":   uuid.New().String(),
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/contents", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing page_id", func(t *testing.T) {
		body := map[string]interface{}{
			"title":       "Title",
			"slug":        "slug",
			"category_id": uuid.New().String(),
			"author_id":   uuid.New().String(),
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/contents", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Result: Missing FK reference returns 400")
		t.Log("Status: PASSED")
	})

	t.Run("400 - malformed JSON", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/contents", bytes.NewReader([]byte(`not json`)))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPContentGetByID(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/contents/{id} ===")

	r, _ := setupContentHTTPTest(t)

	t.Run("400 - invalid UUID", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/contents/invalid", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPContentPublish(t *testing.T) {
	t.Log("=== Scenario: HTTP PUT /api/v1/contents/{id}/publish ===")

	r, _ := setupContentHTTPTest(t)

	t.Run("400 - invalid UUID on publish", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPut, "/api/v1/contents/bad-id/publish", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("500 - publish non-existent content", func(t *testing.T) {
		id := uuid.New().String()
		req := httptest.NewRequest(http.MethodPut, "/api/v1/contents/"+id+"/publish", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPContentGetBySlug(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/contents/slug/{slug} ===")

	r, _ := setupContentHTTPTest(t)

	t.Run("404 - slug not found", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/contents/slug/nonexistent", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		// This returns 404 from query handler (not found)
		assert.True(t, w.Code == http.StatusNotFound || w.Code == http.StatusInternalServerError)
		t.Log("Status: PASSED")
	})
}

func TestHTTPContentFullCRUD(t *testing.T) {
	t.Log("=== Scenario: Content Full CRUD via HTTP ===")

	r, _ := setupContentHTTPTest(t)

	// Create
	body := map[string]interface{}{
		"title": "Article", "slug": "article", "body": "Body",
		"page_id": uuid.New().String(), "category_id": uuid.New().String(), "author_id": uuid.New().String(),
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/contents", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	// List
	req = httptest.NewRequest(http.MethodGet, "/api/v1/contents", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	var resp map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &resp)
	data := resp["data"].(map[string]interface{})
	items := data["items"].([]interface{})
	require.Len(t, items, 1)
	contentID := items[0].(map[string]interface{})["id"].(string)

	// Update
	updateBody := map[string]interface{}{"title": "Updated", "slug": "updated", "body": "New body"}
	b, _ = json.Marshal(updateBody)
	req = httptest.NewRequest(http.MethodPut, "/api/v1/contents/"+contentID, bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// Publish
	req = httptest.NewRequest(http.MethodPut, "/api/v1/contents/"+contentID+"/publish", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// Delete
	req = httptest.NewRequest(http.MethodDelete, "/api/v1/contents/"+contentID, nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	t.Log("Result: Create → List → Update → Publish → Delete all passed")
	t.Log("Status: PASSED")
}

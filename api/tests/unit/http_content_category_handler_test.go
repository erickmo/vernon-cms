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

	createcontentcategory "github.com/erickmo/vernon-cms/internal/command/create_content_category"
	deletecontentcategory "github.com/erickmo/vernon-cms/internal/command/delete_content_category"
	updatecontentcategory "github.com/erickmo/vernon-cms/internal/command/update_content_category"
	httpdelivery "github.com/erickmo/vernon-cms/internal/delivery/http"
	listcontentcategory "github.com/erickmo/vernon-cms/internal/query/list_content_category"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/querybus"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func setupCategoryHTTPTest(t *testing.T) *chi.Mux {
	t.Helper()

	repo := mocks.NewMockContentCategoryRepository()
	eb := mocks.NewMockEventBus()

	cmdBus := commandbus.New(nil)
	cmdBus.Register("CreateContentCategory", createcontentcategory.NewHandler(repo, eb))
	cmdBus.Register("UpdateContentCategory", updatecontentcategory.NewHandler(repo, eb))
	cmdBus.Register("DeleteContentCategory", deletecontentcategory.NewHandler(repo, eb))

	qBus := querybus.New(nil)
	qBus.Register("ListContentCategory", listcontentcategory.NewHandler(repo))

	handler := httpdelivery.NewContentCategoryHandler(cmdBus, qBus)
	r := chi.NewRouter()
	handler.RegisterRoutes(r)

	return r
}

func TestHTTPContentCategoryCreate(t *testing.T) {
	t.Log("=== Scenario: HTTP POST /api/v1/content-categories ===")

	r := setupCategoryHTTPTest(t)

	t.Run("201 - valid create", func(t *testing.T) {
		body := map[string]interface{}{"name": "Tech", "slug": "tech"}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/content-categories", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing name", func(t *testing.T) {
		body := map[string]interface{}{"slug": "slug"}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/content-categories", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing slug", func(t *testing.T) {
		body := map[string]interface{}{"name": "Name"}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/content-categories", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - malformed JSON", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/content-categories", bytes.NewReader([]byte(`{bad`)))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPContentCategoryGetByID(t *testing.T) {
	r := setupCategoryHTTPTest(t)

	t.Run("400 - invalid UUID", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/content-categories/bad", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPContentCategoryFullCRUD(t *testing.T) {
	t.Log("=== Scenario: ContentCategory Full CRUD via HTTP ===")

	r := setupCategoryHTTPTest(t)

	// Create
	body := map[string]interface{}{"name": "Sports", "slug": "sports"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/content-categories", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	// List
	req = httptest.NewRequest(http.MethodGet, "/api/v1/content-categories", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)

	var resp map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &resp)
	data := resp["data"].(map[string]interface{})
	items := data["items"].([]interface{})
	require.Len(t, items, 1)
	catID := items[0].(map[string]interface{})["id"].(string)

	// Update
	updateBody := map[string]interface{}{"name": "Updated Sports", "slug": "updated-sports"}
	b, _ = json.Marshal(updateBody)
	req = httptest.NewRequest(http.MethodPut, "/api/v1/content-categories/"+catID, bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// Delete
	req = httptest.NewRequest(http.MethodDelete, "/api/v1/content-categories/"+catID, nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// List → empty
	req = httptest.NewRequest(http.MethodGet, "/api/v1/content-categories", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	json.Unmarshal(w.Body.Bytes(), &resp)
	data = resp["data"].(map[string]interface{})
	assert.Equal(t, float64(0), data["total"])

	t.Log("Result: ContentCategory CRUD flow verified")
	t.Log("Status: PASSED")
}

func TestHTTPContentCategoryDeleteNonExistent(t *testing.T) {
	r := setupCategoryHTTPTest(t)

	t.Run("500 - delete non-existent", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/content-categories/"+uuid.New().String(), nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - invalid UUID on delete", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/content-categories/invalid", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

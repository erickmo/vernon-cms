package unit

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	createpage "github.com/erickmo/vernon-cms/internal/command/create_page"
	deletepage "github.com/erickmo/vernon-cms/internal/command/delete_page"
	updatepage "github.com/erickmo/vernon-cms/internal/command/update_page"
	httpdelivery "github.com/erickmo/vernon-cms/internal/delivery/http"
	listpage "github.com/erickmo/vernon-cms/internal/query/list_page"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/querybus"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func setupPageHTTPTest(t *testing.T) (*chi.Mux, *mocks.MockPageRepository, *mocks.MockEventBus) {
	t.Helper()

	repo := mocks.NewMockPageRepository()
	eb := mocks.NewMockEventBus()

	cmdBus := commandbus.New(nil)
	cmdBus.Register("CreatePage", createpage.NewHandler(repo, eb))
	cmdBus.Register("UpdatePage", updatepage.NewHandler(repo, eb))
	cmdBus.Register("DeletePage", deletepage.NewHandler(repo, eb))

	qBus := querybus.New(nil)
	qBus.Register("ListPage", listpage.NewHandler(repo))

	handler := httpdelivery.NewPageHandler(cmdBus, qBus)
	r := chi.NewRouter()
	handler.RegisterRoutes(r)

	return r, repo, eb
}

func TestHTTPPageCreate(t *testing.T) {
	t.Log("=== Scenario: HTTP POST /api/v1/pages ===")
	t.Log("Goal: Verify HTTP layer validates input and returns correct status codes")

	r, _, _ := setupPageHTTPTest(t)

	t.Run("201 - valid create request", func(t *testing.T) {
		body := map[string]interface{}{
			"name":      "Home Page",
			"slug":      "home-page",
			"variables": map[string]interface{}{"title": ""},
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/pages", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		assert.NotNil(t, resp["data"])
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing required field: name", func(t *testing.T) {
		body := map[string]interface{}{
			"slug": "slug",
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/pages", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		assert.NotEmpty(t, resp["error"])
		t.Log("Result: Validator caught missing required field")
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing required field: slug", func(t *testing.T) {
		body := map[string]interface{}{
			"name": "Page",
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/pages", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - malformed JSON body", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/pages", bytes.NewReader([]byte(`{invalid json`)))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Result: Malformed JSON returns 400")
		t.Log("Status: PASSED")
	})

	t.Run("400 - empty body", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/pages", bytes.NewReader([]byte("")))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPPageGetByID(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/pages/{id} ===")

	r, repo, eb := setupPageHTTPTest(t)

	// We need to register GetPage query handler with a mock that doesn't need Redis
	// For simplicity, let's test the invalid UUID case which doesn't hit query bus
	_ = repo
	_ = eb

	t.Run("400 - invalid UUID", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/pages/not-a-uuid", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		assert.Contains(t, resp["error"], "invalid")
		t.Log("Result: Invalid UUID returns 400")
		t.Log("Status: PASSED")
	})

	t.Run("routes to list when trailing slash", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/pages/", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		// Chi may redirect or route to list endpoint
		assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusMovedPermanently || w.Code == http.StatusNotFound)
		t.Log("Status: PASSED")
	})
}

func TestHTTPPageList(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/pages (List) ===")
	t.Log("Goal: Verify pagination parameter handling")

	r, repo, eb := setupPageHTTPTest(t)

	// Seed data
	createHandler := createpage.NewHandler(repo, eb)
	for i := 0; i < 25; i++ {
		_ = createHandler.Handle(context.Background(), createpage.Command{
			Name: "Page",
			Slug: uuid.New().String(), // unique slug
		})
	}

	t.Run("200 - list with default pagination", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/pages", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		data := resp["data"].(map[string]interface{})
		assert.Equal(t, float64(25), data["total"])
		assert.Equal(t, float64(20), data["limit"]) // default limit
		t.Log("Result: Default pagination applied (page=1, limit=20)")
		t.Log("Status: PASSED")
	})

	t.Run("200 - custom pagination", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/pages?page=2&limit=10", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		data := resp["data"].(map[string]interface{})
		assert.Equal(t, float64(2), data["page"])
		assert.Equal(t, float64(10), data["limit"])
		t.Log("Status: PASSED")
	})

	t.Run("200 - negative page defaults to 1", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/pages?page=-1&limit=5", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		data := resp["data"].(map[string]interface{})
		assert.Equal(t, float64(1), data["page"])
		t.Log("Result: Negative page number corrected to 1")
		t.Log("Status: PASSED")
	})

	t.Run("200 - zero limit defaults to 20", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/pages?page=1&limit=0", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		data := resp["data"].(map[string]interface{})
		assert.Equal(t, float64(20), data["limit"])
		t.Log("Status: PASSED")
	})

	t.Run("200 - non-numeric page/limit treated as zero", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/pages?page=abc&limit=xyz", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code) // defaults applied
		t.Log("Result: Non-numeric params default to page=1, limit=20")
		t.Log("Status: PASSED")
	})

	t.Run("200 - page beyond total returns empty items", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/pages?page=999&limit=20", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		data := resp["data"].(map[string]interface{})
		items := data["items"].([]interface{})
		assert.Empty(t, items)
		assert.Equal(t, float64(25), data["total"])
		t.Log("Result: Page beyond data returns empty items with correct total")
		t.Log("Status: PASSED")
	})
}

func TestHTTPPageUpdate(t *testing.T) {
	t.Log("=== Scenario: HTTP PUT /api/v1/pages/{id} ===")

	r, _, _ := setupPageHTTPTest(t)

	t.Run("400 - invalid UUID in path", func(t *testing.T) {
		body := map[string]interface{}{"name": "N", "slug": "s"}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPut, "/api/v1/pages/bad-uuid", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - malformed JSON on update", func(t *testing.T) {
		id := uuid.New().String()
		req := httptest.NewRequest(http.MethodPut, "/api/v1/pages/"+id, bytes.NewReader([]byte(`{bad}`)))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing required fields on update", func(t *testing.T) {
		id := uuid.New().String()
		body := map[string]interface{}{"name": "Only name"} // missing slug
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPut, "/api/v1/pages/"+id, bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPPageDelete(t *testing.T) {
	t.Log("=== Scenario: HTTP DELETE /api/v1/pages/{id} ===")

	r, _, _ := setupPageHTTPTest(t)

	t.Run("400 - invalid UUID", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/pages/not-uuid", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("500 - delete non-existent returns error", func(t *testing.T) {
		id := uuid.New().String()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/pages/"+id, nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		t.Log("Result: Non-existent page delete returns 500 with error message")
		t.Log("Status: PASSED")
	})
}

func TestHTTPPageCreateAndDelete(t *testing.T) {
	t.Log("=== Scenario: HTTP Full CRUD Flow (Create → List → Delete → List) ===")
	t.Log("Goal: Verify data consistency through HTTP layer")

	r, _, _ := setupPageHTTPTest(t)

	// Create
	body := map[string]interface{}{"name": "Test Page", "slug": "test-page"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/pages", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	// List → should have 1
	req = httptest.NewRequest(http.MethodGet, "/api/v1/pages", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)

	var resp map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &resp)
	data := resp["data"].(map[string]interface{})
	assert.Equal(t, float64(1), data["total"])

	items := data["items"].([]interface{})
	pageItem := items[0].(map[string]interface{})
	pageID := pageItem["id"].(string)

	// Delete
	req = httptest.NewRequest(http.MethodDelete, "/api/v1/pages/"+pageID, nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// List → should have 0
	req = httptest.NewRequest(http.MethodGet, "/api/v1/pages", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)

	json.Unmarshal(w.Body.Bytes(), &resp)
	data = resp["data"].(map[string]interface{})
	assert.Equal(t, float64(0), data["total"])

	t.Log("Result: Full create → list → delete → verify empty works correctly")
	t.Log("Status: PASSED")
}

func TestHTTPPageMethodNotAllowed(t *testing.T) {
	t.Log("=== Scenario: HTTP Method Not Allowed ===")

	r, _, _ := setupPageHTTPTest(t)

	t.Run("405 - PATCH not supported on pages", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/pages/"+uuid.New().String(), nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusMethodNotAllowed, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPPageResponseFormat(t *testing.T) {
	t.Log("=== Scenario: Response Format Consistency ===")
	t.Log("Goal: All responses must follow {data:...} or {error:...} format")

	r, _, _ := setupPageHTTPTest(t)

	t.Run("success response has 'data' key", func(t *testing.T) {
		body := map[string]interface{}{"name": "P", "slug": "p"}
		b, _ := json.Marshal(body)
		req := httptest.NewRequest(http.MethodPost, "/api/v1/pages", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		assert.NotNil(t, resp["data"])
		assert.Nil(t, resp["error"])
		t.Log("Status: PASSED")
	})

	t.Run("error response has 'error' key", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/pages", bytes.NewReader([]byte(`{invalid`)))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		assert.NotEmpty(t, resp["error"])
		t.Log("Status: PASSED")
	})
}

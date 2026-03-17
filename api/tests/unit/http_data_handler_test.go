package unit

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/go-chi/chi/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	createdata "github.com/erickmo/vernon-cms/internal/command/create_data"
	createdatarecord "github.com/erickmo/vernon-cms/internal/command/create_data_record"
	deletedata "github.com/erickmo/vernon-cms/internal/command/delete_data"
	deletedatarecord "github.com/erickmo/vernon-cms/internal/command/delete_data_record"
	updatedata "github.com/erickmo/vernon-cms/internal/command/update_data"
	updatedatarecord "github.com/erickmo/vernon-cms/internal/command/update_data_record"
	httpdelivery "github.com/erickmo/vernon-cms/internal/delivery/http"
	getdata "github.com/erickmo/vernon-cms/internal/query/get_data"
	getdatarecord "github.com/erickmo/vernon-cms/internal/query/get_data_record"
	listdata "github.com/erickmo/vernon-cms/internal/query/list_data"
	listdatarecord "github.com/erickmo/vernon-cms/internal/query/list_data_record"
	listdatarecordoptions "github.com/erickmo/vernon-cms/internal/query/list_data_record_options"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/querybus"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func setupDataHTTPTest(t *testing.T) (*chi.Mux, *mocks.MockDataRepository) {
	t.Helper()

	repo := mocks.NewMockDataRepository()
	eb := mocks.NewMockEventBus()

	cmdBus := commandbus.New(nil)
	cmdBus.Register("CreateData", createdata.NewHandler(repo, eb))
	cmdBus.Register("UpdateData", updatedata.NewHandler(repo, eb))
	cmdBus.Register("DeleteData", deletedata.NewHandler(repo, eb))
	cmdBus.Register("CreateDataRecord", createdatarecord.NewHandler(repo, eb))
	cmdBus.Register("UpdateDataRecord", updatedatarecord.NewHandler(repo, eb))
	cmdBus.Register("DeleteDataRecord", deletedatarecord.NewHandler(repo, eb))

	qBus := querybus.New(nil)
	qBus.Register("ListData", listdata.NewHandler(repo))
	qBus.Register("GetData", getdata.NewHandler(repo))
	qBus.Register("ListDataRecord", listdatarecord.NewHandler(repo))
	qBus.Register("GetDataRecord", getdatarecord.NewHandler(repo))
	qBus.Register("ListDataRecordOptions", listdatarecordoptions.NewHandler(repo))

	handler := httpdelivery.NewDataHandler(cmdBus, qBus)
	r := chi.NewRouter()

	r.Route("/api/v1/data", func(r chi.Router) {
		r.Get("/", handler.ListDataTypes)
		r.Get("/{id}", handler.GetDataType)
		r.Post("/", handler.CreateDataType)
		r.Put("/{id}", handler.UpdateDataType)
		r.Delete("/{id}", handler.DeleteDataType)

		r.Route("/{data_slug}/records", func(r chi.Router) {
			r.Get("/", handler.ListRecords)
			r.Get("/options", handler.ListRecordOptions)
			r.Get("/{id}", handler.GetRecord)
			r.Post("/", handler.CreateRecord)
			r.Put("/{id}", handler.UpdateRecord)
			r.Delete("/{id}", handler.DeleteRecord)
		})
	})

	return r, repo
}

// --- Data Type CRUD Tests ---

func TestHTTPDataCreate(t *testing.T) {
	t.Log("=== Scenario: HTTP POST /api/v1/data ===")

	r, _ := setupDataHTTPTest(t)

	t.Run("201 - valid create without fields", func(t *testing.T) {
		body := map[string]interface{}{
			"name":        "Article",
			"slug":        "article",
			"plural_name": "Articles",
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("201 - valid create with fields", func(t *testing.T) {
		body := map[string]interface{}{
			"name":        "Product",
			"slug":        "product",
			"plural_name": "Products",
			"fields": []map[string]interface{}{
				{"name": "title", "label": "Title", "field_type": "text", "is_required": true, "sort_order": 1},
				{"name": "price", "label": "Price", "field_type": "number", "sort_order": 2},
			},
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing required fields", func(t *testing.T) {
		body := map[string]interface{}{
			"name": "Only Name",
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - malformed JSON", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader([]byte(`{bad`)))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPDataList(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/data ===")

	r, _ := setupDataHTTPTest(t)

	t.Run("200 - empty list", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/data", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		d := resp["data"].(map[string]interface{})
		assert.Equal(t, float64(0), d["total"])
		t.Log("Status: PASSED")
	})

	t.Run("200 - list after create", func(t *testing.T) {
		body := map[string]interface{}{"name": "Blog", "slug": "blog-list", "plural_name": "Blogs"}
		b, _ := json.Marshal(body)
		req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		require.Equal(t, http.StatusCreated, w.Code)

		req = httptest.NewRequest(http.MethodGet, "/api/v1/data", nil)
		w = httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		d := resp["data"].(map[string]interface{})
		assert.GreaterOrEqual(t, d["total"].(float64), float64(1))
		t.Log("Status: PASSED")
	})
}

func TestHTTPDataGetByID(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/data/{id} ===")

	r, _ := setupDataHTTPTest(t)

	t.Run("400 - invalid UUID", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/data/bad-uuid", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("404 - data type not found", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/data/00000000-0000-0000-0000-000000000001", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPDataDelete(t *testing.T) {
	t.Log("=== Scenario: HTTP DELETE /api/v1/data/{id} ===")

	r, _ := setupDataHTTPTest(t)

	t.Run("400 - invalid UUID", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/data/not-uuid", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPDataFullCRUD(t *testing.T) {
	t.Log("=== Scenario: Data Type Full CRUD via HTTP ===")

	r, _ := setupDataHTTPTest(t)

	// Create
	body := map[string]interface{}{
		"name":            "Gallery",
		"slug":            "gallery",
		"plural_name":     "Galleries",
		"sidebar_section": "media",
		"sidebar_order":   5,
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	// List and get ID
	req = httptest.NewRequest(http.MethodGet, "/api/v1/data", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusOK, w.Code)

	var listResp map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &listResp)
	d := listResp["data"].(map[string]interface{})
	items := d["items"].([]interface{})
	require.Len(t, items, 1)
	dataTypeID := items[0].(map[string]interface{})["id"].(string)

	// Get by ID
	req = httptest.NewRequest(http.MethodGet, "/api/v1/data/"+dataTypeID, nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// Update
	updateBody := map[string]interface{}{
		"name":        "Gallery Updated",
		"slug":        "gallery-updated",
		"plural_name": "Galleries Updated",
	}
	b, _ = json.Marshal(updateBody)
	req = httptest.NewRequest(http.MethodPut, "/api/v1/data/"+dataTypeID, bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// Delete
	req = httptest.NewRequest(http.MethodDelete, "/api/v1/data/"+dataTypeID, nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// List → empty
	req = httptest.NewRequest(http.MethodGet, "/api/v1/data", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	json.Unmarshal(w.Body.Bytes(), &listResp)
	d = listResp["data"].(map[string]interface{})
	assert.Equal(t, float64(0), d["total"])

	t.Log("Result: Data Type CRUD flow verified end-to-end")
	t.Log("Status: PASSED")
}

// --- Data Record Tests ---

func TestHTTPDataRecordCreate(t *testing.T) {
	t.Log("=== Scenario: HTTP POST /api/v1/data/{data_slug}/records ===")

	r, _ := setupDataHTTPTest(t)

	// Setup data type first
	b, _ := json.Marshal(map[string]interface{}{
		"name": "Post", "slug": "post", "plural_name": "Posts",
	})
	req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	t.Run("201 - valid record create", func(t *testing.T) {
		body := map[string]interface{}{
			"data": map[string]interface{}{"title": "Hello World", "body": "Content here"},
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/data/post/records", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - malformed JSON", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/data/post/records", bytes.NewReader([]byte(`{bad`)))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("500 - data type not found for record", func(t *testing.T) {
		body := map[string]interface{}{
			"data": map[string]interface{}{"title": "test"},
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/data/nonexistent/records", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		t.Log("Result: 500 returned when data_slug not found")
		t.Log("Status: PASSED")
	})
}

func TestHTTPDataRecordList(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/data/{data_slug}/records ===")

	r, _ := setupDataHTTPTest(t)

	// Setup data type
	b, _ := json.Marshal(map[string]interface{}{"name": "Event", "slug": "event", "plural_name": "Events"})
	req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	// Create record
	b, _ = json.Marshal(map[string]interface{}{"data": map[string]interface{}{"name": "Event 1"}})
	req = httptest.NewRequest(http.MethodPost, "/api/v1/data/event/records", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	t.Run("200 - list records", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/data/event/records", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		d := resp["data"].(map[string]interface{})
		assert.Equal(t, float64(1), d["total"])
		t.Log("Status: PASSED")
	})

	t.Run("200 - list with search", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/data/event/records?search=Event+1", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPDataRecordGetByID(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/data/{data_slug}/records/{id} ===")

	r, _ := setupDataHTTPTest(t)

	t.Run("400 - invalid UUID", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/data/post/records/bad-uuid", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("404 - record not found", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/data/post/records/00000000-0000-0000-0000-000000000001", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPDataRecordFullCRUD(t *testing.T) {
	t.Log("=== Scenario: Data Record Full CRUD via HTTP ===")

	r, _ := setupDataHTTPTest(t)

	// Create data type
	b, _ := json.Marshal(map[string]interface{}{"name": "FAQ", "slug": "faq", "plural_name": "FAQs"})
	req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	// Create record
	b, _ = json.Marshal(map[string]interface{}{"data": map[string]interface{}{"question": "What is CMS?", "answer": "Content Management System"}})
	req = httptest.NewRequest(http.MethodPost, "/api/v1/data/faq/records", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	// List records
	req = httptest.NewRequest(http.MethodGet, "/api/v1/data/faq/records", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusOK, w.Code)

	var listResp map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &listResp)
	d := listResp["data"].(map[string]interface{})
	items := d["items"].([]interface{})
	require.Len(t, items, 1)
	recordID := items[0].(map[string]interface{})["id"].(string)

	// Get by ID
	req = httptest.NewRequest(http.MethodGet, "/api/v1/data/faq/records/"+recordID, nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// Update record
	b, _ = json.Marshal(map[string]interface{}{"data": map[string]interface{}{"question": "Updated Q?", "answer": "Updated A"}})
	req = httptest.NewRequest(http.MethodPut, "/api/v1/data/faq/records/"+recordID, bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// Delete record
	req = httptest.NewRequest(http.MethodDelete, "/api/v1/data/faq/records/"+recordID, nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// List → empty
	req = httptest.NewRequest(http.MethodGet, "/api/v1/data/faq/records", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	json.Unmarshal(w.Body.Bytes(), &listResp)
	d = listResp["data"].(map[string]interface{})
	assert.Equal(t, float64(0), d["total"])

	t.Log("Result: Data Record CRUD flow verified end-to-end")
	t.Log("Status: PASSED")
}

func TestHTTPDataRecordOptions(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/data/{data_slug}/records/options ===")

	r, _ := setupDataHTTPTest(t)

	// Create data type and records
	b, _ := json.Marshal(map[string]interface{}{"name": "Category", "slug": "category", "plural_name": "Categories"})
	req := httptest.NewRequest(http.MethodPost, "/api/v1/data", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	b, _ = json.Marshal(map[string]interface{}{"data": map[string]interface{}{"name": "Tech"}})
	req = httptest.NewRequest(http.MethodPost, "/api/v1/data/category/records", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	t.Run("200 - returns options", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/data/category/records/options", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		options := resp["data"].([]interface{})
		assert.Len(t, options, 1)
		t.Log("Result: 1 record option returned")
		t.Log("Status: PASSED")
	})
}

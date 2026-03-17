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

	createuser "github.com/erickmo/vernon-cms/internal/command/create_user"
	deleteuser "github.com/erickmo/vernon-cms/internal/command/delete_user"
	updateuser "github.com/erickmo/vernon-cms/internal/command/update_user"
	httpdelivery "github.com/erickmo/vernon-cms/internal/delivery/http"
	listuser "github.com/erickmo/vernon-cms/internal/query/list_user"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/querybus"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func setupUserHTTPTest(t *testing.T) *chi.Mux {
	t.Helper()

	repo := mocks.NewMockUserRepository()
	eb := mocks.NewMockEventBus()

	cmdBus := commandbus.New(nil)
	cmdBus.Register("CreateUser", createuser.NewHandler(repo, eb))
	cmdBus.Register("UpdateUser", updateuser.NewHandler(repo, eb))
	cmdBus.Register("DeleteUser", deleteuser.NewHandler(repo, eb))

	qBus := querybus.New(nil)
	qBus.Register("ListUser", listuser.NewHandler(repo))

	handler := httpdelivery.NewUserHandler(cmdBus, qBus)
	r := chi.NewRouter()
	handler.RegisterRoutes(r)

	return r
}

func TestHTTPUserCreate(t *testing.T) {
	t.Log("=== Scenario: HTTP POST /api/v1/users ===")

	r := setupUserHTTPTest(t)

	t.Run("201 - valid create", func(t *testing.T) {
		body := map[string]interface{}{
			"email":         "john@example.com",
			"password_hash": "hashed_pw",
			"name":          "John Doe",
			"role":          "editor",
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/users", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing email", func(t *testing.T) {
		body := map[string]interface{}{
			"password_hash": "hash",
			"name":          "Name",
			"role":          "admin",
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/users", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - invalid email format", func(t *testing.T) {
		body := map[string]interface{}{
			"email":         "not-an-email",
			"password_hash": "hash",
			"name":          "Name",
			"role":          "admin",
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/users", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Result: Invalid email format caught by validator")
		t.Log("Status: PASSED")
	})

	t.Run("400 - invalid role", func(t *testing.T) {
		body := map[string]interface{}{
			"email":         "test@test.com",
			"password_hash": "hash",
			"name":          "Name",
			"role":          "superadmin", // not in oneof
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/users", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Result: Invalid role caught by oneof validator")
		t.Log("Status: PASSED")
	})

	t.Run("400 - missing password_hash", func(t *testing.T) {
		body := map[string]interface{}{
			"email": "test@test.com",
			"name":  "Name",
			"role":  "admin",
		}
		b, _ := json.Marshal(body)

		req := httptest.NewRequest(http.MethodPost, "/api/v1/users", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("400 - malformed JSON", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/users", bytes.NewReader([]byte(`{bad`)))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPUserGetByID(t *testing.T) {
	t.Log("=== Scenario: HTTP GET /api/v1/users/{id} ===")

	r := setupUserHTTPTest(t)

	t.Run("400 - invalid UUID", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/users/bad-uuid", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestHTTPUserFullCRUD(t *testing.T) {
	t.Log("=== Scenario: User Full CRUD via HTTP ===")

	r := setupUserHTTPTest(t)

	// Create
	body := map[string]interface{}{
		"email": "crud@test.com", "password_hash": "hash", "name": "CRUD User", "role": "admin",
	}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/users", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	require.Equal(t, http.StatusCreated, w.Code)

	// List
	req = httptest.NewRequest(http.MethodGet, "/api/v1/users", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)

	var resp map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &resp)
	data := resp["data"].(map[string]interface{})
	items := data["items"].([]interface{})
	require.Len(t, items, 1)
	userID := items[0].(map[string]interface{})["id"].(string)

	// Update
	updateBody := map[string]interface{}{
		"email": "updated@test.com", "name": "Updated", "role": "editor",
	}
	b, _ = json.Marshal(updateBody)
	req = httptest.NewRequest(http.MethodPut, "/api/v1/users/"+userID, bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// Delete
	req = httptest.NewRequest(http.MethodDelete, "/api/v1/users/"+userID, nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)

	// List → should be empty
	req = httptest.NewRequest(http.MethodGet, "/api/v1/users", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	json.Unmarshal(w.Body.Bytes(), &resp)
	data = resp["data"].(map[string]interface{})
	assert.Equal(t, float64(0), data["total"])

	t.Log("Result: User CRUD flow verified end-to-end")
	t.Log("Status: PASSED")
}

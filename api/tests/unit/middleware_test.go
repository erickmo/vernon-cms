package unit

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/erickmo/vernon-cms/pkg/middleware"
)

func TestRecoveryMiddleware(t *testing.T) {
	t.Log("=== Scenario: Recovery Middleware ===")
	t.Log("Goal: Verify panic recovery returns 500 instead of crashing")

	t.Run("recovers from panic", func(t *testing.T) {
		handler := middleware.Recovery(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			panic("unexpected panic!")
		}))

		req := httptest.NewRequest(http.MethodGet, "/", nil)
		w := httptest.NewRecorder()

		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		assert.Contains(t, w.Body.String(), "internal server error")
		t.Log("Result: Panic caught, 500 returned instead of crash")
		t.Log("Status: PASSED")
	})

	t.Run("normal request passes through", func(t *testing.T) {
		handler := middleware.Recovery(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
			w.Write([]byte("ok"))
		}))

		req := httptest.NewRequest(http.MethodGet, "/", nil)
		w := httptest.NewRecorder()

		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Equal(t, "ok", w.Body.String())
		t.Log("Status: PASSED")
	})
}

func TestCORSMiddleware(t *testing.T) {
	t.Log("=== Scenario: CORS Middleware ===")
	t.Log("Goal: Verify CORS headers are set and preflight handled")

	t.Run("sets CORS headers", func(t *testing.T) {
		handler := middleware.CORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
		}))

		req := httptest.NewRequest(http.MethodGet, "/", nil)
		w := httptest.NewRecorder()

		handler.ServeHTTP(w, req)

		assert.Equal(t, "*", w.Header().Get("Access-Control-Allow-Origin"))
		assert.Contains(t, w.Header().Get("Access-Control-Allow-Methods"), "GET")
		assert.Contains(t, w.Header().Get("Access-Control-Allow-Methods"), "POST")
		assert.Contains(t, w.Header().Get("Access-Control-Allow-Methods"), "PUT")
		assert.Contains(t, w.Header().Get("Access-Control-Allow-Methods"), "DELETE")
		t.Log("Status: PASSED")
	})

	t.Run("OPTIONS preflight returns 204", func(t *testing.T) {
		handler := middleware.CORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
		}))

		req := httptest.NewRequest(http.MethodOptions, "/api/v1/pages", nil)
		w := httptest.NewRecorder()

		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
		t.Log("Result: OPTIONS preflight returns 204 No Content")
		t.Log("Status: PASSED")
	})
}

func TestLoggingMiddleware(t *testing.T) {
	t.Log("=== Scenario: Logging Middleware ===")
	t.Log("Goal: Verify request passes through with logging context")

	handler := middleware.Logging(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	}))

	req := httptest.NewRequest(http.MethodGet, "/test", nil)
	w := httptest.NewRecorder()

	handler.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	t.Log("Result: Request processed with logging middleware")
	t.Log("Status: PASSED")
}

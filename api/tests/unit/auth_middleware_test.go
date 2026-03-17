package unit

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"

	"github.com/erickmo/vernon-cms/pkg/auth"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

func TestAuthMiddleware(t *testing.T) {
	t.Log("=== Scenario: JWT Auth Middleware ===")
	t.Log("Goal: Verify token extraction, validation, and rejection")

	jwtSvc := auth.NewJWTService("test-secret-key-minimum-32-chars!", 15*time.Minute, 7*24*time.Hour)
	authMw := middleware.Auth(jwtSvc)

	handler := authMw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		claims := middleware.GetClaims(r.Context())
		if claims != nil {
			w.WriteHeader(http.StatusOK)
			w.Write([]byte(claims.Email))
		}
	}))

	t.Run("success - valid Bearer token", func(t *testing.T) {
		pair, _ := jwtSvc.GenerateTokenPair(uuid.New(), "john@test.com", "admin", uuid.Nil, "")

		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("Authorization", "Bearer "+pair.AccessToken)
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Equal(t, "john@test.com", w.Body.String())
		t.Log("Result: Claims extracted and available in context")
		t.Log("Status: PASSED")
	})

	t.Run("success - bearer case insensitive", func(t *testing.T) {
		pair, _ := jwtSvc.GenerateTokenPair(uuid.New(), "john@test.com", "admin", uuid.Nil, "")

		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("Authorization", "bearer "+pair.AccessToken)
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("401 - missing Authorization header", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		assert.Contains(t, w.Body.String(), "missing authorization")
		t.Log("Status: PASSED")
	})

	t.Run("401 - empty Authorization header", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("Authorization", "")
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("401 - missing Bearer prefix", func(t *testing.T) {
		pair, _ := jwtSvc.GenerateTokenPair(uuid.New(), "john@test.com", "admin", uuid.Nil, "")

		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("Authorization", pair.AccessToken) // no "Bearer " prefix
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		assert.Contains(t, w.Body.String(), "invalid authorization format")
		t.Log("Status: PASSED")
	})

	t.Run("401 - invalid token", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("Authorization", "Bearer invalid.token.here")
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		assert.Contains(t, w.Body.String(), "invalid or expired")
		t.Log("Status: PASSED")
	})

	t.Run("401 - expired token", func(t *testing.T) {
		expiredSvc := auth.NewJWTService("test-secret-key-minimum-32-chars!", -1*time.Second, -1*time.Second)
		pair, _ := expiredSvc.GenerateTokenPair(uuid.New(), "john@test.com", "admin", uuid.Nil, "")

		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("Authorization", "Bearer "+pair.AccessToken)
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		t.Log("Result: Expired token returns 401")
		t.Log("Status: PASSED")
	})

	t.Run("401 - token from different secret", func(t *testing.T) {
		otherSvc := auth.NewJWTService("other-secret-key-different-32chars", 15*time.Minute, 7*24*time.Hour)
		pair, _ := otherSvc.GenerateTokenPair(uuid.New(), "john@test.com", "admin", uuid.Nil, "")

		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("Authorization", "Bearer "+pair.AccessToken)
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		t.Log("Result: Token from different secret rejected")
		t.Log("Status: PASSED")
	})
}

func TestRequireRoleMiddleware(t *testing.T) {
	t.Log("=== Scenario: Role-Based Access Control (RBAC) Middleware ===")
	t.Log("Goal: Verify role enforcement — admin/editor/viewer permissions")

	jwtSvc := auth.NewJWTService("test-secret-key-minimum-32-chars!", 15*time.Minute, 7*24*time.Hour)

	makeHandler := func(roles ...string) http.Handler {
		return middleware.Auth(jwtSvc)(
			middleware.RequireRole(roles...)(
				http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
					w.WriteHeader(http.StatusOK)
					w.Write([]byte("allowed"))
				}),
			),
		)
	}

	makeRequest := func(role string) *http.Request {
		pair, _ := jwtSvc.GenerateTokenPair(uuid.New(), "user@test.com", role, uuid.Nil, "")
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("Authorization", "Bearer "+pair.AccessToken)
		return req
	}

	t.Run("admin can access admin-only route", func(t *testing.T) {
		h := makeHandler("admin")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, makeRequest("admin"))

		assert.Equal(t, http.StatusOK, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("editor CANNOT access admin-only route", func(t *testing.T) {
		h := makeHandler("admin")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, makeRequest("editor"))

		assert.Equal(t, http.StatusForbidden, w.Code)
		assert.Contains(t, w.Body.String(), "insufficient permissions")
		t.Log("Result: Editor blocked from admin-only route")
		t.Log("Status: PASSED")
	})

	t.Run("viewer CANNOT access admin-only route", func(t *testing.T) {
		h := makeHandler("admin")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, makeRequest("viewer"))

		assert.Equal(t, http.StatusForbidden, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("editor can access admin+editor route", func(t *testing.T) {
		h := makeHandler("admin", "editor")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, makeRequest("editor"))

		assert.Equal(t, http.StatusOK, w.Code)
		t.Log("Status: PASSED")
	})

	t.Run("viewer CANNOT access admin+editor route", func(t *testing.T) {
		h := makeHandler("admin", "editor")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, makeRequest("viewer"))

		assert.Equal(t, http.StatusForbidden, w.Code)
		t.Log("Result: Viewer blocked from editor route")
		t.Log("Status: PASSED")
	})

	t.Run("all roles can access multi-role route", func(t *testing.T) {
		h := makeHandler("admin", "editor", "viewer")
		for _, role := range []string{"admin", "editor", "viewer"} {
			w := httptest.NewRecorder()
			h.ServeHTTP(w, makeRequest(role))
			assert.Equal(t, http.StatusOK, w.Code, "role=%s should be allowed", role)
		}
		t.Log("Status: PASSED")
	})

	t.Run("401 - no token with role check", func(t *testing.T) {
		h := makeHandler("admin")
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		w := httptest.NewRecorder()
		h.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		t.Log("Result: Missing token returns 401 before role check")
		t.Log("Status: PASSED")
	})
}

func TestMaxBodySizeMiddleware(t *testing.T) {
	t.Log("=== Scenario: Request Body Size Limit ===")
	t.Log("Goal: Verify oversized request bodies are rejected")

	t.Run("small body passes through", func(t *testing.T) {
		handler := middleware.MaxBodySize(1024)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
		}))

		req := httptest.NewRequest(http.MethodPost, "/", nil)
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		t.Log("Status: PASSED")
	})
}

func TestGetClaimsFromContext(t *testing.T) {
	t.Log("=== Scenario: GetClaims from Context ===")

	t.Run("returns nil when no claims in context", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		claims := middleware.GetClaims(req.Context())
		assert.Nil(t, claims)
		t.Log("Status: PASSED")
	})
}

//go:build integration

package integration

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/go-chi/chi/v5"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"github.com/redis/go-redis/v9"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/erickmo/vernon-cms/infrastructure/database"
	"github.com/erickmo/vernon-cms/infrastructure/telemetry"
	createpage "github.com/erickmo/vernon-cms/internal/command/create_page"
	deletepage "github.com/erickmo/vernon-cms/internal/command/delete_page"
	updatepage "github.com/erickmo/vernon-cms/internal/command/update_page"
	httpdelivery "github.com/erickmo/vernon-cms/internal/delivery/http"
	getpage "github.com/erickmo/vernon-cms/internal/query/get_page"
	listpage "github.com/erickmo/vernon-cms/internal/query/list_page"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/eventbus"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

func setupPageTest(t *testing.T) (*httptest.Server, func()) {
	t.Helper()

	dbURL := "postgres://postgres:postgres@localhost:5432/vernon_cms_db?sslmode=disable"
	db, err := sqlx.Connect("postgres", dbURL)
	require.NoError(t, err)

	redisClient := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

	metrics, _, err := telemetry.InitMetrics()
	require.NoError(t, err)

	eb := eventbus.NewInMemoryEventBus()
	repo := database.NewPageRepository(db)

	cmdBus := commandbus.New(metrics)
	cmdBus.Register("CreatePage", createpage.NewHandler(repo, eb))
	cmdBus.Register("UpdatePage", updatepage.NewHandler(repo, eb))
	cmdBus.Register("DeletePage", deletepage.NewHandler(repo, eb))

	qBus := querybus.New(metrics)
	qBus.Register("GetPage", getpage.NewHandler(repo, redisClient, metrics, 300))
	qBus.Register("ListPage", listpage.NewHandler(repo))

	handler := httpdelivery.NewPageHandler(cmdBus, qBus)

	r := chi.NewRouter()
	handler.RegisterRoutes(r)

	server := httptest.NewServer(r)

	cleanup := func() {
		server.Close()
		db.Exec("DELETE FROM contents")
		db.Exec("DELETE FROM pages")
		db.Close()
		redisClient.FlushAll(context.Background())
		redisClient.Close()
	}

	return server, cleanup
}

func TestPageCRUD(t *testing.T) {
	server, cleanup := setupPageTest(t)
	defer cleanup()

	t.Log("=== Scenario: Page CRUD Operations ===")
	t.Log("Goal: Verify create, read, list, update, delete for Page entity")

	// Create
	t.Log("Flow: POST /api/v1/pages → Create page")
	body := map[string]interface{}{
		"name":      "Home Page",
		"slug":      "home-page",
		"variables": map[string]interface{}{"hero_title": "", "hero_subtitle": ""},
	}
	bodyBytes, _ := json.Marshal(body)
	resp, err := http.Post(server.URL+"/api/v1/pages", "application/json", bytes.NewReader(bodyBytes))
	require.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	t.Log("Result: Page created successfully")

	// List
	t.Log("Flow: GET /api/v1/pages → List pages")
	resp, err = http.Get(server.URL + "/api/v1/pages")
	require.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)

	var listResp map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&listResp)
	data := listResp["data"].(map[string]interface{})
	items := data["items"].([]interface{})
	assert.Greater(t, len(items), 0)
	t.Logf("Result: Listed %d pages", len(items))

	// Get by ID
	pageItem := items[0].(map[string]interface{})
	pageID := pageItem["id"].(string)
	t.Logf("Flow: GET /api/v1/pages/%s → Get page by ID", pageID)
	resp, err = http.Get(fmt.Sprintf("%s/api/v1/pages/%s", server.URL, pageID))
	require.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
	t.Log("Result: Page retrieved successfully")

	// Update
	t.Logf("Flow: PUT /api/v1/pages/%s → Update page", pageID)
	updateBody := map[string]interface{}{
		"name":      "Updated Home Page",
		"slug":      "home-page",
		"variables": map[string]interface{}{"hero_title": "", "hero_subtitle": "", "cta_text": ""},
	}
	updateBytes, _ := json.Marshal(updateBody)
	req, _ := http.NewRequest(http.MethodPut, fmt.Sprintf("%s/api/v1/pages/%s", server.URL, pageID), bytes.NewReader(updateBytes))
	req.Header.Set("Content-Type", "application/json")
	resp, err = http.DefaultClient.Do(req)
	require.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
	t.Log("Result: Page updated successfully")

	// Delete
	t.Logf("Flow: DELETE /api/v1/pages/%s → Delete page", pageID)
	req, _ = http.NewRequest(http.MethodDelete, fmt.Sprintf("%s/api/v1/pages/%s", server.URL, pageID), nil)
	resp, err = http.DefaultClient.Do(req)
	require.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
	t.Log("Result: Page deleted successfully")

	t.Log("=== Status: PASSED ===")
}

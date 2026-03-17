package unit

import (
	"fmt"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	deletemedia "github.com/erickmo/vernon-cms/internal/command/delete_media"
	updatemedia "github.com/erickmo/vernon-cms/internal/command/update_media"
	uploadmedia "github.com/erickmo/vernon-cms/internal/command/upload_media"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func TestUploadMediaHandler(t *testing.T) {
	t.Log("=== Scenario: UploadMedia Command Handler ===")
	t.Log("Goal: Verify media file creation via command handler with context result injection")

	repo := mocks.NewMockMediaWriteRepository()
	handler := uploadmedia.NewHandler(repo)
	siteID := uuid.New()
	ctx := ctxWithSite(siteID)

	t.Run("success - uploads file and returns result via context", func(t *testing.T) {
		repo.Reset()

		cmd := uploadmedia.Command{
			FileName: "photo.jpg",
			FileURL:  "https://cdn.example.com/photo.jpg",
			MimeType: "image/jpeg",
			FileSize: 102400,
		}

		result := &uploadmedia.Result{}
		ctxWithResult := uploadmedia.WithResult(ctx, result)

		err := handler.Handle(ctxWithResult, cmd)

		require.NoError(t, err)
		assert.Equal(t, 1, repo.Count())
		require.NotNil(t, result.File)
		assert.Equal(t, "photo.jpg", result.File.FileName)
		assert.Equal(t, "https://cdn.example.com/photo.jpg", result.File.FileURL)
		assert.Equal(t, siteID, result.File.SiteID)
		assert.NotEqual(t, uuid.Nil, result.File.ID)
		t.Log("Result: Media file saved and returned via context result")
		t.Log("Status: PASSED")
	})

	t.Run("success - uploads with optional fields", func(t *testing.T) {
		repo.Reset()

		alt := "A beautiful photo"
		caption := "Photo caption"
		folder := "images/2026"
		w, h := 1920, 1080

		cmd := uploadmedia.Command{
			FileName: "landscape.jpg",
			FileURL:  "https://cdn.example.com/landscape.jpg",
			MimeType: "image/jpeg",
			FileSize: 512000,
			Width:    &w,
			Height:   &h,
			Alt:      &alt,
			Caption:  &caption,
			Folder:   &folder,
		}

		result := &uploadmedia.Result{}
		ctxWithResult := uploadmedia.WithResult(ctx, result)

		err := handler.Handle(ctxWithResult, cmd)

		require.NoError(t, err)
		require.NotNil(t, result.File)
		assert.Equal(t, &alt, result.File.Alt)
		assert.Equal(t, &caption, result.File.Caption)
		assert.Equal(t, &folder, result.File.Folder)
		assert.Equal(t, &w, result.File.Width)
		assert.Equal(t, &h, result.File.Height)
		t.Log("Result: Optional fields correctly set on media file")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty file name returns domain error", func(t *testing.T) {
		repo.Reset()

		cmd := uploadmedia.Command{
			FileName: "",
			FileURL:  "https://cdn.example.com/photo.jpg",
			MimeType: "image/jpeg",
		}

		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "file name is required")
		assert.Equal(t, 0, repo.Count())
		t.Log("Result: Domain validation rejects empty file name")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty file URL returns domain error", func(t *testing.T) {
		repo.Reset()

		cmd := uploadmedia.Command{
			FileName: "photo.jpg",
			FileURL:  "",
			MimeType: "image/jpeg",
		}

		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "file URL is required")
		assert.Equal(t, 0, repo.Count())
		t.Log("Result: Domain validation rejects empty file URL")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repository save error", func(t *testing.T) {
		repo.Reset()
		repo.SaveErr = fmt.Errorf("disk quota exceeded")

		cmd := uploadmedia.Command{
			FileName: "photo.jpg",
			FileURL:  "https://cdn.example.com/photo.jpg",
			MimeType: "image/jpeg",
		}

		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "disk quota exceeded")
		t.Log("Result: Repository error propagated correctly")
		t.Log("Status: PASSED")
	})

	t.Run("success - no result container in context (fire-and-forget)", func(t *testing.T) {
		repo.Reset()

		cmd := uploadmedia.Command{
			FileName: "doc.pdf",
			FileURL:  "https://cdn.example.com/doc.pdf",
			MimeType: "application/pdf",
		}

		err := handler.Handle(ctx, cmd) // ctx without result

		require.NoError(t, err)
		assert.Equal(t, 1, repo.Count())
		t.Log("Result: Handler works without result container — file still saved")
		t.Log("Status: PASSED")
	})
}

func TestUpdateMediaHandler(t *testing.T) {
	t.Log("=== Scenario: UpdateMedia Command Handler ===")
	t.Log("Goal: Verify media metadata update with not-found guard")

	repo := mocks.NewMockMediaWriteRepository()
	handler := updatemedia.NewHandler(repo)
	siteID := uuid.New()
	ctx := ctxWithSite(siteID)

	t.Run("success - updates alt, caption, folder", func(t *testing.T) {
		repo.Reset()

		// Seed a media file via upload handler
		uploadHandler := uploadmedia.NewHandler(repo)
		result := &uploadmedia.Result{}
		_ = uploadHandler.Handle(uploadmedia.WithResult(ctx, result), uploadmedia.Command{
			FileName: "photo.jpg",
			FileURL:  "https://cdn.example.com/photo.jpg",
			MimeType: "image/jpeg",
		})

		alt := "New alt text"
		caption := "New caption"
		folder := "gallery"

		cmd := updatemedia.Command{
			ID:      result.File.ID,
			Alt:     &alt,
			Caption: &caption,
			Folder:  &folder,
		}

		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		updated, _ := repo.FindByID(result.File.ID, siteID)
		require.NotNil(t, updated)
		assert.Equal(t, &alt, updated.Alt)
		assert.Equal(t, &caption, updated.Caption)
		assert.Equal(t, &folder, updated.Folder)
		t.Log("Result: Media metadata updated correctly")
		t.Log("Status: PASSED")
	})

	t.Run("fail - media not found", func(t *testing.T) {
		repo.Reset()

		cmd := updatemedia.Command{ID: uuid.New()}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Result: Not-found error when media ID doesn't exist")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repository update error", func(t *testing.T) {
		repo.Reset()
		repo.UpdateErr = fmt.Errorf("connection lost")

		uploadHandler := uploadmedia.NewHandler(repo)
		result := &uploadmedia.Result{}
		repo.UpdateErr = nil // allow save
		_ = uploadHandler.Handle(uploadmedia.WithResult(ctx, result), uploadmedia.Command{
			FileName: "photo.jpg",
			FileURL:  "https://cdn.example.com/photo.jpg",
			MimeType: "image/jpeg",
		})
		repo.UpdateErr = fmt.Errorf("connection lost")

		cmd := updatemedia.Command{ID: result.File.ID}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "connection lost")
		t.Log("Result: Repository update error propagated correctly")
		t.Log("Status: PASSED")
	})
}

func TestDeleteMediaHandler(t *testing.T) {
	t.Log("=== Scenario: DeleteMedia Command Handler ===")
	t.Log("Goal: Verify media deletion with not-found guard")

	repo := mocks.NewMockMediaWriteRepository()
	handler := deletemedia.NewHandler(repo)
	siteID := uuid.New()
	ctx := ctxWithSite(siteID)

	t.Run("success - deletes existing media file", func(t *testing.T) {
		repo.Reset()

		uploadHandler := uploadmedia.NewHandler(repo)
		result := &uploadmedia.Result{}
		_ = uploadHandler.Handle(uploadmedia.WithResult(ctx, result), uploadmedia.Command{
			FileName: "photo.jpg",
			FileURL:  "https://cdn.example.com/photo.jpg",
			MimeType: "image/jpeg",
		})
		require.Equal(t, 1, repo.Count())

		err := handler.Handle(ctx, deletemedia.Command{ID: result.File.ID})

		require.NoError(t, err)
		assert.Equal(t, 0, repo.Count())
		t.Log("Result: Media file deleted successfully")
		t.Log("Status: PASSED")
	})

	t.Run("fail - media not found", func(t *testing.T) {
		repo.Reset()

		err := handler.Handle(ctx, deletemedia.Command{ID: uuid.New()})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Result: Not-found error returned for unknown ID")
		t.Log("Status: PASSED")
	})

	t.Run("fail - delete same file twice", func(t *testing.T) {
		repo.Reset()

		uploadHandler := uploadmedia.NewHandler(repo)
		result := &uploadmedia.Result{}
		_ = uploadHandler.Handle(uploadmedia.WithResult(ctx, result), uploadmedia.Command{
			FileName: "photo.jpg",
			FileURL:  "https://cdn.example.com/photo.jpg",
			MimeType: "image/jpeg",
		})

		id := result.File.ID
		_ = handler.Handle(ctx, deletemedia.Command{ID: id})
		err := handler.Handle(ctx, deletemedia.Command{ID: id})

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Result: Second delete returns not-found error")
		t.Log("Status: PASSED")
	})
}

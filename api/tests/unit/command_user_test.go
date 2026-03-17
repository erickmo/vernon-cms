package unit

import (
	"context"
	"fmt"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	createuser "github.com/erickmo/vernon-cms/internal/command/create_user"
	deleteuser "github.com/erickmo/vernon-cms/internal/command/delete_user"
	updateuser "github.com/erickmo/vernon-cms/internal/command/update_user"
	"github.com/erickmo/vernon-cms/internal/domain/user"
	"github.com/erickmo/vernon-cms/tests/mocks"
)

func TestCreateUserHandler(t *testing.T) {
	t.Log("=== Scenario: CreateUser Command Handler ===")
	t.Log("Goal: Verify user creation with duplicate email guard")

	repo := mocks.NewMockUserRepository()
	eb := mocks.NewMockEventBus()
	handler := createuser.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - creates user and publishes event", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createuser.Command{
			Email:        "john@example.com",
			PasswordHash: "hashed_pw",
			Name:         "John Doe",
			Role:         user.RoleEditor,
		}

		err := handler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, 1, eb.EventCount())
		assert.Equal(t, "user.created", eb.LastEvent().EventName())
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty email", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createuser.Command{
			Email:        "",
			PasswordHash: "hash",
			Name:         "Name",
			Role:         user.RoleAdmin,
		}

		err := handler.Handle(ctx, cmd)
		assert.Error(t, err)
		assert.Equal(t, 0, eb.EventCount())
		t.Log("Status: PASSED")
	})

	t.Run("fail - duplicate email", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := createuser.Command{
			Email: "dup@test.com", PasswordHash: "hash", Name: "User 1", Role: user.RoleViewer,
		}
		_ = handler.Handle(ctx, cmd)

		cmd2 := createuser.Command{
			Email: "dup@test.com", PasswordHash: "hash2", Name: "User 2", Role: user.RoleViewer,
		}
		err := handler.Handle(ctx, cmd2)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "duplicate")
		t.Log("Result: Duplicate email rejected at repo level")
		t.Log("Status: PASSED")
	})

	t.Run("fail - repo save error", func(t *testing.T) {
		repo.Reset()
		eb.Reset()
		repo.SaveErr = fmt.Errorf("table locked")

		cmd := createuser.Command{
			Email: "test@test.com", PasswordHash: "hash", Name: "Name", Role: user.RoleAdmin,
		}
		err := handler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "table locked")
		t.Log("Status: PASSED")
	})
}

func TestUpdateUserHandler(t *testing.T) {
	t.Log("=== Scenario: UpdateUser Command Handler ===")

	repo := mocks.NewMockUserRepository()
	eb := mocks.NewMockEventBus()
	createHandler := createuser.NewHandler(repo, eb)
	updateHandler := updateuser.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - updates user", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createuser.Command{
			Email: "old@test.com", PasswordHash: "hash", Name: "Old Name", Role: user.RoleViewer,
		})
		eb.Reset()

		users, _, _ := repo.FindAll(0, 1)
		cmd := updateuser.Command{
			ID:    users[0].ID,
			Email: "new@test.com",
			Name:  "New Name",
			Role:  user.RoleAdmin,
		}

		err := updateHandler.Handle(ctx, cmd)

		require.NoError(t, err)
		assert.Equal(t, "user.updated", eb.LastEvent().EventName())

		updated, _ := repo.FindByID(users[0].ID)
		assert.Equal(t, "new@test.com", updated.Email)
		assert.Equal(t, "New Name", updated.Name)
		assert.Equal(t, user.RoleAdmin, updated.Role)
		t.Log("Status: PASSED")
	})

	t.Run("fail - user not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		cmd := updateuser.Command{
			ID: uuid.New(), Email: "a@b.com", Name: "N", Role: user.RoleViewer,
		}
		err := updateHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty email on update", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createuser.Command{
			Email: "test@test.com", PasswordHash: "hash", Name: "Name", Role: user.RoleViewer,
		})
		eb.Reset()

		users, _, _ := repo.FindAll(0, 1)
		cmd := updateuser.Command{ID: users[0].ID, Email: "", Name: "Name", Role: user.RoleViewer}
		err := updateHandler.Handle(ctx, cmd)

		assert.Error(t, err)
		t.Log("Status: PASSED")
	})
}

func TestDeleteUserHandler(t *testing.T) {
	t.Log("=== Scenario: DeleteUser Command Handler ===")

	repo := mocks.NewMockUserRepository()
	eb := mocks.NewMockEventBus()
	createHandler := createuser.NewHandler(repo, eb)
	deleteHandler := deleteuser.NewHandler(repo, eb)
	ctx := context.Background()

	t.Run("success - deletes user", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		_ = createHandler.Handle(ctx, createuser.Command{
			Email: "test@test.com", PasswordHash: "hash", Name: "Name", Role: user.RoleViewer,
		})
		eb.Reset()

		users, _, _ := repo.FindAll(0, 1)
		err := deleteHandler.Handle(ctx, deleteuser.Command{ID: users[0].ID})

		require.NoError(t, err)
		assert.Equal(t, "user.deleted", eb.LastEvent().EventName())
		t.Log("Status: PASSED")
	})

	t.Run("fail - user not found", func(t *testing.T) {
		repo.Reset()
		eb.Reset()

		err := deleteHandler.Handle(ctx, deleteuser.Command{ID: uuid.New()})
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not found")
		t.Log("Status: PASSED")
	})
}

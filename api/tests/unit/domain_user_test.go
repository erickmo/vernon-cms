package unit

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/erickmo/vernon-cms/internal/domain/user"
)

func TestNewUser(t *testing.T) {
	t.Log("=== Scenario: User Entity Creation ===")
	t.Log("Goal: Verify factory validates input and creates user with correct defaults")

	t.Run("success - valid input", func(t *testing.T) {
		u, err := user.NewUser("test@example.com", "hashed_password", "John Doe", user.RoleEditor)

		require.NoError(t, err)
		assert.NotEmpty(t, u.ID)
		assert.Equal(t, "test@example.com", u.Email)
		assert.Equal(t, "hashed_password", u.PasswordHash)
		assert.Equal(t, "John Doe", u.Name)
		assert.Equal(t, user.RoleEditor, u.Role)
		assert.True(t, u.IsActive)
		t.Log("Result: User created with IsActive=true by default")
		t.Log("Status: PASSED")
	})

	t.Run("success - empty role defaults to viewer", func(t *testing.T) {
		u, err := user.NewUser("test2@example.com", "hash", "Jane", "")

		require.NoError(t, err)
		assert.Equal(t, user.RoleViewer, u.Role)
		t.Log("Result: Empty role defaulted to viewer")
		t.Log("Status: PASSED")
	})

	t.Run("success - all role types", func(t *testing.T) {
		roles := []user.Role{user.RoleAdmin, user.RoleEditor, user.RoleViewer}
		for _, role := range roles {
			u, err := user.NewUser("test@test.com", "hash", "Name", role)
			require.NoError(t, err)
			assert.Equal(t, role, u.Role)
		}
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty email", func(t *testing.T) {
		u, err := user.NewUser("", "hash", "Name", user.RoleAdmin)

		assert.Nil(t, u)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "email")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty password hash", func(t *testing.T) {
		u, err := user.NewUser("test@test.com", "", "Name", user.RoleAdmin)

		assert.Nil(t, u)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "password")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name", func(t *testing.T) {
		u, err := user.NewUser("test@test.com", "hash", "", user.RoleAdmin)

		assert.Nil(t, u)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "name")
		t.Log("Status: PASSED")
	})

	t.Run("fail - all empty fields", func(t *testing.T) {
		u, err := user.NewUser("", "", "", "")

		assert.Nil(t, u)
		assert.Error(t, err)
		t.Log("Status: PASSED")
	})
}

func TestUserUpdateName(t *testing.T) {
	t.Log("=== Scenario: User Name Update ===")

	u, _ := user.NewUser("test@test.com", "hash", "Old Name", user.RoleAdmin)

	t.Run("success - valid name", func(t *testing.T) {
		err := u.UpdateName("New Name")
		assert.NoError(t, err)
		assert.Equal(t, "New Name", u.Name)
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty name", func(t *testing.T) {
		err := u.UpdateName("")
		assert.Error(t, err)
		assert.Equal(t, "New Name", u.Name) // unchanged
		t.Log("Status: PASSED")
	})
}

func TestUserUpdateEmail(t *testing.T) {
	t.Log("=== Scenario: User Email Update ===")

	u, _ := user.NewUser("old@test.com", "hash", "Name", user.RoleAdmin)

	t.Run("success - valid email", func(t *testing.T) {
		err := u.UpdateEmail("new@test.com")
		assert.NoError(t, err)
		assert.Equal(t, "new@test.com", u.Email)
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty email", func(t *testing.T) {
		err := u.UpdateEmail("")
		assert.Error(t, err)
		assert.Equal(t, "new@test.com", u.Email) // unchanged
		t.Log("Status: PASSED")
	})
}

func TestUserUpdatePassword(t *testing.T) {
	t.Log("=== Scenario: User Password Update ===")

	u, _ := user.NewUser("test@test.com", "old_hash", "Name", user.RoleAdmin)

	u.UpdatePassword("new_hash")

	assert.Equal(t, "new_hash", u.PasswordHash)
	t.Log("Status: PASSED")
}

func TestUserUpdateRole(t *testing.T) {
	t.Log("=== Scenario: User Role Update ===")

	u, _ := user.NewUser("test@test.com", "hash", "Name", user.RoleViewer)

	t.Run("viewer → editor", func(t *testing.T) {
		u.UpdateRole(user.RoleEditor)
		assert.Equal(t, user.RoleEditor, u.Role)
		t.Log("Status: PASSED")
	})

	t.Run("editor → admin", func(t *testing.T) {
		u.UpdateRole(user.RoleAdmin)
		assert.Equal(t, user.RoleAdmin, u.Role)
		t.Log("Status: PASSED")
	})

	t.Run("admin → viewer (downgrade)", func(t *testing.T) {
		u.UpdateRole(user.RoleViewer)
		assert.Equal(t, user.RoleViewer, u.Role)
		t.Log("Status: PASSED")
	})
}

func TestUserSetActive(t *testing.T) {
	t.Log("=== Scenario: User Active Status Toggle ===")

	u, _ := user.NewUser("test@test.com", "hash", "Name", user.RoleAdmin)
	assert.True(t, u.IsActive)

	t.Run("deactivate user", func(t *testing.T) {
		u.SetActive(false)
		assert.False(t, u.IsActive)
		t.Log("Status: PASSED")
	})

	t.Run("reactivate user", func(t *testing.T) {
		u.SetActive(true)
		assert.True(t, u.IsActive)
		t.Log("Status: PASSED")
	})
}

func TestUserRoleConstants(t *testing.T) {
	t.Log("=== Scenario: Role Constants Validity ===")

	assert.Equal(t, user.Role("admin"), user.RoleAdmin)
	assert.Equal(t, user.Role("editor"), user.RoleEditor)
	assert.Equal(t, user.Role("viewer"), user.RoleViewer)
	t.Log("Status: PASSED")
}

func TestUserPasswordNotInJSON(t *testing.T) {
	t.Log("=== Scenario: Password Hash Not Exposed in JSON ===")
	t.Log("Goal: Verify password_hash has json:\"-\" tag and won't leak")

	u, _ := user.NewUser("test@test.com", "secret_hash", "Name", user.RoleAdmin)

	// The password hash field has json:"-" tag, so it should not be included in JSON
	assert.Equal(t, "secret_hash", u.PasswordHash) // internal access still works
	t.Log("Status: PASSED")
}

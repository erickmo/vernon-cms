package unit

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/erickmo/vernon-cms/pkg/auth"
)

func TestJWTService(t *testing.T) {
	t.Log("=== Scenario: JWT Token Generation & Validation ===")
	t.Log("Goal: Verify token lifecycle — generate, validate, expiry, tamper detection")

	svc := auth.NewJWTService("test-secret-key-minimum-32-chars!", 15*time.Minute, 7*24*time.Hour)
	userID := uuid.New()

	t.Run("success - generate and validate token pair", func(t *testing.T) {
		pair, err := svc.GenerateTokenPair(userID, "john@example.com", "admin", uuid.Nil, "")

		require.NoError(t, err)
		assert.NotEmpty(t, pair.AccessToken)
		assert.NotEmpty(t, pair.RefreshToken)
		assert.Greater(t, pair.ExpiresAt, time.Now().Unix())

		// Validate access token
		claims, err := svc.ValidateToken(pair.AccessToken)
		require.NoError(t, err)
		assert.Equal(t, userID, claims.UserID)
		assert.Equal(t, "john@example.com", claims.Email)
		assert.Equal(t, "admin", claims.Role)
		assert.Equal(t, userID.String(), claims.Subject)
		assert.Equal(t, "vernon-cms", claims.Issuer)
		t.Log("Status: PASSED")
	})

	t.Run("success - validate refresh token", func(t *testing.T) {
		pair, _ := svc.GenerateTokenPair(userID, "john@example.com", "editor", uuid.Nil, "")

		claims, err := svc.ValidateToken(pair.RefreshToken)
		require.NoError(t, err)
		assert.Equal(t, userID, claims.UserID)
		assert.Equal(t, "editor", claims.Role)
		t.Log("Status: PASSED")
	})

	t.Run("fail - invalid token string", func(t *testing.T) {
		claims, err := svc.ValidateToken("not.a.valid.token")

		assert.Error(t, err)
		assert.Nil(t, claims)
		t.Log("Result: Invalid token rejected")
		t.Log("Status: PASSED")
	})

	t.Run("fail - empty token", func(t *testing.T) {
		claims, err := svc.ValidateToken("")

		assert.Error(t, err)
		assert.Nil(t, claims)
		t.Log("Status: PASSED")
	})

	t.Run("fail - token signed with wrong key", func(t *testing.T) {
		otherSvc := auth.NewJWTService("different-secret-key-also-32-ch!", 15*time.Minute, 7*24*time.Hour)
		pair, _ := otherSvc.GenerateTokenPair(userID, "john@example.com", "admin", uuid.Nil, "")

		claims, err := svc.ValidateToken(pair.AccessToken)

		assert.Error(t, err)
		assert.Nil(t, claims)
		t.Log("Result: Token with different signing key rejected")
		t.Log("Status: PASSED")
	})

	t.Run("fail - expired token", func(t *testing.T) {
		shortSvc := auth.NewJWTService("test-secret-key-minimum-32-chars!", -1*time.Second, -1*time.Second)
		pair, _ := shortSvc.GenerateTokenPair(userID, "john@example.com", "admin", uuid.Nil, "")

		claims, err := svc.ValidateToken(pair.AccessToken)

		assert.Error(t, err)
		assert.Nil(t, claims)
		t.Log("Result: Expired token rejected")
		t.Log("Status: PASSED")
	})

	t.Run("each token pair has unique JTI", func(t *testing.T) {
		pair1, _ := svc.GenerateTokenPair(userID, "john@example.com", "admin", uuid.Nil, "")
		pair2, _ := svc.GenerateTokenPair(userID, "john@example.com", "admin", uuid.Nil, "")

		claims1, _ := svc.ValidateToken(pair1.AccessToken)
		claims2, _ := svc.ValidateToken(pair2.AccessToken)

		assert.NotEqual(t, claims1.ID, claims2.ID)
		t.Log("Result: Each token has unique JWT ID")
		t.Log("Status: PASSED")
	})
}

func TestPasswordHashing(t *testing.T) {
	t.Log("=== Scenario: Password Hashing (bcrypt) ===")
	t.Log("Goal: Verify password hash/check lifecycle")

	t.Run("success - hash and verify", func(t *testing.T) {
		hash, err := auth.HashPassword("MySecurePassword123!")
		require.NoError(t, err)
		assert.NotEmpty(t, hash)
		assert.NotEqual(t, "MySecurePassword123!", hash)

		assert.True(t, auth.CheckPassword("MySecurePassword123!", hash))
		t.Log("Status: PASSED")
	})

	t.Run("fail - wrong password", func(t *testing.T) {
		hash, _ := auth.HashPassword("CorrectPassword")

		assert.False(t, auth.CheckPassword("WrongPassword", hash))
		t.Log("Result: Wrong password rejected")
		t.Log("Status: PASSED")
	})

	t.Run("different hashes for same password", func(t *testing.T) {
		hash1, _ := auth.HashPassword("SamePassword")
		hash2, _ := auth.HashPassword("SamePassword")

		assert.NotEqual(t, hash1, hash2) // bcrypt uses random salt
		assert.True(t, auth.CheckPassword("SamePassword", hash1))
		assert.True(t, auth.CheckPassword("SamePassword", hash2))
		t.Log("Result: Same password produces different hashes (bcrypt salt)")
		t.Log("Status: PASSED")
	})

	t.Run("empty password can be hashed", func(t *testing.T) {
		hash, err := auth.HashPassword("")
		require.NoError(t, err)
		assert.True(t, auth.CheckPassword("", hash))
		assert.False(t, auth.CheckPassword("not-empty", hash))
		t.Log("Status: PASSED")
	})
}

package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/site"
	"github.com/erickmo/vernon-cms/pkg/auth"
)

type contextKey string

const (
	ClaimsKey    contextKey = "claims"
	TenantKey    contextKey = "tenant_site_id"
)

func Auth(jwtSvc *auth.JWTService) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			if header == "" {
				http.Error(w, `{"error":"missing authorization header"}`, http.StatusUnauthorized)
				return
			}

			parts := strings.SplitN(header, " ", 2)
			if len(parts) != 2 || !strings.EqualFold(parts[0], "bearer") {
				http.Error(w, `{"error":"invalid authorization format"}`, http.StatusUnauthorized)
				return
			}

			claims, err := jwtSvc.ValidateToken(parts[1])
			if err != nil {
				http.Error(w, `{"error":"invalid or expired token"}`, http.StatusUnauthorized)
				return
			}

			ctx := context.WithValue(r.Context(), ClaimsKey, claims)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func RequireRole(roles ...string) func(http.Handler) http.Handler {
	roleSet := make(map[string]bool, len(roles))
	for _, r := range roles {
		roleSet[r] = true
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			claims := GetClaims(r.Context())
			if claims == nil {
				http.Error(w, `{"error":"unauthorized"}`, http.StatusUnauthorized)
				return
			}

			if !roleSet[claims.Role] {
				http.Error(w, `{"error":"insufficient permissions"}`, http.StatusForbidden)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

// TenantResolution resolves the site from X-Site-ID header or Host header and injects site ID into context.
func TenantResolution(siteRepo site.ReadRepository) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := r.Context()

			// 1. Try X-Site-ID header first
			if siteIDStr := r.Header.Get("X-Site-ID"); siteIDStr != "" {
				if siteID, err := uuid.Parse(siteIDStr); err == nil {
					s, err := siteRepo.FindByID(siteID)
					if err == nil && s.IsActive {
						ctx = context.WithValue(ctx, TenantKey, s.ID)
						next.ServeHTTP(w, r.WithContext(ctx))
						return
					}
				}
			}

			// 2. Fall back to Host header
			host := r.Host
			// Strip port if present
			if idx := strings.LastIndex(host, ":"); idx != -1 {
				host = host[:idx]
			}
			if host != "" {
				s, err := siteRepo.FindByCustomDomain(host)
				if err == nil && s.IsActive {
					ctx = context.WithValue(ctx, TenantKey, s.ID)
				}
			}

			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// RequireTenant returns 404 if no site_id is in context.
func RequireTenant() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			siteID := GetSiteID(r.Context())
			if siteID == uuid.Nil {
				http.Error(w, `{"error":"site not found"}`, http.StatusNotFound)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

// RequireSiteRole checks that the JWT site_id matches context site_id and role is allowed.
func RequireSiteRole(roles ...string) func(http.Handler) http.Handler {
	roleSet := make(map[string]bool, len(roles))
	for _, r := range roles {
		roleSet[r] = true
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			claims := GetClaims(r.Context())
			if claims == nil {
				http.Error(w, `{"error":"unauthorized"}`, http.StatusUnauthorized)
				return
			}

			siteID := GetSiteID(r.Context())
			if siteID == uuid.Nil {
				http.Error(w, `{"error":"site not found"}`, http.StatusNotFound)
				return
			}

			if claims.SiteID != siteID {
				http.Error(w, `{"error":"token not valid for this site"}`, http.StatusForbidden)
				return
			}

			if !roleSet[claims.SiteRole] {
				http.Error(w, `{"error":"insufficient permissions"}`, http.StatusForbidden)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

func GetClaims(ctx context.Context) *auth.Claims {
	claims, _ := ctx.Value(ClaimsKey).(*auth.Claims)
	return claims
}

func GetSiteID(ctx context.Context) uuid.UUID {
	id, _ := ctx.Value(TenantKey).(uuid.UUID)
	return id
}

func GetUserID(ctx context.Context) uuid.UUID {
	claims := GetClaims(ctx)
	if claims == nil {
		return uuid.Nil
	}
	return claims.UserID
}

func MaxBodySize(maxBytes int64) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			r.Body = http.MaxBytesReader(w, r.Body, maxBytes)
			next.ServeHTTP(w, r)
		})
	}
}

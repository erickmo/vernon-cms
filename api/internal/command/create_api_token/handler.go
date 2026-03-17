package createapitoken

import (
	"context"
	"crypto/sha256"
	"fmt"
	"time"

	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/domain/apitoken"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type Command struct {
	Name        string     `json:"name" validate:"required"`
	Permissions []string   `json:"permissions"`
	ExpiresAt   *time.Time `json:"expires_at"`
}

func (c Command) CommandName() string { return "CreateAPIToken" }

// Result carries the plain token back to the HTTP handler.
type Result struct {
	Token *apitoken.APIToken
	Plain string
}

type resultKey struct{}

// WithResult injects a result container into ctx so the HTTP layer can retrieve the plain token.
func WithResult(ctx context.Context, r *Result) context.Context {
	return context.WithValue(ctx, resultKey{}, r)
}

func getResult(ctx context.Context) *Result {
	r, _ := ctx.Value(resultKey{}).(*Result)
	return r
}

type Handler struct {
	repo apitoken.WriteRepository
}

func NewHandler(repo apitoken.WriteRepository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	c := cmd.(Command)
	siteID := middleware.GetSiteID(ctx)

	plain := uuid.New().String() + uuid.New().String()
	hash := fmt.Sprintf("%x", sha256.Sum256([]byte(plain)))
	prefix := plain[:8]

	perms := c.Permissions
	if perms == nil {
		perms = []string{}
	}

	t, err := apitoken.NewAPIToken(siteID, c.Name, hash, prefix, perms, c.ExpiresAt)
	if err != nil {
		return err
	}

	if err := h.repo.Save(t); err != nil {
		return err
	}

	if res := getResult(ctx); res != nil {
		res.Token = t
		res.Plain = plain
	}
	return nil
}

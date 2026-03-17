package login

import (
	"context"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"

	"github.com/erickmo/vernon-cms/internal/domain/site"
	"github.com/erickmo/vernon-cms/internal/domain/user"
	"github.com/erickmo/vernon-cms/pkg/apperror"
	"github.com/erickmo/vernon-cms/pkg/auth"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
)

type Command struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

func (c Command) CommandName() string { return "Login" }

type Handler struct {
	repo     user.ReadRepository
	siteRepo site.ReadRepository
	jwtSvc   *auth.JWTService
	tracer   trace.Tracer
}

func NewHandler(repo user.ReadRepository, siteRepo site.ReadRepository, jwtSvc *auth.JWTService) *Handler {
	return &Handler{
		repo:     repo,
		siteRepo: siteRepo,
		jwtSvc:   jwtSvc,
		tracer:   otel.Tracer("command.login"),
	}
}

func (h *Handler) Handle(ctx context.Context, cmd commandbus.Command) error {
	// Login is special — it returns data via context. See auth_handler.go
	return nil
}

func (h *Handler) Authenticate(ctx context.Context, email, password string, siteID uuid.UUID) (*auth.TokenPair, error) {
	ctx, span := h.tracer.Start(ctx, "Login.Authenticate")
	defer span.End()

	u, err := h.repo.FindByEmail(email)
	if err != nil {
		return nil, &apperror.UnauthorizedError{Message: "invalid email or password"}
	}

	if !u.IsActive {
		return nil, &apperror.UnauthorizedError{Message: "account is deactivated"}
	}

	if !auth.CheckPassword(password, u.PasswordHash) {
		return nil, &apperror.UnauthorizedError{Message: "invalid email or password"}
	}

	// Look up site role if siteID provided
	siteRole := ""
	if siteID != uuid.Nil {
		member, err := h.siteRepo.FindMemberByIDs(siteID, u.ID)
		if err != nil {
			return nil, &apperror.UnauthorizedError{Message: "user is not a member of this site"}
		}
		siteRole = string(member.Role)
	}

	tokenPair, err := h.jwtSvc.GenerateTokenPair(u.ID, u.Email, string(u.Role), siteID, siteRole)
	if err != nil {
		return nil, err
	}

	return tokenPair, nil
}

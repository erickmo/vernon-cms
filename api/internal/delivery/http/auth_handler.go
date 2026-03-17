package http

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	"github.com/erickmo/vernon-cms/internal/command/login"
	"github.com/erickmo/vernon-cms/internal/command/register"
	"github.com/erickmo/vernon-cms/pkg/apperror"
	"github.com/erickmo/vernon-cms/pkg/auth"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/middleware"
)

type AuthHandler struct {
	cmdBus       *commandbus.CommandBus
	loginHandler *login.Handler
	jwtSvc       *auth.JWTService
	validate     *validator.Validate
}

func NewAuthHandler(cmdBus *commandbus.CommandBus, loginHandler *login.Handler, jwtSvc *auth.JWTService) *AuthHandler {
	return &AuthHandler{
		cmdBus:       cmdBus,
		loginHandler: loginHandler,
		jwtSvc:       jwtSvc,
		validate:     validator.New(),
	}
}

func (h *AuthHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/auth", func(r chi.Router) {
		r.Post("/register", h.Register)
		r.Post("/login", h.Login)
		r.Post("/refresh", h.Refresh)
	})
}

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var cmd register.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.validate.Struct(cmd); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	if err := h.cmdBus.Dispatch(r.Context(), cmd); err != nil {
		if apperror.IsConflict(err) {
			writeError(w, http.StatusConflict, err.Error())
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusCreated, map[string]string{"status": "registered"})
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email    string     `json:"email" validate:"required,email"`
		Password string     `json:"password" validate:"required"`
		SiteID   *uuid.UUID `json:"site_id"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.validate.Struct(req); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	// Determine siteID: explicit body field takes priority, then context (Host-based)
	siteID := uuid.Nil
	if req.SiteID != nil {
		siteID = *req.SiteID
	} else {
		siteID = middleware.GetSiteID(r.Context())
	}

	tokenPair, err := h.loginHandler.Authenticate(r.Context(), req.Email, req.Password, siteID)
	if err != nil {
		if apperror.IsUnauthorized(err) {
			writeError(w, http.StatusUnauthorized, err.Error())
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, tokenPair)
}

func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	var req struct {
		RefreshToken string `json:"refresh_token" validate:"required"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.validate.Struct(req); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	claims, err := h.jwtSvc.ValidateToken(req.RefreshToken)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "invalid or expired refresh token")
		return
	}

	tokenPair, err := h.jwtSvc.GenerateTokenPair(claims.UserID, claims.Email, claims.Role, claims.SiteID, claims.SiteRole)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, tokenPair)
}

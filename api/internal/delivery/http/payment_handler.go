package http

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	createpayment "github.com/erickmo/vernon-cms/internal/command/create_payment"
	getpayment "github.com/erickmo/vernon-cms/internal/query/get_payment"
	listpayments "github.com/erickmo/vernon-cms/internal/query/list_payments"
	"github.com/erickmo/vernon-cms/internal/domain/payment"
	"github.com/erickmo/vernon-cms/pkg/commandbus"
	"github.com/erickmo/vernon-cms/pkg/querybus"
)

type PaymentHandler struct {
	cmdBus   *commandbus.CommandBus
	queryBus *querybus.QueryBus
	validate *validator.Validate
}

func NewPaymentHandler(cmdBus *commandbus.CommandBus, queryBus *querybus.QueryBus) *PaymentHandler {
	return &PaymentHandler{
		cmdBus:   cmdBus,
		queryBus: queryBus,
		validate: validator.New(),
	}
}

func (h *PaymentHandler) RegisterRoutes(r chi.Router) {
	r.Route("/api/v1/payments", func(r chi.Router) {
		r.Get("/", h.List)
		r.Post("/", h.Create)
		r.Get("/{id}", h.GetByID)
	})
}

func (h *PaymentHandler) List(w http.ResponseWriter, r *http.Request) {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	perPage, _ := strconv.Atoi(r.URL.Query().Get("per_page"))

	var clientID *uuid.UUID
	if v := r.URL.Query().Get("client_id"); v != "" {
		if id, err := uuid.Parse(v); err == nil {
			clientID = &id
		}
	}

	var status *payment.Status
	if v := r.URL.Query().Get("status"); v != "" {
		s := payment.Status(v)
		status = &s
	}

	result, err := h.queryBus.Dispatch(r.Context(), listpayments.Query{
		ClientID: clientID,
		Status:   status,
		Page:     page,
		PerPage:  perPage,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *PaymentHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid payment id")
		return
	}

	result, err := h.queryBus.Dispatch(r.Context(), getpayment.Query{ID: id})
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *PaymentHandler) Create(w http.ResponseWriter, r *http.Request) {
	var cmd createpayment.Command
	if err := json.NewDecoder(r.Body).Decode(&cmd); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.validate.Struct(cmd); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	result := &createpayment.Result{}
	ctx := createpayment.WithResult(r.Context(), result)

	if err := h.cmdBus.Dispatch(ctx, cmd); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusCreated, result.Payment)
}

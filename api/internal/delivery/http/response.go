package http

import (
	"encoding/json"
	"net/http"

	"github.com/erickmo/vernon-cms/pkg/apperror"
)

type Response struct {
	Data  interface{} `json:"data,omitempty"`
	Error string      `json:"error,omitempty"`
}

func writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(Response{Data: data})
}

// writeFlatJSON writes data directly without wrapping in {"data":...}.
// Used for new endpoints where Flutter datasources parse response.data directly.
func writeFlatJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

func writeError(w http.ResponseWriter, status int, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(Response{Error: message})
}

func writeAppError(w http.ResponseWriter, err error) {
	switch {
	case apperror.IsNotFound(err):
		writeError(w, http.StatusNotFound, err.Error())
	case apperror.IsValidation(err):
		writeError(w, http.StatusBadRequest, err.Error())
	case apperror.IsConflict(err):
		writeError(w, http.StatusConflict, err.Error())
	case apperror.IsUnauthorized(err):
		writeError(w, http.StatusUnauthorized, err.Error())
	case apperror.IsForbidden(err):
		writeError(w, http.StatusForbidden, err.Error())
	default:
		writeError(w, http.StatusInternalServerError, err.Error())
	}
}

package main
import (
 "net/http"
 "net/http/httptest"
 "testing"
)
func TestHealthDatabaseUnavailable(t *testing.T) {
 t.Setenv("DATABASE_URL", "postgres://invalid:invalid@127.0.0.1:1/invalid?connect_timeout=1")
 r := httptest.NewRecorder(); health(r, httptest.NewRequest(http.MethodGet, "/health", nil))
 if r.Code != http.StatusServiceUnavailable { t.Fatalf("got %d", r.Code) }
}

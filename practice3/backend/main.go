package main

import (
 "encoding/json"
 "log"
 "net/http"
 "os"
 "os/exec"
 "time"
)

func health(w http.ResponseWriter, _ *http.Request) {
 ctx := exec.Command("pg_isready", "-d", os.Getenv("DATABASE_URL"))
 if err := ctx.Run(); err != nil { http.Error(w, "database unavailable", http.StatusServiceUnavailable); return }
 w.Header().Set("Content-Type", "application/json")
 _ = json.NewEncoder(w).Encode(map[string]string{"status":"ok"})
}
func main() {
 http.HandleFunc("/health", health)
 http.HandleFunc("/api/health", health)
 server := &http.Server{Addr:":8000", ReadHeaderTimeout: 5*time.Second}
 log.Fatal(server.ListenAndServe())
}

# Vernon CMS — TODO

**Last updated:** 2026-03-17
**Current commit:** `cd0e882`

---

## ✅ Done

| # | Task | Commit |
|---|---|---|
| - | Core CMS (pages, content, categories, users, domain builder) | `075d82c` |
| - | Auth + JWT + RBAC | `075d82c` |
| - | Settings / Media / ActivityLog / APIToken | `ba14eb8` |
| - | app_admin Flutter (clients + payments UI) | `075d82c` |
| - | Unit tests: 393 cases (Settings, Media, APIToken added) | `cd0e882` |
| - | Multipart file upload (save to disk, serve /uploads/*) | `cd0e882` |
| - | Clients + Payments API (domain, migrations, CRUD) | `cd0e882` |

---

## 🔴 High Priority

### 1. Rate Limiting — Login Endpoint
Protect `POST /api/v1/auth/login` dari brute force.
- [ ] Pilih library: `go.uber.org/ratelimit` atau `golang.org/x/time/rate`
- [ ] Implementasi per-IP rate limiter middleware
- [ ] Default: 5 attempts / minute per IP
- [ ] Config via env: `LOGIN_RATE_LIMIT` (default 5)
- [ ] Return 429 Too Many Requests saat limit tercapai

### 2. Unit Tests — Clients & Payments
Test baru belum ada untuk fitur clients/payments.
- [ ] Mock: `client_repository.go` (write + read)
- [ ] Mock: `payment_repository.go` (write + read)
- [ ] `command_client_test.go` — CreateClient, UpdateClient, DeleteClient, ToggleClient
- [ ] `command_payment_test.go` — CreatePayment (validasi amount > 0, client_id required)

### 3. HTTP Handler Tests — New Features
- [ ] `http_settings_handler_test.go` — GET + PUT /api/v1/settings
- [ ] `http_media_handler_test.go` — List, Upload (JSON + multipart), Update, Delete
- [ ] `http_api_token_handler_test.go` — CRUD + toggle-active
- [ ] `http_client_handler_test.go` — CRUD + toggle-active
- [ ] `http_payment_handler_test.go` — List, Create, GetByID

---

## 🟡 Medium Priority

### 4. Integration Tests (Testcontainers)
Saat ini hanya `page_test.go`. Butuh:
- [ ] Content + ContentCategory integration
- [ ] Client + Payment integration
- [ ] Multi-tenant isolation test (data tidak bocor antar site_id)
- [ ] API Token auth flow (hash, verify, last_used_at update)

### 5. Cursor-based Pagination
`OFFSET/LIMIT` tidak efisien untuk dataset besar.
- [ ] Implementasi cursor pagination untuk: contents, pages, media, activity-logs
- [ ] Format cursor: `created_at` + `id` (stable sort)
- [ ] Backward compatible — jika `cursor` param tidak ada, fallback ke offset

### 6. Token Blacklist / Revocation
JWT saat ini tidak bisa di-invalidate sebelum expired.
- [ ] Simpan revoked tokens di Redis dengan TTL = sisa expiry
- [ ] Check blacklist di `Auth` middleware
- [ ] Endpoint `POST /api/v1/auth/logout` → blacklist access token

### 7. Enhanced Health Check
Saat ini `/health` hanya return `{"status":"ok"}`.
- [ ] Check DB connectivity (simple query)
- [ ] Check Redis connectivity (PING)
- [ ] Return degraded status jika salah satu down

---

## 🟢 Low Priority

### 8. OpenAPI Spec
- [ ] Generate OpenAPI 3.0 dari code (swaggo/swag atau manual)
- [ ] Expose `/docs` endpoint di development mode

### 9. Input Sanitization (XSS Prevention)
- [ ] Sanitize HTML di `content.Body`, `content.Excerpt`
- [ ] Library: `microcosm-cc/bluemonday`

### 10. Structured Error Codes
- [ ] Tambah `code` field di error response: `{"error":"...", "code":"DUPLICATE_SLUG"}`
- [ ] Konsisten di semua handler

### 11. app_admin — Update CLAUDE.md & Docs
- [ ] Update `app_admin/CLAUDE.md` endpoint map (reflect Go API yang sudah ada)
- [ ] Pastikan Flutter datasource URL match dengan Go routes

---

## 🔧 Tech Debt

| Item | Detail |
|---|---|
| `writeJSON` vs `writeFlatJSON` | Dual format masih ada — unify di versi besar berikutnya |
| Activity log sync | Saat ini async best-effort; pertimbangkan queue di scale |
| Payment: no update/delete | Intentional; tambah jika bisnis butuh |
| Clients: no site_id | Clients adalah global platform entity, bukan tenant-scoped |

# Code Audit: Vernon CMS

**Versi:** 1.3.0
**Tanggal:** 2026-03-17
**Auditor:** AI-Generated

---

## 1. Architecture Compliance

### 1.1 Clean Architecture Rules

| Rule | Status | Evidence |
|---|---|---|
| Domain layer ZERO external dependency | PASS | `internal/domain/*/` hanya import stdlib + uuid |
| Repository interface di domain layer | PASS | `WriteRepository` dan `ReadRepository` di entity file |
| Command handler hanya depend ke WriteRepository + EventBus | PASS | Semua command handler hanya inject repo + eventbus |
| Query handler hanya depend ke ReadRepository atau sqlx.DB | PASS | Dashboard & ActivityLog pakai sqlx.DB langsung (valid untuk simple aggregations) |
| HTTP handler hanya depend ke CommandBus + QueryBus | PASS | Tidak ada direct repo access di HTTP handler |
| 1 folder = 1 command/query | PASS | Setiap command/query punya folder sendiri |

### 1.2 CQRS Separation

| Aspek | Write Side | Read Side |
|---|---|---|
| Repository | WriteRepository | ReadRepository / sqlx.DB |
| Bus | CommandBus | QueryBus |
| Handler output | error | (interface{}, error) |
| Cache | Tidak ada | Redis 5m (core queries) |
| Side effects | Publish domain event | Tidak ada |

### 1.3 Event-Driven Architecture

| Aspek | Status |
|---|---|
| Domain events defined | PASS — 25+ events (8 entities) |
| Events implement DomainEvent interface | PASS — EventName() + OccurredAt() |
| EventBus interface di pkg/ | PASS — `pkg/eventbus/eventbus.go` |
| InMemory fallback | PASS — development |
| Cache invalidation via events | PASS — `CDNCacheHandler` |
| Activity log via events | PASS — `ActivityLogHandler` (best-effort, errors swallowed) |

### 1.4 Multi-tenancy

| Aspek | Status |
|---|---|
| TenantResolution middleware | PASS — X-Site-ID header + Host fallback |
| RequireTenant middleware | PASS — 404 jika no site_id in context |
| RequireSiteRole middleware | PASS — validasi site_id claim + role |
| site_id di semua tenant-scoped repositories | PASS — semua query include site_id filter |

### 1.5 Context Result Container Pattern

Digunakan untuk command yang perlu mengembalikan data ke HTTP handler (command bus hanya return error):

| Command | Pattern | Data yang dikembalikan |
|---|---|---|
| CreateAPIToken | `WithResult(ctx, &Result{})` | plain token + Token struct |
| UploadMedia | `WithResult(ctx, &Result{})` | MediaFile struct |

---

## 2. Security Review

### 2.1 Data Exposure

| Item | Status | Detail |
|---|---|---|
| Password hash di JSON response | SAFE | `json:"-"` tag |
| SQL Injection | SAFE | Parameterized queries via sqlx (`$1, $2, ...`) |
| API Token | SAFE | Hanya SHA-256 hash disimpan; plain token ditampilkan sekali saat create |
| Input validation | PASS | go-playground/validator v10 di HTTP layer |
| CORS | CONFIGURABLE | Via `CORS_ALLOWED_ORIGINS` env |

### 2.2 Authentication & Authorization

| Item | Status | Detail |
|---|---|---|
| JWT authentication | IMPLEMENTED | HMAC-SHA256, access (15m) + refresh (7d) |
| RBAC middleware | IMPLEMENTED | Per-site roles + global role |
| Multi-tenant token validation | IMPLEMENTED | claims.SiteID == context.SiteID check |
| Password hashing | IMPLEMENTED | bcrypt default cost |
| Public routes | SAFE | /health, /api/v1/auth/* only |

### 2.3 Remaining Issues

| Issue | Severity | Recommendation |
|---|---|---|
| No rate limiting | MEDIUM | Tambah rate limiter di login endpoint |
| No token blacklist/revocation | LOW | Implement jika perlu logout/force-expire |
| No input sanitization (XSS) | LOW | Sanitize HTML di body/excerpt |
| Activity log errors swallowed | LOW | Acceptable (best-effort audit log) |
| Media upload via URL (no file upload) | MEDIUM | Upload masih terima URL; implementasi multipart jika butuh direct upload |

---

## 3. Code Quality

### 3.1 File Count & Organization

| Layer | Files | Description |
|---|---|---|
| `cmd/api/` | 1 | FX wiring, server bootstrap |
| `internal/domain/` | 10 | 8 entities × (entity + events) + apitoken + settings + media |
| `internal/command/` | 35 | 35 command handlers |
| `internal/query/` | 25 | 25 query handlers |
| `internal/eventhandler/` | 2 | CDNCacheHandler + ActivityLogHandler |
| `internal/delivery/http/` | 11 | 9 entity handlers + auth handler + response helper |
| `infrastructure/database/` | 10 | DB repos (write + read) |
| `infrastructure/` | 13 | DB, cache, telemetry, config |
| `pkg/` | 8 | commandbus, querybus, eventbus, hooks, middleware, auth, apperror |
| `migrations/` | 24 | 12 up + 12 down |
| `tests/` | 26 | 5 mocks + 20 unit + 1 integration |

### 3.2 Consistency

| Pattern | Consistent | Notes |
|---|---|---|
| Command struct + CommandName() | Yes | Semua 35 commands |
| Query struct + QueryName() | Yes | Semua 25 queries |
| Handler.Handle() signature | Yes | Semua handlers |
| Repository interface naming | Yes | WriteRepository + ReadRepository |
| HTTP response format | Yes | `writeJSON` (wrapped) untuk endpoint lama; `writeFlatJSON` (flat) untuk endpoint baru |
| Auth middleware pattern | Yes | Auth(jwtSvc) + RequireSiteRole() chaining |
| Multi-tenancy | Yes | middleware.GetSiteID(ctx) di semua tenant-scoped handlers |
| Context result container | Yes | createapitoken + uploadmedia (untuk data return tanpa query bus) |

### 3.3 Dual Response Format

| Format | Digunakan untuk | Fungsi |
|---|---|---|
| `writeJSON` — `{"data": ...}` | Endpoint lama (content, pages, users, sites, domains) | Backward compatible dengan Flutter web lama |
| `writeFlatJSON` — flat JSON | Endpoint baru (dashboard, settings, media, activity-logs, tokens) | Flutter datasources parse `response.data` directly |

### 3.4 Test Quality

| Metric | Value |
|---|---|
| Total test cases | 334 (core entities) |
| Test files | 23 unit + 1 integration |
| Mock implementations | 6 (page, content_category, content, user, domain, eventbus) |
| Coverage area | Core CMS (pages, content, categories, users, domain builder) |
| New features tested | ⚠️ Settings/Media/Tokens/Dashboard belum ada unit test |

---

## 4. Performance Considerations

| Area | Current | Recommendation |
|---|---|---|
| DB connection pool | 25 max open, 5 idle | Adequate for medium load |
| Redis cache TTL | 5 minutes | Tunable via `REDIS_TTL_SECONDS` |
| Cache invalidation | Pattern scan + delete | Acceptable; consider pub/sub at scale |
| Query pagination | OFFSET/LIMIT | Consider cursor-based for large datasets |
| Activity log inserts | Synchronous (in event handler) | Consider async queue at scale |
| JSONB permissions (api_tokens) | json.Marshal/Unmarshal per op | Acceptable; tidak di hot path |

---

## 5. Recommendations

### Completed (v1.3.0)
- [x] ~~Settings per-site~~
- [x] ~~Media management~~
- [x] ~~Activity log (audit trail)~~
- [x] ~~API tokens (SHA-256 hash)~~
- [x] ~~Dashboard stats~~
- [x] ~~Fix path /data → /domains~~
- [x] ~~Multi-tenancy full implementation~~

### Completed (v1.2.0)
- [x] ~~Domain Builder — no-code custom entity types + dynamic CRUD~~

### Completed (v1.1.0)
- [x] ~~JWT authentication middleware~~
- [x] ~~Role-based access control (admin/editor/viewer)~~
- [x] ~~Restrict CORS (configurable origins)~~

### High Priority
1. **Unit tests untuk fitur baru** — Settings, Media, APIToken, Dashboard, ActivityLog belum ada unit test
2. **Rate limiting** — Protect login endpoint dari brute force
3. **Multipart file upload** — Saat ini upload hanya terima URL; perlu direct file upload

### Medium Priority
4. **Integration tests** — Testcontainers untuk semua entities
5. **Cursor-based pagination** — Untuk dataset besar
6. **Token blacklist/revocation** — Untuk logout dan force-expire
7. **Health check enhanced** — Include DB + Redis connectivity check

### Low Priority
8. **OpenAPI spec** — Generate dari code
9. **Input sanitization** — Sanitize HTML di body/excerpt (XSS prevention)
10. **Structured error codes** — Error codes selain string messages

---
*Di-generate dan di-update oleh AI. Review sebelum production deploy.*

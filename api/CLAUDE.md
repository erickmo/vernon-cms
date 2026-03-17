# Vernon CMS

## Overview
Content Management System (CMS) untuk mengelola pages, content categories, contents, dan users. Dibangun dengan arsitektur Clean Architecture + CQRS + Event-Driven.

**PRD Lengkap:** docs/requirements/prd-vernon-cms.md

## Architecture
- **Pattern:** Clean Architecture + CQRS + Event-Driven
- **HTTP:** Chi router
- **DI:** Uber FX
- **Events:** Watermill + NATS JetStream (InMemory fallback)
- **DB Write:** PostgreSQL 17 + sqlx + sqlc
- **DB Read:** PostgreSQL 17 + Redis cache
- **Observability:** OpenTelemetry + Prometheus + Jaeger
- **Logging:** zerolog
- **Auth:** JWT (golang-jwt/jwt v5) + bcrypt
- **RBAC:** admin / editor / viewer per-route

## Architecture Rules (WAJIB)
- Domain layer: ZERO external dependency (hanya stdlib + uuid)
- Command handler: hanya WriteRepository + EventBus
- Query handler: hanya ReadRepository + Redis
- HTTP handler: hanya CommandBus + QueryBus
- 1 folder = 1 command atau 1 query

## Project Structure
```
cmd/api/          ← FX wiring + server bootstrap
internal/
  domain/         ← entity + events + repo interfaces (ZERO deps)
  command/        ← 1 folder per command
  query/          ← 1 folder per query
  eventhandler/   ← side effects subscribe events
  delivery/http/  ← thin HTTP handlers
infrastructure/   ← implementasi DB, cache, telemetry
pkg/              ← commandbus, querybus, eventbus, hooks, middleware, auth, apperror
```

## Entities & Endpoints
| Entity | Endpoints | Write Access | Delete Access |
|---|---|---|---|
| Auth | /api/v1/auth/* (public) | - | - |
| Page | /api/v1/pages | admin, editor | admin |
| ContentCategory | /api/v1/content-categories | admin, editor | admin |
| Content | /api/v1/contents | admin, editor | admin |
| User | /api/v1/users | admin | admin |

## Key Commands
```bash
make infra-up         # start semua infra (Postgres+Redis+NATS+Jaeger)
make dev              # hot reload server
make build            # build binary
make test             # run unit tests
make test-race        # wajib sebelum PR
make test-integration # butuh Docker running
make sqlc             # regenerate setelah ubah SQL queries
make mock             # regenerate setelah ubah domain interfaces
make migrate-up       # run pending migrations
make tidy             # go mod tidy
```

## Important Notes
- Jalankan `make infra-up` sebelum development
- Copy `.env.example` ke `.env` sebelum running
- Setelah ubah `sqlc/queries/`: wajib `make sqlc`
- Setelah ubah interface di `internal/domain/`: wajib `make mock`
- Jaeger UI: http://localhost:16686
- Prometheus: http://localhost:9090
- NATS monitoring: http://localhost:8222

## Testing
- **334 unit test cases** — all passing
- Run: `make test` (unit) atau `make test-integration` (integration)
- Test files: `tests/unit/` dan `tests/integration/`
- Mocks: `tests/mocks/` (in-memory repositories + event bus)

## Documentation Index
| File | Deskripsi | Status |
|---|---|---|
| docs/requirements/prd-vernon-cms.md | PRD (domain, API, auth, RBAC, endpoints) | v1.2.0 |
| docs/testing/testing-document.md | Testing document (334 test cases, coverage matrix) | v1.2.0 |
| docs/audit/code-audit.md | Code audit (architecture, security, quality) | v1.2.0 |

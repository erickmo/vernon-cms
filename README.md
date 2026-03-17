# Vernon CMS

Full-stack Content Management System dengan Go backend dan Flutter Web dashboard.

## Stack

| Layer | Teknologi |
|---|---|
| API | Go, Chi, Uber FX, Clean Architecture + CQRS |
| Database | PostgreSQL 17, Redis, sqlc |
| Events | Watermill + NATS JetStream |
| Observability | OpenTelemetry, Prometheus, Jaeger |
| Web Dashboard | Flutter 3.41.4 (PWA), BLoC, go_router |

## Struktur Repo

```
vernon-cms/
├── api/    ← Go REST API
└── web/    ← Flutter Web PWA
```

## Quick Start

### 1. Prasyarat

- Go 1.22+
- Flutter 3.41.4
- Docker & Docker Compose
- [Air](https://github.com/air-verse/air) (hot reload Go)
- [golang-migrate](https://github.com/golang-migrate/migrate)
- [sqlc](https://sqlc.dev)

### 2. Setup API

```bash
cd api
cp .env.example .env   # sesuaikan konfigurasi jika perlu
make infra-up          # start Postgres, Redis, NATS, Jaeger
make migrate-up        # run database migrations
make dev               # start API dengan hot reload
```

API berjalan di `http://localhost:8080`

### 3. Setup Web

```bash
cd web
flutter pub get
make run               # flutter run -d chrome --web-port=3000
```

Dashboard berjalan di `http://localhost:3000`

### 4. Dari root (shortcut)

```bash
make infra-up    # start semua infra
make dev-api     # jalankan API
make dev-web     # jalankan Web
```

## Environment Variables (API)

Salin `api/.env.example` ke `api/.env`:

```env
HTTP_PORT=8080
DATABASE_URL=postgres://postgres:postgres@localhost:5432/vernon_cms_db?sslmode=disable
REDIS_URL=redis://localhost:6379/0
NATS_URL=nats://localhost:4222
JWT_SECRET=change-me-in-production-minimum-32-chars!
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

## Service URLs (Development)

| Service | URL |
|---|---|
| API | http://localhost:8080 |
| Web Dashboard | http://localhost:3000 |
| Jaeger UI | http://localhost:16686 |
| Prometheus | http://localhost:9090 |
| NATS Monitoring | http://localhost:8222 |

## Fitur

- Auth (JWT, RBAC: admin / editor / viewer)
- Content & Content Category management
- Page Management
- Domain Builder (no-code custom entity types)
- Media Manager
- User Management
- Activity Log
- API Token management
- Settings

## Commands

```bash
# API
make test-api            # unit tests (334 test cases)
make test-api-race       # race condition check
make test-api-integration # integration tests (butuh Docker)
make sqlc                # regenerate DB queries
make mock                # regenerate mocks
make migrate-up          # run migrations

# Web
make test-web            # flutter test
make gen-web             # build_runner (freezed, json_serializable)
make build-web           # build release PWA
```

## Dokumentasi

| Dokumen | Path |
|---|---|
| API PRD | `api/docs/requirements/prd-vernon-cms.md` |
| Web PRD | `web/docs/requirements/prd-vernon-cms-ui.md` |
| Testing Document | `api/docs/testing/testing-document.md` |
| Code Audit | `api/docs/audit/code-audit.md` |

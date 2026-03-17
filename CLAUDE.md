# Vernon CMS — Monorepo

Monorepo yang berisi tiga sub-project:

| Sub-project | Path | Deskripsi |
|---|---|---|
| `api` | `./api/` | Go backend (Clean Architecture + CQRS) |
| `web` | `./web/` | Flutter Web PWA — CMS dashboard (BLoC + go_router) |
| `app_admin` | `./app_admin/` | Flutter Web PWA — Admin panel (clients & payments) |

Lihat CLAUDE.md masing-masing sub-project untuk detail lengkap:
- **API:** `api/CLAUDE.md`
- **Web (CMS):** `web/CLAUDE.md`
- **Admin Panel:** `app_admin/CLAUDE.md`

## Quick Start

```bash
# Start semua infra (Postgres, Redis, NATS, Jaeger)
make infra-up

# Jalankan masing-masing di terminal terpisah
make dev-api      # Terminal 1
make dev-web      # Terminal 2
make dev-admin    # Terminal 3

# Lihat semua shortcut
make dev
```

## Key Commands

```bash
make infra-up       # start Docker infra (dari api/)
make infra-down     # stop Docker infra
make dev-api        # hot reload Go API
make dev-web        # flutter run chrome (CMS, port 3000)
make dev-admin      # flutter run chrome (Admin, port 3001)
make test-api       # unit test API
make test-web       # flutter test CMS web
make test-admin     # flutter test admin panel
make build-api      # build Go binary
make build-web      # build Flutter CMS web release
make build-admin    # build Flutter Admin web release
make gen-web        # build_runner untuk web/
make gen-admin      # build_runner untuk app_admin/
make sqlc           # regenerate sqlc queries (Go)
make mock           # regenerate mocks (Go)
make migrate-up     # run DB migrations
```

## Service URLs (Development)

| Service | URL |
|---|---|
| API | http://localhost:8080 |
| CMS Dashboard | http://localhost:3000 |
| Admin Panel | http://localhost:3001 |
| Jaeger UI | http://localhost:16686 |
| Prometheus | http://localhost:9090 |
| NATS | http://localhost:8222 |

## Contract: API ↔ Frontend

Base URL dikonfigurasi via `.env` file (development) atau `--dart-define=BASE_URL=...` (build/prod).

- `web/` endpoint pattern: lihat `web/CLAUDE.md` bagian **API Endpoints Pattern**
- `app_admin/` endpoint pattern: lihat `app_admin/CLAUDE.md` bagian **API Endpoints**

> **Note:** Endpoints `/api/v1/clients` dan `/api/v1/payments` belum ada di `api/` dan perlu ditambahkan.

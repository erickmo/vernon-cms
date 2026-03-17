# Vernon CMS — Monorepo

Monorepo yang berisi dua sub-project:

| Sub-project | Path | Deskripsi |
|---|---|---|
| `api` | `./api/` | Go backend (Clean Architecture + CQRS) |
| `web` | `./web/` | Flutter Web PWA (BLoC + go_router) |

Lihat CLAUDE.md masing-masing sub-project untuk detail lengkap:
- **API:** `api/CLAUDE.md`
- **Web:** `web/CLAUDE.md`

## Quick Start

```bash
# Start semua infra (Postgres, Redis, NATS, Jaeger)
make infra-up

# Jalankan API + Web sekaligus (2 terminal)
make dev-api
make dev-web

# Atau shortcut semuanya
make dev
```

## Key Commands

```bash
make infra-up       # start Docker infra (dari api/)
make infra-down     # stop Docker infra
make dev-api        # hot reload Go API
make dev-web        # flutter run chrome
make test-api       # unit test API
make test-web       # flutter test web
make build-api      # build Go binary
make build-web      # build Flutter web release
make gen-web        # flutter build_runner (freezed, json_serializable)
make sqlc           # regenerate sqlc queries (Go)
make mock           # regenerate mocks (Go)
make migrate-up     # run DB migrations
```

## Service URLs (Development)

| Service | URL |
|---|---|
| API | http://localhost:8080 |
| Web (dev) | http://localhost:8081 |
| Jaeger UI | http://localhost:16686 |
| Prometheus | http://localhost:9090 |
| NATS | http://localhost:8222 |

## Contract: API ↔ Web

Base URL web ke API dikonfigurasi via `--dart-define=BASE_URL=...` saat build/run Flutter.
Contoh: `make dev-web` → `--dart-define=BASE_URL=http://localhost:8080`

Endpoint pattern lengkap ada di `web/CLAUDE.md` bagian **API Endpoints Pattern**.

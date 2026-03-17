# Vernon CMS

A production-grade Content Management System REST API built with Go, following **Clean Architecture + CQRS + Event-Driven Architecture**.

## Tech Stack

| Component | Technology |
|---|---|
| Language | Go 1.25 |
| HTTP Router | [Chi](https://github.com/go-chi/chi) v5 |
| Dependency Injection | [Uber FX](https://github.com/uber-go/fx) |
| Event Bus | [Watermill](https://github.com/ThreeDotsLabs/watermill) + NATS JetStream |
| Database | PostgreSQL 17 + [sqlx](https://github.com/jmoiron/sqlx) + [sqlc](https://github.com/sqlc-dev/sqlc) |
| Cache | Redis 7 ([go-redis](https://github.com/redis/go-redis)) |
| Authentication | JWT ([golang-jwt](https://github.com/golang-jwt/jwt)) + bcrypt |
| Observability | OpenTelemetry + Prometheus + Jaeger |
| Logging | [zerolog](https://github.com/rs/zerolog) |
| Validation | [go-playground/validator](https://github.com/go-playground/validator) v10 |
| Testing | testify + httptest + mock repositories |

## Features

- CRUD operations for **Pages**, **Content Categories**, **Contents**, and **Users**
- **Page Variables**: Admin presets JSON template variables per page, users fill content based on those templates
- **Content Publishing Lifecycle**: draft -> published -> archived (with guards against double-publish)
- **JWT Authentication**: Access token (15m) + Refresh token (7d)
- **Role-Based Access Control (RBAC)**: admin / editor / viewer with per-route enforcement
- **CDN Cache Invalidation**: Automatic Redis cache invalidation via domain events
- **Full Observability**: Distributed tracing (Jaeger), metrics (Prometheus), structured logging (zerolog)
- **284 unit tests** covering domain, commands, queries, HTTP handlers, middleware, auth, and error types

## Quick Start

### Prerequisites

- Go 1.25+
- Docker & Docker Compose

### Setup

```bash
# Clone
git clone https://github.com/erickmo/vernon-cms.git
cd vernon-cms

# Copy environment config
cp .env.example .env

# Start infrastructure (PostgreSQL 17, Redis, NATS, Jaeger, Prometheus)
make infra-up

# Run database migrations
make migrate-up

# Start the server (hot reload with air)
make dev

# Or build and run
make build
./bin/vernon-cms
```

The server starts at `http://localhost:8080`.

### Verify

```bash
curl http://localhost:8080/health
# {"status":"ok"}
```

## API Endpoints

### Authentication (Public)

```
POST /api/v1/auth/register    Register a new user (default role: viewer)
POST /api/v1/auth/login       Login, returns access + refresh tokens
POST /api/v1/auth/refresh     Refresh an expired access token
```

### Pages (Protected)

```
GET    /api/v1/pages           List pages          (any role)
GET    /api/v1/pages/:id       Get page by ID      (any role)
POST   /api/v1/pages           Create page         (admin, editor)
PUT    /api/v1/pages/:id       Update page         (admin, editor)
DELETE /api/v1/pages/:id       Delete page         (admin only)
```

### Content Categories (Protected)

```
GET    /api/v1/content-categories           List categories     (any role)
GET    /api/v1/content-categories/:id       Get category        (any role)
POST   /api/v1/content-categories           Create category     (admin, editor)
PUT    /api/v1/content-categories/:id       Update category     (admin, editor)
DELETE /api/v1/content-categories/:id       Delete category     (admin only)
```

### Contents (Protected)

```
GET    /api/v1/contents                List contents       (any role)
GET    /api/v1/contents/:id            Get content by ID   (any role)
GET    /api/v1/contents/slug/:slug     Get content by slug (any role)
POST   /api/v1/contents                Create content      (admin, editor)
PUT    /api/v1/contents/:id            Update content      (admin, editor)
PUT    /api/v1/contents/:id/publish    Publish content     (admin, editor)
DELETE /api/v1/contents/:id            Delete content      (admin only)
```

### Users (Protected - Admin Only)

```
GET    /api/v1/users           List users
GET    /api/v1/users/:id       Get user
POST   /api/v1/users           Create user
PUT    /api/v1/users/:id       Update user
DELETE /api/v1/users/:id       Delete user
```

### Usage Example

```bash
# Register
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"securepass","name":"Admin User"}'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"securepass"}'
# Returns: {"data":{"access_token":"eyJ...","refresh_token":"eyJ...","expires_at":...}}

# Use the access token for protected endpoints
curl http://localhost:8080/api/v1/pages \
  -H "Authorization: Bearer <access_token>"
```

### Response Format

```json
// Success
{ "data": { ... } }

// Error
{ "error": "error message" }
```

| Status Code | Meaning |
|---|---|
| 200 | Success |
| 201 | Resource created |
| 400 | Invalid input |
| 401 | Missing / invalid / expired token |
| 403 | Insufficient role permissions |
| 404 | Resource not found |
| 409 | Duplicate resource (slug, email) |
| 500 | Internal server error |

## Project Structure

```
vernon-cms/
├── cmd/api/                    Entry point, FX wiring, server bootstrap
├── internal/
│   ├── domain/                 Entities, events, repository interfaces (ZERO deps)
│   │   ├── page/
│   │   ├── content_category/
│   │   ├── content/
│   │   └── user/
│   ├── command/                Command handlers (1 folder = 1 command)
│   │   ├── create_page/
│   │   ├── login/
│   │   ├── register/
│   │   └── ...
│   ├── query/                  Query handlers (1 folder = 1 query)
│   │   ├── get_page/
│   │   ├── get_content_by_slug/
│   │   └── ...
│   ├── eventhandler/           Side effects (CDN cache invalidation)
│   └── delivery/http/          HTTP handlers (thin, no business logic)
├── infrastructure/
│   ├── database/               PostgreSQL repository implementations
│   ├── cache/                  Redis client
│   ├── telemetry/              OpenTelemetry + Prometheus metrics
│   └── config/                 Viper configuration
├── pkg/
│   ├── commandbus/             Command bus with hooks + OTel
│   ├── querybus/               Query bus with OTel
│   ├── eventbus/               EventBus interface + InMemory/Watermill
│   ├── auth/                   JWT service + password hashing
│   ├── apperror/               Custom error types (NotFound, Validation, etc.)
│   ├── middleware/             HTTP middleware (auth, RBAC, tracing, logging, CORS, recovery)
│   └── hooks/                  Command lifecycle hooks (logging, validation)
├── migrations/                 PostgreSQL migration files
├── sqlc/                       Type-safe SQL queries
├── tests/
│   ├── mocks/                  In-memory mock repositories
│   ├── unit/                   Unit tests (284 test cases)
│   └── integration/            Integration tests
├── docs/
│   ├── requirements/           PRD document
│   ├── testing/                Testing document
│   └── audit/                  Code audit document
├── docker-compose.yml          PostgreSQL 17, Redis, NATS, Jaeger, Prometheus
├── Dockerfile                  Multi-stage, distroless
└── Makefile                    Build, test, migrate, infra commands
```

## Architecture Rules

1. **Domain layer** has ZERO external dependencies (stdlib + uuid only)
2. **Command handlers** depend only on WriteRepository + EventBus
3. **Query handlers** depend only on ReadRepository + Redis cache
4. **HTTP handlers** depend only on CommandBus + QueryBus
5. Every command/query handler has its own **OpenTelemetry span**
6. Cache invalidation happens via **domain events** (not in handlers)

## Testing

```bash
make test             # Run unit tests (284 test cases)
make test-race        # Run with race detector
make test-integration # Run integration tests (requires Docker)
```

Tests cover:
- Domain entity validation and state transitions
- Command handlers (success, not-found, duplicate, repo errors, event bus failures)
- HTTP handlers (valid/invalid input, malformed JSON, invalid UUIDs, pagination edge cases)
- JWT lifecycle (generate, validate, expiry, wrong key, tamper detection)
- RBAC middleware (admin/editor/viewer permission matrix)
- Custom error type detection
- Middleware (panic recovery, CORS, body size limit)

## Environment Variables

See [`.env.example`](.env.example) for all configurable values:

| Variable | Default | Description |
|---|---|---|
| `HTTP_PORT` | `8080` | Server port |
| `DATABASE_URL` | `postgres://...` | PostgreSQL connection string |
| `REDIS_URL` | `redis://localhost:6379/0` | Redis connection string |
| `JWT_SECRET` | (change in production) | HMAC-SHA256 signing key |
| `JWT_ACCESS_EXPIRY` | `15m` | Access token lifetime |
| `JWT_REFRESH_EXPIRY` | `168h` | Refresh token lifetime (7 days) |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:3000` | Comma-separated allowed origins |

## Observability

| Tool | URL | Purpose |
|---|---|---|
| Jaeger | http://localhost:16686 | Distributed tracing |
| Prometheus | http://localhost:9090 | Metrics |
| NATS Monitoring | http://localhost:8222 | Event bus monitoring |

## Documentation

| Document | Description |
|---|---|
| [PRD](docs/requirements/prd-vernon-cms.md) | Product requirements, domain model, API spec, RBAC |
| [Testing](docs/testing/testing-document.md) | 284 test cases breakdown, robustness coverage matrix |
| [Code Audit](docs/audit/code-audit.md) | Architecture compliance, security review, recommendations |

## License

Private

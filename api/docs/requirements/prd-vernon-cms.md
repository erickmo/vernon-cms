# PRD: Vernon CMS

**Versi:** 1.2.0
**Tanggal:** 2026-03-16
**Status:** In Development
**Stack:** Go 1.25 / Clean Architecture + CQRS + EDA
**Author:** AI-Generated
**Reviewer:** -

---

## 1. Overview

### 1.1 Latar Belakang
Vernon CMS adalah Content Management System yang dibangun untuk mengelola konten halaman web secara dinamis. Admin dapat membuat page dengan template variable (JSON), dan user dapat mengisi konten berdasarkan variable tersebut.

### 1.2 Tujuan
- Menyediakan API REST untuk mengelola pages, categories, contents, dan users
- Admin dapat preset JSON variables sebagai template di setiap Page
- User mengisi konten berdasarkan template variable yang sudah disiapkan admin
- CDN cache otomatis ter-invalidate saat ada perubahan data

### 1.3 Tech Stack

| Komponen | Library/Tool |
|---|---|
| Language | Go 1.23 |
| HTTP Router | Chi v5 |
| Dependency Injection | Uber FX |
| Event Bus | Watermill + NATS JetStream (InMemory fallback) |
| Database | PostgreSQL 17 + sqlx + sqlc |
| Cache | Redis 7 |
| Observability | OpenTelemetry + Prometheus + Jaeger |
| Logging | zerolog (structured, trace-aware) |
| Validation | go-playground/validator v10 |
| Authentication | golang-jwt/jwt v5 (HMAC-SHA256) |
| Password Hashing | bcrypt (golang.org/x/crypto) |
| Config | Viper |
| Testing | testify + httptest + mock repositories |

---

## 2. Domain Model

### 2.1 Entity: Page
| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| id | UUID | PK | Primary key |
| name | VARCHAR(255) | NOT NULL | Nama halaman |
| slug | VARCHAR(255) | UNIQUE, NOT NULL | URL-friendly identifier |
| variables | JSONB | NOT NULL, DEFAULT '{}' | Template variables preset oleh admin |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Status aktif/nonaktif |
| created_at | TIMESTAMPTZ | NOT NULL | Waktu dibuat |
| updated_at | TIMESTAMPTZ | NOT NULL | Waktu terakhir diubah |

**Domain Rules:**
- Name dan slug wajib diisi (tidak boleh kosong)
- Slug harus unik
- Variables default ke `{}` jika tidak diisi
- Page baru otomatis `is_active = true`

### 2.2 Entity: ContentCategory
| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| id | UUID | PK | Primary key |
| name | VARCHAR(255) | NOT NULL | Nama kategori |
| slug | VARCHAR(255) | UNIQUE, NOT NULL | URL-friendly identifier |
| created_at | TIMESTAMPTZ | NOT NULL | Waktu dibuat |
| updated_at | TIMESTAMPTZ | NOT NULL | Waktu terakhir diubah |

**Domain Rules:**
- Name dan slug wajib diisi
- Slug harus unik

### 2.3 Entity: Content
| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| id | UUID | PK | Primary key |
| title | VARCHAR(500) | NOT NULL | Judul konten |
| slug | VARCHAR(500) | UNIQUE, NOT NULL | URL-friendly identifier |
| body | TEXT | NOT NULL, DEFAULT '' | Isi konten lengkap |
| excerpt | TEXT | NOT NULL, DEFAULT '' | Ringkasan konten |
| status | VARCHAR(20) | NOT NULL, CHECK | draft / published / archived |
| page_id | UUID | FK → pages, CASCADE | Referensi ke halaman |
| category_id | UUID | FK → content_categories, CASCADE | Referensi ke kategori |
| author_id | UUID | FK → users, CASCADE | Referensi ke penulis |
| metadata | JSONB | NOT NULL, DEFAULT '{}' | Data tambahan (SEO, tags, dll) |
| published_at | TIMESTAMPTZ | NULLABLE | Waktu pertama kali dipublish |
| created_at | TIMESTAMPTZ | NOT NULL | Waktu dibuat |
| updated_at | TIMESTAMPTZ | NOT NULL | Waktu terakhir diubah |

**Domain Rules:**
- Title dan slug wajib diisi
- Slug harus unik
- Status awal selalu `draft`
- Tidak boleh publish konten yang sudah `published` (double publish guard)
- `published_at` di-set saat pertama kali publish, di-reset saat `ToDraft()`
- Body dan excerpt boleh kosong
- Metadata default ke `{}`

**State Transitions:**
```
draft → published (via Publish)
draft → archived (via Archive)
published → archived (via Archive)
archived → draft (via ToDraft)
archived → published (via Publish)
published → published (BLOCKED - error)
```

### 2.4 Entity: User
| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| id | UUID | PK | Primary key |
| email | VARCHAR(255) | UNIQUE, NOT NULL | Email login |
| password_hash | VARCHAR(255) | NOT NULL | Hash password (tidak di-expose via JSON) |
| name | VARCHAR(255) | NOT NULL | Nama lengkap |
| role | VARCHAR(20) | NOT NULL, CHECK | admin / editor / viewer |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Status aktif |
| created_at | TIMESTAMPTZ | NOT NULL | Waktu dibuat |
| updated_at | TIMESTAMPTZ | NOT NULL | Waktu terakhir diubah |

**Domain Rules:**
- Email, password_hash, dan name wajib diisi
- Email harus unik
- Role default ke `viewer` jika kosong
- User baru otomatis `is_active = true`
- `password_hash` di-tag `json:"-"` (tidak ter-expose di response)

---

## 3. Commands & Queries

### 3.1 Commands (15 total)
| Command | Handler | Event Dipublish | Validasi |
|---|---|---|---|
| Register | internal/command/register/ | user.created | email (valid), password (min 8), name required |
| Login | internal/command/login/ | - | email (valid), password required |
| CreatePage | internal/command/create_page/ | page.created | name, slug required |
| UpdatePage | internal/command/update_page/ | page.updated | name, slug required; page must exist |
| DeletePage | internal/command/delete_page/ | page.deleted | page must exist |
| CreateContentCategory | internal/command/create_content_category/ | content_category.created | name, slug required |
| UpdateContentCategory | internal/command/update_content_category/ | content_category.updated | name, slug required; must exist |
| DeleteContentCategory | internal/command/delete_content_category/ | content_category.deleted | must exist |
| CreateContent | internal/command/create_content/ | content.created | title, slug, page_id, category_id, author_id required |
| UpdateContent | internal/command/update_content/ | content.updated | title, slug required; must exist |
| DeleteContent | internal/command/delete_content/ | content.deleted | must exist |
| PublishContent | internal/command/publish_content/ | content.published | must exist; must not be already published |
| CreateUser | internal/command/create_user/ | user.created | email (valid format), password_hash, name, role (oneof) |
| UpdateUser | internal/command/update_user/ | user.updated | email, name, role required; must exist |
| DeleteUser | internal/command/delete_user/ | user.deleted | must exist |

### 3.2 Queries (9 total)
| Query | Handler | Cache Key | TTL |
|---|---|---|---|
| GetPage | internal/query/get_page/ | page:{id} | 5 menit |
| ListPage | internal/query/list_page/ | - | - |
| GetContentCategory | internal/query/get_content_category/ | content_category:{id} | 5 menit |
| ListContentCategory | internal/query/list_content_category/ | - | - |
| GetContent | internal/query/get_content/ | content:{id} | 5 menit |
| GetContentBySlug | internal/query/get_content_by_slug/ | content:slug:{slug} | 5 menit |
| ListContent | internal/query/list_content/ | - | - |
| GetUser | internal/query/get_user/ | user:{id} | 5 menit |
| ListUser | internal/query/list_user/ | - | - |

**Pagination:** Semua List query mendukung `?page=X&limit=Y` (default: page=1, limit=20)

### 3.3 Side Effects (Event Handlers)
| Event | Handler | Aksi |
|---|---|---|
| page.created/updated/deleted | CDNCacheHandler | Invalidate Redis cache keys `page:*` |
| content_category.created/updated/deleted | CDNCacheHandler | Invalidate Redis cache keys `content_category:*` |
| content.created/updated/published/deleted | CDNCacheHandler | Invalidate Redis cache keys `content:*` |
| user.created/updated/deleted | CDNCacheHandler | Invalidate Redis cache keys `user:*` |

---

## 4. API Endpoints (25 total)

### 4.1 Health (Public)
| Method | Path | Command/Query | Auth | Response |
|---|---|---|---|---|
| GET | /health | - | No | `{"status":"ok"}` |

### 4.2 Authentication (Public)
| Method | Path | Command/Query | Auth | Request Body |
|---|---|---|---|---|
| POST | /api/v1/auth/register | Register | No | `{email, password, name}` |
| POST | /api/v1/auth/login | Login | No | `{email, password}` |
| POST | /api/v1/auth/refresh | - | No | `{refresh_token}` |

**Login Response:**
```json
{
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "expires_at": 1710600000
  }
}
```

### 4.3 Pages (Protected)
| Method | Path | Command/Query | Role Required | Request Body |
|---|---|---|---|---|
| POST | /api/v1/pages | CreatePage | admin, editor | `{name, slug, variables}` |
| GET | /api/v1/pages | ListPage | any | Query: `?page=&limit=` |
| GET | /api/v1/pages/:id | GetPage | any | - |
| PUT | /api/v1/pages/:id | UpdatePage | admin, editor | `{name, slug, variables, is_active}` |
| DELETE | /api/v1/pages/:id | DeletePage | admin | - |

### 4.4 Content Categories (Protected)
| Method | Path | Command/Query | Role Required | Request Body |
|---|---|---|---|---|
| POST | /api/v1/content-categories | CreateContentCategory | admin, editor | `{name, slug}` |
| GET | /api/v1/content-categories | ListContentCategory | any | Query: `?page=&limit=` |
| GET | /api/v1/content-categories/:id | GetContentCategory | any | - |
| PUT | /api/v1/content-categories/:id | UpdateContentCategory | admin, editor | `{name, slug}` |
| DELETE | /api/v1/content-categories/:id | DeleteContentCategory | admin | - |

### 4.5 Contents (Protected)
| Method | Path | Command/Query | Role Required | Request Body |
|---|---|---|---|---|
| POST | /api/v1/contents | CreateContent | admin, editor | `{title, slug, body, excerpt, page_id, category_id, author_id, metadata}` |
| GET | /api/v1/contents | ListContent | any | Query: `?page=&limit=` |
| GET | /api/v1/contents/:id | GetContent | any | - |
| GET | /api/v1/contents/slug/:slug | GetContentBySlug | any | - |
| PUT | /api/v1/contents/:id | UpdateContent | admin, editor | `{title, slug, body, excerpt, metadata}` |
| PUT | /api/v1/contents/:id/publish | PublishContent | admin, editor | - |
| DELETE | /api/v1/contents/:id | DeleteContent | admin | - |

### 4.6 Users (Protected — Admin Only)
| Method | Path | Command/Query | Role Required | Request Body |
|---|---|---|---|---|
| POST | /api/v1/users | CreateUser | admin | `{email, password_hash, name, role}` |
| GET | /api/v1/users | ListUser | admin | Query: `?page=&limit=` |
| GET | /api/v1/users/:id | GetUser | admin | - |
| PUT | /api/v1/users/:id | UpdateUser | admin | `{email, name, role}` |
| DELETE | /api/v1/users/:id | DeleteUser | admin | - |

### 4.6 Response Format
```json
// Success
{ "data": { ... } }

// Error
{ "error": "error message" }
```

### 4.7 HTTP Status Codes
| Code | Digunakan Saat |
|---|---|
| 200 | GET, PUT, DELETE berhasil; Login berhasil |
| 201 | POST berhasil (resource created); Register berhasil |
| 204 | OPTIONS preflight (CORS) |
| 400 | Invalid input (malformed JSON, missing field, invalid UUID, invalid email format, invalid role, ValidationError) |
| 401 | Missing/invalid/expired JWT token; Wrong credentials (UnauthorizedError) |
| 403 | Insufficient role permissions (ForbiddenError) |
| 404 | Resource not found (NotFoundError) |
| 405 | Method not allowed |
| 409 | Duplicate resource (ConflictError — duplicate email, slug) |
| 500 | Internal server error (repo error, event bus failure) |

---

## 5. Non-Functional Requirements

| Kategori | Target | Status |
|---|---|---|
| Response time (p95) | < 50ms | Target |
| Throughput | > 1000 req/s | Target |
| Unit test coverage | >= 80% | Implemented (284 test cases) |
| Integration test | Testcontainers | Scaffold ready |
| Database | PostgreSQL 17 | Implemented |
| Cache | Redis 7 | Implemented |
| Observability | OTel + Prometheus + Jaeger | Implemented |
| Panic recovery | Middleware | Implemented |
| CORS | Configurable origins | Implemented |
| Authentication | JWT (access + refresh) | Implemented |
| Authorization | RBAC (admin/editor/viewer) | Implemented |
| Password hashing | bcrypt | Implemented |
| Body size limit | 1MB max | Implemented |
| Custom error types | NotFound/Validation/Conflict/Unauthorized/Forbidden | Implemented |

---

## 6. Database Migrations

| No | File | Deskripsi |
|---|---|---|
| 001 | create_users | Tabel users dengan index email, role |
| 002 | create_pages | Tabel pages dengan unique index slug |
| 003 | create_content_categories | Tabel content_categories dengan unique index slug |
| 004 | create_contents | Tabel contents dengan FK ke pages, content_categories, users + index status, page_id, category_id, author_id, published_at |

---

## 7. Authentication & Authorization

### 7.1 JWT Token
| Parameter | Value | Configurable |
|---|---|---|
| Algorithm | HMAC-SHA256 | No |
| Access token expiry | 15 menit | `JWT_ACCESS_EXPIRY` |
| Refresh token expiry | 7 hari | `JWT_REFRESH_EXPIRY` |
| Secret key | env `JWT_SECRET` | Yes |
| Issuer | `vernon-cms` | No |

### 7.2 RBAC Permission Matrix
| Resource | Read (GET) | Write (POST/PUT) | Delete |
|---|---|---|---|
| Pages | admin, editor, viewer | admin, editor | admin |
| Content Categories | admin, editor, viewer | admin, editor | admin |
| Contents | admin, editor, viewer | admin, editor | admin |
| Users | admin | admin | admin |

### 7.3 Password
- Hashing: bcrypt with default cost (10)
- Minimum length: 8 characters (validated on register)
- `password_hash` field: `json:"-"` (never exposed in API response)

### 7.4 Security Headers & Limits
| Feature | Value |
|---|---|
| CORS origins | Configurable via `CORS_ALLOWED_ORIGINS` |
| Max request body | 1MB |
| Credentials | `Access-Control-Allow-Credentials: true` |

---

## 8. Open Questions
- [ ] Apakah perlu file/media upload?
- [ ] Apakah perlu versioning untuk content?
- [ ] Apakah perlu soft delete?
- [ ] Apakah perlu audit log?
- [ ] Apakah perlu token blacklist/revocation?

---

## 9. Changelog

| Versi | Tanggal | Perubahan |
|---|---|---|
| 1.0.0 | 2026-03-16 | Initial PRD |
| 1.1.0 | 2026-03-16 | Detail domain rules, state transitions, HTTP status codes, migration list |
| 1.2.0 | 2026-03-16 | JWT auth, RBAC, auth endpoints, custom error types, CORS config, body size limit, 284 test cases |

---
*Di-generate saat project init. Update sesuai perkembangan project.*

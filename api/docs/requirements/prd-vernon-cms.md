# PRD: Vernon CMS

**Versi:** 1.3.0
**Tanggal:** 2026-03-17
**Status:** In Development
**Stack:** Go 1.25 / Clean Architecture + CQRS + EDA
**Author:** AI-Generated
**Reviewer:** -

---

## 1. Overview

### 1.1 Latar Belakang
Vernon CMS adalah Content Management System multi-tenant yang dibangun untuk mengelola konten halaman web secara dinamis. Admin dapat membuat page dengan template variable (JSON), mengelola media, mengatur konfigurasi site, dan memantau aktivitas melalui activity log.

### 1.2 Tujuan
- Menyediakan API REST untuk mengelola pages, categories, contents, users, media, settings, dan API tokens
- Multi-tenancy: setiap site memiliki data yang terisolasi via `site_id`
- Domain Builder (no-code): admin bisa mendefinisikan custom entity types + dynamic CRUD
- CDN cache otomatis ter-invalidate saat ada perubahan data
- Activity log real-time untuk audit trail

### 1.3 Tech Stack

| Komponen | Library/Tool |
|---|---|
| Language | Go 1.23 |
| HTTP Router | Chi v5 |
| Dependency Injection | Uber FX |
| Event Bus | Watermill + NATS JetStream (InMemory fallback) |
| Database | PostgreSQL 17 + sqlx |
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

### 2.1 Entity: User
| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| id | UUID | PK | Primary key |
| email | VARCHAR(255) | UNIQUE, NOT NULL | Email login |
| password_hash | VARCHAR(255) | NOT NULL | Hash password (`json:"-"`) |
| name | VARCHAR(255) | NOT NULL | Nama lengkap |
| role | VARCHAR(20) | NOT NULL, CHECK | admin / editor / viewer |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Status aktif |
| created_at | TIMESTAMPTZ | NOT NULL | Waktu dibuat |
| updated_at | TIMESTAMPTZ | NOT NULL | Waktu diubah |

### 2.2 Entity: Site
| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| id | UUID | PK | Primary key |
| name | VARCHAR(255) | NOT NULL | Nama site |
| slug | VARCHAR(255) | UNIQUE, NOT NULL | Identifier unik |
| custom_domain | VARCHAR(255) | UNIQUE, NULLABLE | Domain kustom |
| is_active | BOOLEAN | DEFAULT true | Status aktif |
| created_at | TIMESTAMPTZ | NOT NULL | Waktu dibuat |
| updated_at | TIMESTAMPTZ | NOT NULL | Waktu diubah |

**Site Members:** Relasi user ↔ site dengan field `role` (admin/editor/viewer) per-site.

### 2.3 Entity: Page
| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| id | UUID | PK | Primary key |
| site_id | UUID | FK → sites | Multi-tenancy |
| name | VARCHAR(255) | NOT NULL | Nama halaman |
| slug | VARCHAR(255) | NOT NULL | URL-friendly identifier |
| variables | JSONB | NOT NULL, DEFAULT '{}' | Template variables |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Status aktif |
| created_at/updated_at | TIMESTAMPTZ | | |

### 2.4 Entity: ContentCategory
| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| id | UUID | PK | Primary key |
| site_id | UUID | FK → sites | Multi-tenancy |
| name | VARCHAR(255) | NOT NULL | Nama kategori |
| slug | VARCHAR(255) | NOT NULL | URL-friendly identifier |

### 2.5 Entity: Content
| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| id | UUID | PK | Primary key |
| site_id | UUID | FK → sites | Multi-tenancy |
| title | VARCHAR(500) | NOT NULL | Judul konten |
| slug | VARCHAR(500) | NOT NULL | URL identifier |
| body | TEXT | DEFAULT '' | Isi konten |
| excerpt | TEXT | DEFAULT '' | Ringkasan |
| status | VARCHAR(20) | CHECK | draft / published / archived |
| page_id | UUID | FK → pages | Referensi halaman |
| category_id | UUID | FK → content_categories | Referensi kategori |
| author_id | UUID | FK → users | Penulis |
| metadata | JSONB | DEFAULT '{}' | SEO, tags, dll |
| published_at | TIMESTAMPTZ | NULLABLE | Waktu publish |

**State Transitions:**
```
draft → published (via Publish)
draft → archived (via Archive)
published → archived (via Archive)
archived → draft (via ToDraft)
```

### 2.6 Entity: DataType (Domain Builder)
Tabel `data_types` + `data_fields` + `data_records`. Mendukung custom entity types yang didefinisikan admin di runtime.

### 2.7 Entity: SiteSettings
| Field | Type | Deskripsi |
|---|---|---|
| id | UUID | PK |
| site_id | UUID | UNIQUE FK → sites |
| site_name | VARCHAR(500) | Nama site |
| site_description/url | TEXT | Info site |
| logo_url/favicon_url | TEXT | Asset branding |
| default_meta_title/description | TEXT | SEO defaults |
| default_og_image | TEXT | OG default |
| primary_color/secondary_color | VARCHAR(20) | Tema warna |
| footer_text | TEXT | Footer |
| google_analytics_id | VARCHAR(100) | Analytics |
| custom_head_code/body_code | TEXT | Custom scripts |
| maintenance_mode | BOOLEAN | Maintenance switch |
| maintenance_message | TEXT | Pesan maintenance |
| updated_at | TIMESTAMPTZ | |

### 2.8 Entity: MediaFile
| Field | Type | Deskripsi |
|---|---|---|
| id | UUID | PK |
| site_id | UUID | FK → sites |
| file_name | VARCHAR | Nama file |
| file_url | TEXT | URL file |
| thumbnail_url | TEXT | URL thumbnail |
| mime_type | VARCHAR | MIME type |
| file_size | BIGINT | Ukuran bytes |
| width/height | INT | Dimensi (gambar) |
| alt/caption | TEXT | Metadata |
| folder | TEXT | Folder organisasi |
| uploaded_by | UUID | FK → users |

### 2.9 Entity: ActivityLog
| Field | Type | Deskripsi |
|---|---|---|
| id | UUID | PK |
| site_id | UUID | FK → sites |
| user_id | UUID | FK → users (nullable) |
| user_name | VARCHAR | Nama user saat aksi |
| action | VARCHAR | created / updated / published / deleted |
| entity_type | VARCHAR | content / page / dll |
| entity_id | UUID | ID entitas |
| entity_title | TEXT | Judul entitas |
| details | TEXT | Detail tambahan |
| ip_address | INET | IP address |
| created_at | TIMESTAMPTZ | Waktu aksi |

### 2.10 Entity: APIToken
| Field | Type | Deskripsi |
|---|---|---|
| id | UUID | PK |
| site_id | UUID | FK → sites |
| name | VARCHAR(255) | Nama token |
| token_hash | VARCHAR(255) | SHA-256 hash (UNIQUE) |
| prefix | VARCHAR(10) | 8 karakter pertama plain token |
| permissions | JSONB | Array string permissions |
| expires_at | TIMESTAMPTZ | Expiry (nullable) |
| last_used_at | TIMESTAMPTZ | Terakhir digunakan |
| is_active | BOOLEAN | Status aktif |
| created_at | TIMESTAMPTZ | |

---

## 3. Commands & Queries

### 3.1 Commands (35 total)

| Command | Handler | Event |
|---|---|---|
| Register | command/register/ | user.created |
| Login | command/login/ | - |
| CreatePage | command/create_page/ | page.created |
| UpdatePage | command/update_page/ | page.updated |
| DeletePage | command/delete_page/ | page.deleted |
| CreateContentCategory | command/create_content_category/ | content_category.created |
| UpdateContentCategory | command/update_content_category/ | content_category.updated |
| DeleteContentCategory | command/delete_content_category/ | content_category.deleted |
| CreateContent | command/create_content/ | content.created |
| UpdateContent | command/update_content/ | content.updated |
| DeleteContent | command/delete_content/ | content.deleted |
| PublishContent | command/publish_content/ | content.published |
| CreateUser | command/create_user/ | user.created |
| UpdateUser | command/update_user/ | user.updated |
| DeleteUser | command/delete_user/ | user.deleted |
| CreateSite | command/create_site/ | site.created |
| UpdateSite | command/update_site/ | site.updated |
| DeleteSite | command/delete_site/ | site.deleted |
| AddSiteMember | command/add_site_member/ | site.member_added |
| RemoveSiteMember | command/remove_site_member/ | site.member_removed |
| UpdateSiteMemberRole | command/update_site_member_role/ | site.member_role_updated |
| CreateData | command/create_data/ | data.created |
| UpdateData | command/update_data/ | data.updated |
| DeleteData | command/delete_data/ | data.deleted |
| CreateDataRecord | command/create_data_record/ | data_record.created |
| UpdateDataRecord | command/update_data_record/ | data_record.updated |
| DeleteDataRecord | command/delete_data_record/ | data_record.deleted |
| UpdateSettings | command/update_settings/ | - |
| UploadMedia | command/upload_media/ | - |
| UpdateMedia | command/update_media/ | - |
| DeleteMedia | command/delete_media/ | - |
| CreateAPIToken | command/create_api_token/ | - |
| UpdateAPIToken | command/update_api_token/ | - |
| DeleteAPIToken | command/delete_api_token/ | - |
| ToggleAPIToken | command/toggle_api_token/ | - |

### 3.2 Queries (25 total)

| Query | Handler | Cache |
|---|---|---|
| GetPage | query/get_page/ | Redis 5m |
| ListPage | query/list_page/ | - |
| GetContentCategory | query/get_content_category/ | Redis 5m |
| ListContentCategory | query/list_content_category/ | - |
| GetContent | query/get_content/ | Redis 5m |
| GetContentBySlug | query/get_content_by_slug/ | Redis 5m |
| ListContent | query/list_content/ | - |
| GetUser | query/get_user/ | Redis 5m |
| ListUser | query/list_user/ | - |
| GetSite | query/get_site/ | - |
| ListSite | query/list_site/ | - |
| ListSiteMember | query/list_site_member/ | - |
| ListData | query/list_data/ | - |
| GetData | query/get_data/ | - |
| ListDataRecord | query/list_data_record/ | - |
| GetDataRecord | query/get_data_record/ | - |
| ListDataRecordOptions | query/list_data_record_options/ | - |
| GetDashboardStats | query/get_dashboard_stats/ | - |
| GetDailyContentStats | query/get_daily_content_stats/ | - |
| GetSettings | query/get_settings/ | - |
| ListMedia | query/list_media/ | - |
| GetMedia | query/get_media/ | - |
| ListMediaFolders | query/list_media_folders/ | - |
| ListActivityLogs | query/list_activity_logs/ | - |
| ListAPITokens | query/list_api_tokens/ | - |

### 3.3 Event Handlers

| Event | Handler | Aksi |
|---|---|---|
| page.*/content.*/content_category.*/user.* | CDNCacheHandler | Invalidate Redis cache |
| data.*/data_record.* | CDNCacheHandler | Invalidate Redis cache |
| content.created/updated/published/deleted | ActivityLogHandler | Insert activity_log |
| page.created/updated/deleted | ActivityLogHandler | Insert activity_log |

---

## 4. API Endpoints (60+ total)

### 4.1 Health (Public)
| Method | Path |
|---|---|
| GET | /health |

### 4.2 Authentication (Public, TenantResolution via X-Site-ID)
| Method | Path | Auth |
|---|---|---|
| POST | /api/v1/auth/register | No |
| POST | /api/v1/auth/login | No |
| POST | /api/v1/auth/refresh | No |

### 4.3 Pages (Protected, RequireTenant)
| Method | Path | Role |
|---|---|---|
| GET | /api/v1/pages | any |
| GET | /api/v1/pages/{id} | any |
| POST | /api/v1/pages | admin, editor |
| PUT | /api/v1/pages/{id} | admin, editor |
| DELETE | /api/v1/pages/{id} | admin |

### 4.4 Content Categories (Protected, RequireTenant)
| Method | Path | Role |
|---|---|---|
| GET | /api/v1/content-categories | any |
| GET | /api/v1/content-categories/{id} | any |
| POST | /api/v1/content-categories | admin, editor |
| PUT | /api/v1/content-categories/{id} | admin, editor |
| DELETE | /api/v1/content-categories/{id} | admin |

### 4.5 Contents (Protected, RequireTenant)
| Method | Path | Role |
|---|---|---|
| GET | /api/v1/contents | any |
| GET | /api/v1/contents/{id} | any |
| GET | /api/v1/contents/slug/{slug} | any |
| POST | /api/v1/contents | admin, editor |
| PUT | /api/v1/contents/{id} | admin, editor |
| PUT | /api/v1/contents/{id}/publish | admin, editor |
| DELETE | /api/v1/contents/{id} | admin |

### 4.6 Domain Builder (Protected, RequireTenant)
| Method | Path | Role |
|---|---|---|
| GET | /api/v1/domains | any |
| GET | /api/v1/domains/{id} | any |
| POST | /api/v1/domains | admin |
| PUT | /api/v1/domains/{id} | admin |
| DELETE | /api/v1/domains/{id} | admin |
| GET | /api/v1/domains/{slug}/records | any |
| GET | /api/v1/domains/{slug}/records/options | any |
| GET | /api/v1/domains/{slug}/records/{id} | any |
| POST | /api/v1/domains/{slug}/records | admin, editor |
| PUT | /api/v1/domains/{slug}/records/{id} | admin, editor |
| DELETE | /api/v1/domains/{slug}/records/{id} | admin |

### 4.7 Dashboard (Protected, RequireTenant) — Flat JSON response
| Method | Path | Query Params |
|---|---|---|
| GET | /api/v1/dashboard/stats | - |
| GET | /api/v1/dashboard/daily-content | `?days=7` |

**Response stats:** `{"total_posts": N, "total_visits": 0, "today_visits": 0, "visit_growth_percent": 0.0}`
**Response daily:** `[{"date": "YYYY-MM-DD", "count": N}, ...]`

### 4.8 Settings (Protected, RequireTenant, admin) — Flat JSON response
| Method | Path | Request Body |
|---|---|---|
| GET | /api/v1/settings | - |
| PUT | /api/v1/settings | `{site_name, site_description, logo_url, ...}` |

### 4.9 Media (Protected, RequireTenant) — Flat JSON response
| Method | Path | Role | Query Params |
|---|---|---|---|
| GET | /api/v1/media | any | `?page=&per_page=&search=&mime_type=&folder=` |
| GET | /api/v1/media/folders | any | - |
| GET | /api/v1/media/{id} | any | - |
| POST | /api/v1/media/upload | admin, editor | JSON body: `{file_name, file_url, mime_type, file_size, ...}` |
| PUT | /api/v1/media/{id} | admin, editor | `{alt, caption, folder}` |
| DELETE | /api/v1/media/{id} | admin | - |

### 4.10 Activity Logs (Protected, RequireTenant) — Flat JSON array
| Method | Path | Query Params |
|---|---|---|
| GET | /api/v1/activity-logs | `?page=&per_page=&search=&action=&entity_type=&user_id=&date_from=&date_to=` |

### 4.11 API Tokens (Protected, RequireTenant, admin) — Flat JSON response
| Method | Path | Request Body |
|---|---|---|
| GET | /api/v1/tokens | - |
| POST | /api/v1/tokens | `{name, permissions, expires_at}` |
| PUT | /api/v1/tokens/{id} | `{name, permissions, expires_at}` |
| DELETE | /api/v1/tokens/{id} | - |
| PUT | /api/v1/tokens/{id}/toggle-active | - |

**Create response includes plain token (ditampilkan sekali saja).**

### 4.12 Users (Protected, admin global role)
| Method | Path | Role |
|---|---|---|
| GET/POST | /api/v1/users | admin |
| GET/PUT/DELETE | /api/v1/users/{id} | admin |

### 4.13 Sites (Protected)
| Method | Path |
|---|---|
| GET/POST | /api/v1/sites |
| GET/PUT/DELETE | /api/v1/sites/{id} |
| GET/POST | /api/v1/sites/{id}/members |
| PUT | /api/v1/sites/{id}/members/{userID}/role |
| DELETE | /api/v1/sites/{id}/members/{userID} |

### 4.14 Response Format

```json
// Endpoint lama (content, pages, users, sites, domains)
{ "data": { ... } }

// Endpoint baru (dashboard, settings, media, activity-logs, tokens)
{ ... }   // flat JSON, no wrapper

// Error (semua endpoint)
{ "error": "error message" }
```

---

## 5. Multi-tenancy

- Setiap request ke tenant-scoped routes wajib menyertakan `X-Site-ID` header (UUID)
- Middleware `TenantResolution` resolve site dari header atau Host
- Middleware `RequireTenant` menolak request jika site tidak ditemukan
- Middleware `RequireSiteRole` validasi `claims.SiteID == context.SiteID` + role check

---

## 6. Non-Functional Requirements

| Kategori | Target | Status |
|---|---|---|
| Response time (p95) | < 50ms | Target |
| Unit test coverage | >= 80% | 334 test cases (core) |
| Database | PostgreSQL 17 | Implemented |
| Cache | Redis 7 | Implemented |
| Observability | OTel + Prometheus + Jaeger | Implemented |
| Panic recovery | Middleware | Implemented |
| CORS | Configurable origins | Implemented |
| Authentication | JWT (access + refresh) | Implemented |
| Authorization | RBAC per-site + global | Implemented |
| Body size limit | 1MB max | Implemented |
| Multi-tenancy | X-Site-ID header | Implemented |

---

## 7. Database Migrations

| No | File | Deskripsi |
|---|---|---|
| 001 | create_users | Tabel users |
| 002 | create_pages | Tabel pages |
| 003 | create_content_categories | Tabel content_categories |
| 004 | create_contents | Tabel contents |
| 005 | create_domains | Tabel data_types, data_fields, data_records |
| 006 | create_sites | Tabel sites, site_members |
| 007 | add_site_id_to_entities | Tambah site_id ke pages, contents, dll |
| 008 | rename_domains_to_data | Rename domains → data_types (+ fields, records) |
| 009 | create_site_settings | Tabel site_settings (UNIQUE per site) |
| 010 | create_media_files | Tabel media_files |
| 011 | create_activity_logs | Tabel activity_logs |
| 012 | create_api_tokens | Tabel api_tokens (permissions JSONB) |

---

## 8. Authentication & Authorization

### 8.1 JWT Token
| Parameter | Value |
|---|---|
| Algorithm | HMAC-SHA256 |
| Access token | 15 menit (`JWT_ACCESS_EXPIRY`) |
| Refresh token | 7 hari (`JWT_REFRESH_EXPIRY`) |
| Claims | user_id, email, role, site_id, site_role |

### 8.2 RBAC Permission Matrix
| Resource | Read | Write | Delete |
|---|---|---|---|
| Pages | any | admin, editor | admin |
| Content | any | admin, editor | admin |
| Users | admin (global) | admin | admin |
| Settings | - | admin | - |
| Media | any | admin, editor | admin |
| Activity Logs | any | - | - |
| API Tokens | admin | admin | admin |
| Domain Builder | any | admin | admin |

---

## 9. Open Questions ✅ Resolved

| Pertanyaan | Status |
|---|---|
| Perlu file/media upload? | ✅ Ya — implemented di `/api/v1/media` |
| Perlu audit log? | ✅ Ya — `activity_logs` table + event handler |
| Perlu API token? | ✅ Ya — `/api/v1/tokens` |
| Perlu settings per-site? | ✅ Ya — `site_settings` table |

### Masih Terbuka
- [ ] Rate limiting (terutama login endpoint)
- [ ] Token blacklist/revocation untuk logout
- [ ] Versioning untuk content
- [ ] Soft delete

---

## 10. Changelog

| Versi | Tanggal | Perubahan |
|---|---|---|
| 1.0.0 | 2026-03-16 | Initial PRD |
| 1.1.0 | 2026-03-16 | JWT auth, RBAC, custom error types, CORS |
| 1.2.0 | 2026-03-16 | Domain Builder, 334 unit test cases |
| 1.3.0 | 2026-03-17 | Multi-tenancy (Sites), Settings, Media, Activity Logs, API Tokens, Dashboard; migrations 009-012; fix path /data → /domains |

---
*Di-generate dan di-update oleh AI. Review sebelum production deploy.*

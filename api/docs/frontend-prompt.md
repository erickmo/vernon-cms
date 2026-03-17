# Prompt: Buatkan Frontend untuk Vernon CMS

## Konteks

Saya sudah punya backend REST API untuk Content Management System bernama **Vernon CMS**, dibangun dengan Go. Saya butuh frontend yang sesuai dengan API ini.

---

## 1. Informasi Umum

- **Base URL API:** `http://localhost:8080`
- **Auth:** JWT Bearer Token (access token 15 menit, refresh token 7 hari)
- **Response format:**
  - Sukses: `{ "data": { ... } }`
  - Error: `{ "error": "pesan error" }`
- **Pagination:** Semua list endpoint mendukung query param `?page=1&limit=20`
- **Role:** 3 role — `admin`, `editor`, `viewer`

---

## 2. Auth Flow

### Register
```
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "minimal8karakter",
  "name": "Nama Lengkap"
}

Response 201:
{ "data": { "status": "registered" } }
```
- User baru otomatis mendapat role `viewer`
- Password minimal 8 karakter
- Email harus unik

### Login
```
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response 200:
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_at": 1710600000
  }
}

Response 401:
{ "error": "invalid email or password" }
```

### Refresh Token
```
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}

Response 200:
{
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "expires_at": 1710601000
  }
}
```

### Cara Pakai Token
Semua endpoint selain `/health` dan `/api/v1/auth/*` membutuhkan header:
```
Authorization: Bearer <access_token>
```

Jika token expired, kirim refresh token ke `/api/v1/auth/refresh` untuk dapat token baru. Jika refresh token juga expired, user harus login ulang.

---

## 3. Role-Based Access Control (RBAC)

| Resource | Read (GET) | Write (POST/PUT) | Delete |
|---|---|---|---|
| Pages | admin, editor, viewer | admin, editor | admin |
| Content Categories | admin, editor, viewer | admin, editor | admin |
| Contents | admin, editor, viewer | admin, editor | admin |
| Users | admin | admin | admin |

- **Admin:** full akses semua fitur
- **Editor:** bisa buat dan edit page, category, content. Tidak bisa delete atau manage user
- **Viewer:** hanya bisa lihat data (read-only)

Di frontend, sembunyikan tombol/menu yang tidak sesuai role. Misalnya viewer tidak perlu lihat tombol "Create" atau "Delete".

---

## 4. Semua API Endpoints

### 4.1 Pages

Page adalah halaman web yang punya **variables** (JSON). Variables ini adalah template field yang di-preset admin — user mengisi konten sesuai template ini.

**Contoh variables:**
```json
{
  "hero_title": "",
  "hero_subtitle": "",
  "hero_image": "",
  "sections": [
    { "type": "text", "fields": { "title": "", "body": "" } },
    { "type": "banner", "fields": { "image": "", "link": "" } }
  ]
}
```

#### Create Page
```
POST /api/v1/pages
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Home Page",
  "slug": "home-page",
  "variables": {
    "hero_title": "",
    "hero_subtitle": "",
    "cta_text": ""
  }
}

Response 201:
{ "data": { "status": "created" } }
```

#### List Pages
```
GET /api/v1/pages?page=1&limit=20
Authorization: Bearer <token>

Response 200:
{
  "data": {
    "items": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "name": "Home Page",
        "slug": "home-page",
        "variables": { "hero_title": "", "hero_subtitle": "" },
        "is_active": true,
        "created_at": "2026-03-16T10:00:00Z",
        "updated_at": "2026-03-16T10:00:00Z"
      }
    ],
    "total": 1,
    "page": 1,
    "limit": 20
  }
}
```

#### Get Page
```
GET /api/v1/pages/:id
Authorization: Bearer <token>

Response 200:
{
  "data": {
    "id": "550e8400-...",
    "name": "Home Page",
    "slug": "home-page",
    "variables": { "hero_title": "", "hero_subtitle": "" },
    "is_active": true,
    "created_at": "2026-03-16T10:00:00Z",
    "updated_at": "2026-03-16T10:00:00Z"
  }
}
```

#### Update Page
```
PUT /api/v1/pages/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Updated Home Page",
  "slug": "home-page",
  "variables": { "hero_title": "", "hero_subtitle": "", "new_field": "" },
  "is_active": true
}

Response 200:
{ "data": { "status": "updated" } }
```

#### Delete Page
```
DELETE /api/v1/pages/:id
Authorization: Bearer <token>

Response 200:
{ "data": { "status": "deleted" } }
```

---

### 4.2 Content Categories

#### Create
```
POST /api/v1/content-categories
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Technology",
  "slug": "technology"
}

Response 201:
{ "data": { "status": "created" } }
```

#### List
```
GET /api/v1/content-categories?page=1&limit=20
Authorization: Bearer <token>

Response 200:
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "Technology",
        "slug": "technology",
        "created_at": "2026-03-16T10:00:00Z",
        "updated_at": "2026-03-16T10:00:00Z"
      }
    ],
    "total": 1,
    "page": 1,
    "limit": 20
  }
}
```

#### Get
```
GET /api/v1/content-categories/:id
Authorization: Bearer <token>

Response 200:
{ "data": { "id": "uuid", "name": "Technology", "slug": "technology", ... } }
```

#### Update
```
PUT /api/v1/content-categories/:id
Authorization: Bearer <token>
Content-Type: application/json

{ "name": "Tech & Science", "slug": "tech-science" }

Response 200:
{ "data": { "status": "updated" } }
```

#### Delete
```
DELETE /api/v1/content-categories/:id
Authorization: Bearer <token>

Response 200:
{ "data": { "status": "deleted" } }
```

---

### 4.3 Contents

Content punya **status lifecycle**: `draft` → `published` → `archived`

#### Create (status awal selalu `draft`)
```
POST /api/v1/contents
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Getting Started with Go",
  "slug": "getting-started-with-go",
  "body": "<p>Full article content here...</p>",
  "excerpt": "A beginner's guide to Go programming",
  "page_id": "uuid-of-page",
  "category_id": "uuid-of-category",
  "author_id": "uuid-of-user",
  "metadata": {
    "seo_title": "Learn Go Programming",
    "seo_description": "Complete guide...",
    "tags": ["go", "programming", "tutorial"]
  }
}

Response 201:
{ "data": { "status": "created" } }
```

#### List
```
GET /api/v1/contents?page=1&limit=20
Authorization: Bearer <token>

Response 200:
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "title": "Getting Started with Go",
        "slug": "getting-started-with-go",
        "excerpt": "A beginner's guide...",
        "status": "draft",
        "page_id": "uuid",
        "category_id": "uuid",
        "author_id": "uuid",
        "metadata": { "tags": ["go"] },
        "published_at": null,
        "created_at": "2026-03-16T10:00:00Z"
      }
    ],
    "total": 1,
    "page": 1,
    "limit": 20
  }
}
```

#### Get by ID
```
GET /api/v1/contents/:id
Authorization: Bearer <token>

Response 200:
{
  "data": {
    "id": "uuid",
    "title": "Getting Started with Go",
    "slug": "getting-started-with-go",
    "body": "<p>Full article content...</p>",
    "excerpt": "A beginner's guide...",
    "status": "draft",
    "page_id": "uuid",
    "category_id": "uuid",
    "author_id": "uuid",
    "metadata": { "seo_title": "...", "tags": ["go"] },
    "published_at": null,
    "created_at": "2026-03-16T10:00:00Z",
    "updated_at": "2026-03-16T10:00:00Z"
  }
}
```

#### Get by Slug
```
GET /api/v1/contents/slug/:slug
Authorization: Bearer <token>

Response sama seperti Get by ID
```

#### Update
```
PUT /api/v1/contents/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Title",
  "slug": "updated-slug",
  "body": "<p>Updated body...</p>",
  "excerpt": "Updated excerpt",
  "metadata": { "tags": ["go", "updated"] }
}

Response 200:
{ "data": { "status": "updated" } }
```

#### Publish (draft → published)
```
PUT /api/v1/contents/:id/publish
Authorization: Bearer <token>

Response 200:
{ "data": { "status": "published" } }

Response 500 (jika sudah published):
{ "error": "content is already published" }
```

#### Delete
```
DELETE /api/v1/contents/:id
Authorization: Bearer <token>

Response 200:
{ "data": { "status": "deleted" } }
```

---

### 4.4 Users (Admin Only)

#### Create
```
POST /api/v1/users
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "email": "editor@example.com",
  "password_hash": "already_hashed_password",
  "name": "Editor User",
  "role": "editor"
}

Response 201:
{ "data": { "status": "created" } }
```
Note: Endpoint ini untuk admin membuat user dengan role tertentu. Untuk registrasi publik, gunakan `/api/v1/auth/register`.

#### List
```
GET /api/v1/users?page=1&limit=20
Authorization: Bearer <admin_token>

Response 200:
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "email": "editor@example.com",
        "name": "Editor User",
        "role": "editor",
        "is_active": true,
        "created_at": "2026-03-16T10:00:00Z"
      }
    ],
    "total": 1,
    "page": 1,
    "limit": 20
  }
}
```
Note: `password_hash` TIDAK pernah muncul di response (di-hide via `json:"-"`).

#### Get
```
GET /api/v1/users/:id
Authorization: Bearer <admin_token>

Response 200:
{
  "data": {
    "id": "uuid",
    "email": "editor@example.com",
    "name": "Editor User",
    "role": "editor",
    "is_active": true,
    "created_at": "2026-03-16T10:00:00Z",
    "updated_at": "2026-03-16T10:00:00Z"
  }
}
```

#### Update
```
PUT /api/v1/users/:id
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "email": "newemail@example.com",
  "name": "Updated Name",
  "role": "admin"
}

Response 200:
{ "data": { "status": "updated" } }
```

#### Delete
```
DELETE /api/v1/users/:id
Authorization: Bearer <admin_token>

Response 200:
{ "data": { "status": "deleted" } }
```

---

## 5. Error Responses

Semua error response menggunakan format yang sama:
```json
{ "error": "pesan error" }
```

| HTTP Code | Kapan Muncul | Contoh Error Message |
|---|---|---|
| 400 | Input tidak valid | `"invalid request body"`, `"Key: 'Command.Name' Error:Field validation..."` |
| 401 | Token hilang/invalid/expired | `"missing authorization header"`, `"invalid or expired token"`, `"invalid email or password"` |
| 403 | Role tidak cukup | `"insufficient permissions"` |
| 404 | Data tidak ditemukan | `"page not found: <uuid>"` |
| 409 | Duplikat (slug/email) | `"duplicate slug: home-page"`, `"duplicate email: user@test.com"` |
| 500 | Error internal server | `"content is already published"`, error database, dll |

---

## 6. Kebutuhan UI

### Halaman yang Dibutuhkan

1. **Login Page** — Form email + password, redirect ke dashboard setelah login
2. **Register Page** — Form email + password + name
3. **Dashboard** — Overview (jumlah pages, categories, contents, users)
4. **Pages**
   - List: tabel dengan search, pagination, tombol create/edit/delete (sesuai role)
   - Create/Edit form: name, slug (auto-generate dari name), JSON editor untuk variables, toggle is_active
5. **Content Categories**
   - List: tabel dengan pagination
   - Create/Edit form: name, slug
6. **Contents**
   - List: tabel dengan filter status (draft/published/archived), pagination
   - Create/Edit form: title, slug, rich text editor untuk body, excerpt, pilih page (dropdown), pilih category (dropdown), metadata JSON editor
   - Tombol "Publish" (tampil hanya jika status = draft)
   - Status badge berwarna (draft=gray, published=green, archived=red)
7. **Users** (hanya tampil untuk admin)
   - List: tabel dengan pagination
   - Create/Edit form: email, name, role (dropdown: admin/editor/viewer), toggle is_active

### Fitur UI

- **Auto-refresh token**: Jika access token expired (401), otomatis refresh menggunakan refresh_token, lalu retry request. Jika refresh juga gagal, redirect ke login
- **Role-aware UI**: Sembunyikan menu/tombol yang tidak sesuai role user yang login
- **Slug auto-generate**: Saat user mengetik name/title, otomatis generate slug (lowercase, spasi → dash)
- **Pagination controls**: Previous/Next, page number, items per page selector
- **Toast notifications**: Tampilkan notifikasi sukses/error setelah create/update/delete
- **Confirmation dialog**: Konfirmasi sebelum delete
- **Loading states**: Skeleton loader saat fetch data
- **Responsive**: Mobile-friendly

### JWT Token Info (untuk decode di frontend)

Access token JWT payload berisi:
```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "role": "admin",
  "iss": "vernon-cms",
  "sub": "uuid",
  "exp": 1710600000,
  "iat": 1710599100,
  "jti": "unique-token-id"
}
```
Bisa decode payload (base64) untuk mendapatkan `role`, `email`, `user_id` tanpa perlu API call tambahan.

---

## 7. Catatan Teknis

- Semua ID menggunakan UUID v4 (format: `550e8400-e29b-41d4-a716-446655440000`)
- Timestamp format: RFC 3339 (`2026-03-16T10:00:00Z`)
- `published_at` bisa `null` (jika belum pernah dipublish)
- `variables` dan `metadata` adalah JSON object yang fleksibel (tidak ada schema tetap)
- Max request body: 1MB
- CORS sudah dikonfigurasi di backend, default allow `http://localhost:3000`

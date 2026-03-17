# Backend Development Requests — Vernon CMS API

**Tanggal:** 2026-03-17
**Status:** Pending Implementation
**Frontend Ready:** ✅ UI pages sudah dibuat, menunggu endpoint backend
**Base URL:** `{API_BASE_URL}/api/v1`

---

## 1. Settings Management

### Requirement
Halaman Settings untuk konfigurasi global CMS (SEO, tampilan, integrasi, maintenance mode).

### Frontend Route
- **GET** `/settings` → Halaman Settings
- **PUT** `/api/v1/settings` → Update konfigurasi

### Endpoints Dibutuhkan

#### GET /api/v1/settings
**Deskripsi:** Ambil semua konfigurasi global CMS

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "id": "settings_1",
    "siteName": "Vernon CMS",
    "siteDescription": "Content Management System",
    "siteUrl": "https://cms.vernon.com",
    "maintenanceMode": false,
    "maintenanceMessage": "Sistem sedang dalam maintenance",
    "adminEmail": "admin@vernon.com",

    // SEO Settings
    "defaultMetaDescription": "Deskripsi default untuk halaman",
    "defaultOgImage": "https://cdn.vernon.com/og-default.jpg",

    // Email Settings
    "emailProvider": "smtp", // atau "sendgrid", "mailgun"
    "emailFromName": "Vernon CMS",
    "emailFromAddress": "noreply@vernon.com",

    // Integrasi
    "analyticsCode": "UA-XXXXXXXXX-X",
    "gtmCode": "GTM-XXXXXX",

    // Tampilan
    "accentColor": "#4D2975",
    "logoUrl": "https://cdn.vernon.com/logo.png",
    "faviconUrl": "https://cdn.vernon.com/favicon.ico",

    // Upload Settings
    "maxUploadSize": 52428800, // 50MB in bytes
    "allowedFileTypes": ["jpg", "jpeg", "png", "gif", "pdf", "doc", "docx"],
    "enableImageCompression": true,
    "imageCompressionQuality": 80,

    // API Settings
    "enableApiAccess": true,
    "apiRateLimit": 1000, // per jam
    "apiTokenExpiration": 30, // hari

    "createdAt": "2024-01-15T10:00:00Z",
    "updatedAt": "2026-03-17T12:30:00Z"
  }
}
```

**Response Error (401/403/500):**
```json
{
  "success": false,
  "message": "Unauthorized" atau "Internal Server Error"
}
```

---

#### PUT /api/v1/settings
**Deskripsi:** Update konfigurasi global CMS (all fields optional)

**Request Body:**
```json
{
  "siteName": "Vernon CMS Updated",
  "siteDescription": "Updated description",
  "siteUrl": "https://cms-new.vernon.com",
  "maintenanceMode": true,
  "maintenanceMessage": "Maintenance dimulai pukul 14:00",
  "adminEmail": "newadmin@vernon.com",
  "defaultMetaDescription": "New default meta",
  "defaultOgImage": "https://cdn.vernon.com/og-new.jpg",
  "emailFromName": "Vernon Admin",
  "emailFromAddress": "admin@vernon.com",
  "analyticsCode": "UA-NEW-CODE",
  "gtmCode": "GTM-NEW",
  "accentColor": "#FF5733",
  "logoUrl": "https://cdn.vernon.com/logo-v2.png",
  "faviconUrl": "https://cdn.vernon.com/favicon-v2.ico",
  "maxUploadSize": 104857600,
  "allowedFileTypes": ["jpg", "jpeg", "png", "gif", "pdf"],
  "enableImageCompression": true,
  "imageCompressionQuality": 75,
  "enableApiAccess": true,
  "apiRateLimit": 2000,
  "apiTokenExpiration": 60
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Pengaturan berhasil diupdate",
  "data": {
    // same as GET response dengan nilai yang diupdate
  }
}
```

**Response Error (400/401/403/500):**
```json
{
  "success": false,
  "message": "Validation error: siteName is required" atau error lainnya
}
```

**Auth Required:** ✅ Yes (admin only)

---

## 2. Activity Log Management

### Requirement
Halaman Activity Log untuk melihat riwayat semua perubahan di CMS (who did what when).

### Frontend Route
- **GET** `/activity-logs` → Halaman Activity Log

### Endpoints Dibutuhkan

#### GET /api/v1/activity-logs
**Deskripsi:** Ambil daftar activity log dengan pagination, filter, dan sorting

**Query Parameters:**
```
GET /api/v1/activity-logs?page=1&limit=50&entityType=content&action=create&userId=user_123&sortBy=createdAt&sortOrder=desc&startDate=2026-01-01&endDate=2026-03-17
```

| Parameter | Type | Required | Deskripsi |
|---|---|---|---|
| `page` | integer | No | Halaman (default: 1) |
| `limit` | integer | No | Item per halaman (default: 50, max: 200) |
| `entityType` | string | No | Filter by tipe entity (`content`, `page`, `user`, `domain`, `setting`, `media`, `token`, dll) |
| `action` | string | No | Filter by action (`create`, `update`, `delete`, `publish`, `unpublish`) |
| `userId` | string | No | Filter by user ID |
| `sortBy` | string | No | Sort field (`createdAt`, `entityType`, `action`) |
| `sortOrder` | string | No | Sort order (`asc`, `desc`) |
| `startDate` | string (ISO8601) | No | Filter dari tanggal (inclusive) |
| `endDate` | string (ISO8601) | No | Filter hingga tanggal (inclusive) |

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "log_abc123",
        "entityType": "content", // content, page, user, domain, media, token, setting
        "entityId": "content_456",
        "entityName": "Flutter Tips & Tricks",
        "action": "update", // create, update, delete, publish, unpublish, restore
        "userId": "user_xyz",
        "userName": "Admin User",
        "userEmail": "admin@vernon.com",
        "description": "Mengupdate judul konten dan publish",
        "changes": {
          "before": {
            "title": "Flutter Tips",
            "status": "draft"
          },
          "after": {
            "title": "Flutter Tips & Tricks",
            "status": "published"
          }
        },
        "ipAddress": "192.168.1.100",
        "userAgent": "Mozilla/5.0...",
        "createdAt": "2026-03-17T10:30:00Z"
      },
      {
        "id": "log_def789",
        "entityType": "page",
        "entityId": "page_789",
        "entityName": "Contact Us",
        "action": "create",
        "userId": "user_xyz",
        "userName": "Admin User",
        "userEmail": "admin@vernon.com",
        "description": "Membuat halaman baru",
        "changes": null,
        "ipAddress": "192.168.1.100",
        "userAgent": "Mozilla/5.0...",
        "createdAt": "2026-03-17T09:15:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 50,
      "total": 1234,
      "totalPages": 25,
      "hasNextPage": true,
      "hasPrevPage": false
    }
  }
}
```

**Response Error (401/403/500):**
```json
{
  "success": false,
  "message": "Unauthorized atau error lainnya"
}
```

**Auth Required:** ✅ Yes (can be viewed by admin and user with permission)

**Implementation Notes:**
- Activity log HARUS dicatat otomatis untuk setiap action: create, update, delete, publish, unpublish
- Simpan `changes` (before/after) untuk operasi update agar bisa track perubahan detail
- Simpan `ipAddress` dan `userAgent` untuk audit trail
- Jangan hapus log — hanya soft delete jika diperlukan
- Index database pada kolom: `createdAt`, `entityType`, `action`, `userId` untuk performa query

---

## 3. API Token Management

### Requirement
Halaman API Token untuk manage API access tokens dengan permissions control.

### Frontend Routes
- **GET** `/api-tokens` → Daftar tokens
- **POST** `/api-tokens` → Buat token baru
- **PUT** `/api-tokens/{tokenId}` → Update token
- **DELETE** `/api-tokens/{tokenId}` → Hapus token

### Endpoints Dibutuhkan

#### GET /api/v1/tokens
**Deskripsi:** Ambil daftar API tokens milik user yang login (atau semua jika admin)

**Query Parameters:**
```
GET /api/v1/tokens?page=1&limit=20&status=active&sortBy=createdAt&sortOrder=desc
```

| Parameter | Type | Required |
|---|---|---|
| `page` | integer | No |
| `limit` | integer | No |
| `status` | string | No | `active`, `revoked`, `expired` |
| `sortBy` | string | No | `createdAt`, `expiresAt`, `lastUsedAt` |
| `sortOrder` | string | No | `asc`, `desc` |

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "token_abc123",
        "name": "Mobile App Token",
        "token": "ver_live_abc123def456...", // hanya tampilkan di create response, bukan di list
        "prefix": "ver_live_abc...", // tampilkan di list untuk identifikasi
        "description": "Token untuk mobile app v2",
        "permissions": ["content:read", "content:write", "page:read", "media:read", "media:write"],
        "status": "active", // active, revoked, expired
        "expiresAt": "2027-03-17T00:00:00Z",
        "lastUsedAt": "2026-03-17T10:30:00Z",
        "lastUsedIp": "203.0.113.45",
        "usageCount": 1234,
        "createdAt": "2026-03-17T00:00:00Z",
        "revokedAt": null,
        "revokedBy": null
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 5,
      "totalPages": 1,
      "hasNextPage": false
    }
  }
}
```

---

#### POST /api/v1/tokens
**Deskripsi:** Buat API token baru

**Request Body:**
```json
{
  "name": "Mobile App Token",
  "description": "Token untuk mobile app v2",
  "permissions": ["content:read", "content:write", "page:read", "media:read"],
  "expiresAt": "2027-03-17T00:00:00Z" // optional, null = never expire (with warning)
}
```

**Available Permissions:**
```
// Content
content:read          - Read konten
content:write         - Create/update konten
content:delete        - Delete konten
content:publish       - Publish konten

// Pages
page:read             - Read halaman
page:write            - Create/update halaman
page:delete           - Delete halaman

// Media
media:read            - Read media
media:write           - Upload media
media:delete          - Delete media

// Domains (custom entities)
domain:read           - Read domain records
domain:write          - Create/update domain records
domain:delete         - Delete domain records

// Users
user:read             - Read user data
user:write            - Create/update user
user:delete           - Delete user

// Activity Log
log:read              - Read activity log

// Settings
settings:read         - Read settings
settings:write        - Update settings
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "Token berhasil dibuat. Simpan token ini di tempat aman!",
  "data": {
    "id": "token_abc123",
    "name": "Mobile App Token",
    "token": "ver_live_abc123def456ghi789jkl012mno345pqr678stu901vwx234yz", // ONLY returned once at creation
    "prefix": "ver_live_abc...",
    "description": "Token untuk mobile app v2",
    "permissions": ["content:read", "content:write", "page:read", "media:read"],
    "expiresAt": "2027-03-17T00:00:00Z",
    "createdAt": "2026-03-17T12:00:00Z"
  }
}
```

**Response Error (400/401/403/500):**
```json
{
  "success": false,
  "message": "Token name is required atau validation error lainnya"
}
```

---

#### PUT /api/v1/tokens/{tokenId}
**Deskripsi:** Update token (name, description, permissions, expiration)

**Request Body:**
```json
{
  "name": "Mobile App Token v3",
  "description": "Updated description",
  "permissions": ["content:read", "page:read", "media:read"],
  "expiresAt": "2028-03-17T00:00:00Z"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Token berhasil diupdate",
  "data": {
    // same structure as POST response
  }
}
```

---

#### DELETE /api/v1/tokens/{tokenId}
**Deskripsi:** Revoke / hapus token (soft delete / mark as revoked)

**Response Success (200):**
```json
{
  "success": true,
  "message": "Token berhasil dihapus dan tidak dapat digunakan lagi"
}
```

---

#### GET /api/v1/tokens/{tokenId}
**Deskripsi:** Ambil detail token tertentu

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    // same as list item
  }
}
```

**Auth Required:** ✅ Yes (user hanya bisa lihat/manage token milik sendiri, admin bisa manage semua)

**Implementation Notes:**
- Token diprefiks dengan `ver_live_` untuk production (bisa `ver_test_` untuk test environment)
- JANGAN return full token value saat list/get detail — hanya prefixnya
- Token value HANYA dikembalikan saat create (sekali saja)
- Implementasi rate limiting per token berdasarkan `permissions` dan `usageCount`
- Track `lastUsedAt` dan `lastUsedIp` untuk security audit
- Support token expiration — reject request dengan token yang sudah expired

---

## 4. Media Manager Improvements

### Current Issue
- Media list, upload, dan media picker belum terintegrasi dengan backend
- Frontend siap, hanya butuh endpoint API

### Endpoints Dibutuhkan

#### GET /api/v1/media
**Deskripsi:** Ambil daftar media dengan pagination dan filter

**Query Parameters:**
```
GET /api/v1/media?page=1&limit=20&type=image&search=banner&sortBy=createdAt&sortOrder=desc
```

| Parameter | Type | Required | Deskripsi |
|---|---|---|---|
| `page` | integer | No | Halaman (default: 1) |
| `limit` | integer | No | Item per halaman (default: 20, max: 100) |
| `type` | string | No | Filter by type: `image`, `video`, `pdf`, `document`, atau `all` |
| `search` | string | No | Search by filename atau alt text |
| `sortBy` | string | No | `createdAt`, `name`, `size` |
| `sortOrder` | string | No | `asc`, `desc` |

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "media_abc123",
        "name": "hero-banner.jpg",
        "type": "image", // image, video, pdf, document, etc
        "mimeType": "image/jpeg",
        "url": "https://cdn.vernon.com/media/hero-banner.jpg",
        "size": 245823, // bytes
        "width": 1920, // untuk image
        "height": 1080, // untuk image
        "altText": "Hero banner untuk homepage",
        "uploadedBy": "user_xyz",
        "uploadedByName": "Admin User",
        "createdAt": "2026-03-10T14:30:00Z",
        "updatedAt": "2026-03-10T14:30:00Z"
      },
      {
        "id": "media_def456",
        "name": "product-demo.mp4",
        "type": "video",
        "mimeType": "video/mp4",
        "url": "https://cdn.vernon.com/media/product-demo.mp4",
        "size": 52428800,
        "duration": 120, // seconds untuk video
        "uploadedBy": "user_xyz",
        "uploadedByName": "Admin User",
        "createdAt": "2026-03-15T10:00:00Z",
        "updatedAt": "2026-03-15T10:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3,
      "hasNextPage": true,
      "hasPrevPage": false
    }
  }
}
```

---

#### POST /api/v1/media/upload
**Deskripsi:** Upload satu atau lebih file media

**Request:** multipart/form-data
```
Content-Type: multipart/form-data

file: <binary file data>
altText: "Deskripsi gambar"
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "File berhasil diupload",
  "data": {
    "id": "media_abc123",
    "name": "my-image.jpg",
    "type": "image",
    "mimeType": "image/jpeg",
    "url": "https://cdn.vernon.com/media/my-image.jpg",
    "size": 102400,
    "width": 1200,
    "height": 800,
    "altText": "Deskripsi gambar",
    "createdAt": "2026-03-17T12:00:00Z"
  }
}
```

**Response Error (400/413/500):**
```json
{
  "success": false,
  "message": "File size exceeds maximum allowed size (50MB)" atau error lainnya,
  "data": null
}
```

---

#### PUT /api/v1/media/{mediaId}
**Deskripsi:** Update metadata media (nama, alt text, dll)

**Request Body:**
```json
{
  "name": "hero-banner-v2.jpg",
  "altText": "Updated alt text"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Media berhasil diupdate",
  "data": {
    // same as GET response
  }
}
```

---

#### DELETE /api/v1/media/{mediaId}
**Deskripsi:** Hapus media file

**Response Success (200):**
```json
{
  "success": true,
  "message": "Media berhasil dihapus"
}
```

**Response Error (404/500):**
```json
{
  "success": false,
  "message": "Media not found atau error lainnya"
}
```

---

#### GET /api/v1/media/{mediaId}
**Deskripsi:** Ambil detail media tertentu

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    // same as list item
  }
}
```

---

## Testing & Integration

### cURL Examples untuk Testing

**Get Settings:**
```bash
curl -X GET http://localhost:3000/api/v1/settings \
  -H "Authorization: Bearer {token}"
```

**Update Settings:**
```bash
curl -X PUT http://localhost:3000/api/v1/settings \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"siteName":"New Name","maintenanceMode":true}'
```

**Get Activity Logs:**
```bash
curl -X GET "http://localhost:3000/api/v1/activity-logs?page=1&limit=50&entityType=content" \
  -H "Authorization: Bearer {token}"
```

**Create API Token:**
```bash
curl -X POST http://localhost:3000/api/v1/tokens \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Mobile App",
    "description":"Token untuk mobile app",
    "permissions":["content:read","media:read"],
    "expiresAt":"2027-03-17T00:00:00Z"
  }'
```

**Upload Media:**
```bash
curl -X POST http://localhost:3000/api/v1/media/upload \
  -H "Authorization: Bearer {token}" \
  -F "file=@/path/to/image.jpg" \
  -F "altText=Image description"
```

---

## Summary of Missing Endpoints

| Endpoint | Method | Priority | Status |
|---|---|---|---|
| GET /api/v1/settings | GET | High | ❌ Needed |
| PUT /api/v1/settings | PUT | High | ❌ Needed |
| GET /api/v1/activity-logs | GET | High | ❌ Needed |
| GET /api/v1/tokens | GET | High | ❌ Needed |
| POST /api/v1/tokens | POST | High | ❌ Needed |
| PUT /api/v1/tokens/{id} | PUT | High | ❌ Needed |
| DELETE /api/v1/tokens/{id} | DELETE | High | ❌ Needed |
| GET /api/v1/media | GET | High | ❌ Needed |
| POST /api/v1/media/upload | POST | High | ❌ Needed |
| PUT /api/v1/media/{id} | PUT | Medium | ❌ Needed |
| DELETE /api/v1/media/{id} | DELETE | Medium | ❌ Needed |

---

## Acceptance Criteria

✅ When all endpoints above are implemented:
- [ ] Settings page dapat menampilkan dan update konfigurasi global
- [ ] Activity log page menampilkan riwayat semua perubahan dengan filter & sort
- [ ] API token page dapat CRUD tokens dengan permission control
- [ ] Media manager dapat upload, list, dan manage media files
- [ ] Semua endpoint return standardized response format (success, message, data)
- [ ] Proper error handling dengan status code yang sesuai (400, 401, 403, 404, 500)
- [ ] Authentication required pada semua endpoint
- [ ] Support pagination untuk list endpoints

---

**Questions untuk Backend Team:**
1. Apakah sudah ada database schema untuk activity log? Jika belum, perlu dibuat untuk track semua changes
2. Untuk image upload, apakah ada image processing (resize, compress) atau langsung store as-is?
3. API token expiration — apakah otomatis revoke saat expired atau manual check saat request?
4. Media file storage — apakah local storage atau cloud (S3, GCS, dll)?
5. Settings — apakah per-domain atau global untuk seluruh CMS?

---

**Frontend UI Status:** ✅ Ready for all 4 features (Settings, Activity Log, API Token, Media Manager)
**Backend Status:** ❌ Pending implementation
**Timeline:** Akan integrate segera setelah endpoint diimplementasikan

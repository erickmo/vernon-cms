# PRD: Vernon CMS UI

**Versi:** 1.0.0
**Tanggal:** 2026-03-16
**Status:** Implemented
**Stack:** Flutter Web (PWA)
**Author:** AI-Generated

---

## 1. Overview

### 1.1 Latar Belakang
Vernon CMS membutuhkan web UI yang powerful untuk mengelola konten, halaman, media, dan custom data types secara no-code.

### 1.2 Tujuan Produk
Menyediakan antarmuka web CMS yang lengkap, responsif, dan extensible dengan fitur domain builder untuk membuat custom entity types tanpa coding.

### 1.3 Target Pengguna
| Role | Deskripsi | Permissions |
|---|---|---|
| Super Admin | Akses penuh ke seluruh sistem | Semua |
| Admin | Mengelola konten, user, dan konfigurasi | Semua kecuali system settings |
| Editor | Membuat dan mengedit konten | Content CRUD, Media |
| Viewer | Melihat konten saja | Read-only |

---

## 2. Fitur Utama

| # | Fitur | Prioritas | Status | Route |
|---|---|---|---|---|
| 1 | Auth (Login + Forgot Password) | High | Done | `/login`, `/forgot-password` |
| 2 | Dashboard (Stats + Chart) | High | Done | `/dashboard` |
| 3 | Content Management (CRUD) | High | Done | `/content/*` |
| 4 | Content Category (CRUD) | High | Done | `/content-category` |
| 5 | Page Management (CRUD) | High | Done | `/pages/*` |
| 6 | Domain Builder (No-code Schema) | High | Done | `/domain-builder/*` |
| 7 | Domain Records (Dynamic CRUD) | High | Done | `/domain/:slug/*` |
| 8 | Media Manager | Medium | Done | `/media` |
| 9 | User Management | Medium | Done | `/users/*` |
| 10 | Global Settings | Medium | Done | `/settings` |
| 11 | Activity Log | Low | Done | `/activity-logs` |
| 12 | API Token Management | Low | Done | `/api-tokens` |

---

## 3. Detail Fitur

### 3.1 Auth
- Login dengan username + password
- Remember me (simpan username)
- Forgot password (kirim link reset via email)
- JWT token management (access + refresh)

### 3.2 Dashboard
- Stats cards: Total Post, Total Kunjungan, Kunjungan Hari Ini (+ growth %)
- Bar chart: konten per hari (7 hari terakhir)

### 3.3 Content Management
- CRUD artikel dengan 30+ fields
- Publishing workflow: draft → published → archived
- Visibility: public, private, password_protected
- SEO: meta title/description, canonical URL, noindex/nofollow
- Open Graph: og:title, og:description, og:image
- Media: featured image, thumbnail
- Tags, categories, templates
- Featured & pinned flags
- Version tracking
- Filter: search, status, category

### 3.4 Content Category
- CRUD dengan hierarchy (parent-child)
- Fields: name, slug, description, icon, color, image
- SEO: meta title/description
- Visibility & featured flags
- Content count (denormalized)

### 3.5 Page Management
- CRUD halaman CMS dengan 35+ fields
- Hero section: title, subtitle, image, CTA button
- SEO & Open Graph fields
- Layout settings: show header/footer/breadcrumbs, template, custom CSS
- Navigation: parent page, sort order, show in nav, nav label
- Redirect support (301/302)

### 3.6 Domain Builder (No-code)
- Admin membuat custom entity types (seperti Frappe DocType)
- Define fields: text, textarea, number, email, url, phone, date, select, checkbox, image, rich text, relation
- Select fields: configurable options (label + value)
- Relation fields: link ke domain lain
- Sidebar integration: pilih section (content/pages/custom) + sort order
- Reorderable field list

### 3.7 Domain Records
- Dynamic CRUD berdasarkan domain definition
- Auto-generate DataTable columns dari field definitions
- Auto-generate form fields via DynamicFieldWidget
- Relation field: dropdown populated dari domain terkait
- Search + pagination

### 3.8 Media Manager
- Grid view dengan responsive layout (4/3/2 columns)
- Filter: search, MIME type, folder
- Upload via URL
- Detail dialog: preview, edit metadata (alt, caption, folder), copy URL
- Reusable MediaPickerDialog untuk integrasi form lain
- MIME type icons (image, PDF, doc, video)
- File size formatting (KB/MB)

### 3.9 User Management
- CRUD users dengan 4 role levels
- Role chips: super_admin (red), admin (blue), editor (green), viewer (info)
- Toggle active/inactive
- Admin reset password
- Filter: search, role, status
- Two-column form: user info + settings sidebar

### 3.10 Global Settings
- Single form page dengan 5 sections:
  - Umum: site name, description, URL, logo, favicon
  - SEO Default: meta title/description, OG image
  - Tampilan: primary/secondary color, footer text
  - Integrasi: Google Analytics ID, custom head/body code
  - Maintenance: mode toggle + message

### 3.11 Activity Log
- Timeline-style read-only view
- Action badges: created (green), updated (blue), deleted (red), login (primary)
- Filters: search, action, entity type, date range
- Relative time display

### 3.12 API Token Management
- CRUD API tokens
- Permissions checkboxes per token
- Expiry date support
- Active/inactive toggle
- Token ditampilkan hanya sekali setelah creation (copy button + warning)
- Token prefix untuk identifikasi

---

## 4. Architecture

### Clean Architecture
```
feature/
├── domain/          ← entities, repository interfaces, usecases
├── data/            ← models (json), datasources (API), repository impls
└── presentation/    ← cubits (state management), pages, widgets
```

### Shared Layout
- CMS Shell: sidebar (collapsible) + top bar
- Sidebar: data-driven (static + dynamic domain items)
- Responsive: desktop (sidebar permanent), mobile (<768px, sidebar as drawer)

### API Pattern
- Base URL via `--dart-define`
- Auth: JWT Bearer token via interceptor
- Error handling: `Either<Failure, T>` dari dartz
- Models: json_serializable
- States: freezed sealed classes

---

## 5. Non-Functional Requirements

| Kategori | Target |
|---|---|
| Load time | < 3 detik (koneksi 4G) |
| Platform | Web (Chrome, Firefox, Safari, Edge) |
| PWA | Installable, offline shell |
| Responsive | Desktop + tablet + mobile |
| Test coverage | Cubit tests untuk auth & dashboard |

---

## 6. Sidebar Menu Structure

```
Dashboard
── Konten
   ├── Daftar Konten
   ├── Kategori Konten
   ├── Media
   └── [Dynamic domain items...]
── Halaman
   ├── Daftar Halaman
   └── [Dynamic domain items...]
── [Custom sections dari domain builder...]
── Pengaturan
   ├── Domain Builder
   ├── Pengguna
   ├── Pengaturan Situs
   ├── Log Aktivitas
   └── API Token
```

---

*PRD ini di-generate dan di-maintain oleh AI.*

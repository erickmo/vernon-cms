# Prompt: Buatkan API Domain Builder untuk Vernon CMS

## Konteks

Saya sudah punya backend REST API untuk **Vernon CMS** (Go), dan frontend Flutter Web sudah jadi. Saya butuh API tambahan untuk fitur **Domain Builder** — fitur no-code yang memungkinkan admin membuat custom entity types (seperti DocType di Frappe), lalu melakukan CRUD data berdasarkan definisi tersebut.

**Frontend sudah siap dan mengharapkan API persis seperti yang didefinisikan di bawah ini.**

---

## 1. Informasi Umum

- **Base URL API:** `http://localhost:8080`
- **Auth:** JWT Bearer Token (sama dengan auth yang sudah ada)
- **Response format:**
  - Sukses: `{ "data": { ... } }`
  - Sukses (list): `{ "data": { "items": [...], "total": N, "page": N, "limit": N } }`
  - Error: `{ "error": "pesan error" }`
- **Role yang bisa akses:** `admin` (full CRUD), `editor` (read only), `viewer` (read only)

---

## 2. Data Model

### 2.1 Domain Definition

Tabel `domains` — menyimpan definisi custom entity types.

| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID | PK | ID unik |
| `name` | VARCHAR(255) | NOT NULL | Nama domain (e.g., "Cabang Bisnis") |
| `slug` | VARCHAR(255) | NOT NULL, UNIQUE | Slug URL-friendly (e.g., "cabang-bisnis") |
| `description` | TEXT | NULLABLE | Deskripsi domain |
| `icon` | VARCHAR(100) | NULLABLE | Nama Material Icon (e.g., "store", "people") |
| `plural_name` | VARCHAR(255) | NOT NULL | Nama bentuk jamak (e.g., "Cabang Bisnis") |
| `sidebar_section` | VARCHAR(100) | NOT NULL, DEFAULT 'content' | Section di sidebar CMS (content/pages/master_data/custom) |
| `sidebar_order` | INTEGER | NOT NULL, DEFAULT 0 | Urutan tampil di sidebar |
| `created_at` | TIMESTAMP | NOT NULL | Waktu dibuat |
| `updated_at` | TIMESTAMP | NOT NULL | Waktu terakhir diperbarui |

### 2.2 Domain Field Definition

Tabel `domain_fields` — menyimpan definisi field untuk setiap domain.

| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID | PK | ID unik field |
| `domain_id` | UUID | FK → domains.id, ON DELETE CASCADE | Domain yang memiliki field ini |
| `name` | VARCHAR(100) | NOT NULL | Nama field snake_case (e.g., "nama_cabang") |
| `label` | VARCHAR(255) | NOT NULL | Label tampilan (e.g., "Nama Cabang") |
| `field_type` | VARCHAR(50) | NOT NULL | Tipe field (lihat daftar di bawah) |
| `is_required` | BOOLEAN | NOT NULL, DEFAULT false | Apakah field wajib diisi |
| `default_value` | TEXT | NULLABLE | Nilai default |
| `placeholder` | VARCHAR(255) | NULLABLE | Placeholder text |
| `help_text` | TEXT | NULLABLE | Teks bantuan |
| `sort_order` | INTEGER | NOT NULL, DEFAULT 0 | Urutan field dalam form |
| `options` | JSONB | NULLABLE | Opsi untuk field tipe `select` (format: `[{"label": "...", "value": "..."}]`) |
| `related_domain_id` | UUID | NULLABLE, FK → domains.id | Untuk field tipe `relation`: ID domain yang dirujuk |
| `related_domain_slug` | VARCHAR(255) | NULLABLE | Untuk field tipe `relation`: slug domain yang dirujuk |

**Field Types yang didukung:**

| Type | Deskripsi | Validasi |
|---|---|---|
| `text` | Input teks satu baris | Max 255 karakter |
| `textarea` | Input teks multi-baris | Max 5000 karakter |
| `number` | Input angka | Numeric only |
| `email` | Input email | Format email valid |
| `url` | Input URL | Format URL valid |
| `phone` | Input nomor telepon | - |
| `date` | Input tanggal | Format ISO 8601 (YYYY-MM-DD) |
| `select` | Dropdown pilihan | Value harus salah satu dari `options` |
| `checkbox` | Boolean toggle | true/false |
| `image_url` | Input URL gambar | Format URL valid |
| `rich_text` | Rich text editor | HTML content |
| `relation` | Relasi ke domain lain | Value harus ID record yang valid di domain terkait |

### 2.3 Domain Records

Tabel `domain_records` — menyimpan data instance dari setiap domain.

| Field | Type | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID | PK | ID unik record |
| `domain_id` | UUID | FK → domains.id, ON DELETE CASCADE | Domain yang memiliki record ini |
| `domain_slug` | VARCHAR(255) | NOT NULL | Slug domain (denormalized untuk query cepat) |
| `data` | JSONB | NOT NULL | Data record (key-value berdasarkan field definitions) |
| `created_at` | TIMESTAMP | NOT NULL | Waktu dibuat |
| `updated_at` | TIMESTAMP | NOT NULL | Waktu terakhir diperbarui |

**Contoh `data` JSONB:**
```json
{
  "nama_cabang": "Cabang Jakarta",
  "alamat": "Jl. Sudirman No. 1",
  "telepon": "021-12345678",
  "kota": "Jakarta",
  "is_active": true,
  "region_id": "uuid-of-related-record"
}
```

---

## 3. API Endpoints

### 3.1 Domain Definitions CRUD

#### List Domains
```
GET /api/v1/domains
Authorization: Bearer <token>

Response 200:
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "Cabang Bisnis",
        "slug": "cabang-bisnis",
        "description": "Data cabang bisnis perusahaan",
        "icon": "store",
        "plural_name": "Cabang Bisnis",
        "sidebar_section": "master_data",
        "sidebar_order": 1,
        "fields": [
          {
            "id": "uuid",
            "name": "nama_cabang",
            "label": "Nama Cabang",
            "field_type": "text",
            "is_required": true,
            "default_value": null,
            "placeholder": "Masukkan nama cabang",
            "help_text": null,
            "sort_order": 0,
            "options": [],
            "related_domain_id": null,
            "related_domain_slug": null
          },
          {
            "id": "uuid",
            "name": "alamat",
            "label": "Alamat",
            "field_type": "textarea",
            "is_required": false,
            "default_value": null,
            "placeholder": "Alamat lengkap",
            "help_text": null,
            "sort_order": 1,
            "options": [],
            "related_domain_id": null,
            "related_domain_slug": null
          },
          {
            "id": "uuid",
            "name": "tipe",
            "label": "Tipe Cabang",
            "field_type": "select",
            "is_required": true,
            "default_value": "reguler",
            "placeholder": null,
            "help_text": "Pilih tipe cabang",
            "sort_order": 2,
            "options": [
              { "label": "Reguler", "value": "reguler" },
              { "label": "Premium", "value": "premium" },
              { "label": "Flagship", "value": "flagship" }
            ],
            "related_domain_id": null,
            "related_domain_slug": null
          },
          {
            "id": "uuid",
            "name": "region",
            "label": "Region",
            "field_type": "relation",
            "is_required": false,
            "default_value": null,
            "placeholder": null,
            "help_text": "Pilih region cabang",
            "sort_order": 3,
            "options": [],
            "related_domain_id": "uuid-of-region-domain",
            "related_domain_slug": "region"
          }
        ],
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

**Note:** List endpoint HARUS mengembalikan `fields` yang sudah ter-include (nested), karena frontend membutuhkan field definitions untuk render sidebar dan dynamic forms.

#### Get Domain Detail
```
GET /api/v1/domains/:id
Authorization: Bearer <token>

Response 200:
{
  "data": {
    "id": "uuid",
    "name": "Cabang Bisnis",
    "slug": "cabang-bisnis",
    "description": "...",
    "icon": "store",
    "plural_name": "Cabang Bisnis",
    "sidebar_section": "master_data",
    "sidebar_order": 1,
    "fields": [ ... ],
    "created_at": "2026-03-16T10:00:00Z",
    "updated_at": "2026-03-16T10:00:00Z"
  }
}
```

#### Create Domain
```
POST /api/v1/domains
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "name": "Cabang Bisnis",
  "slug": "cabang-bisnis",
  "description": "Data cabang bisnis",
  "icon": "store",
  "plural_name": "Cabang Bisnis",
  "sidebar_section": "master_data",
  "sidebar_order": 1,
  "fields": [
    {
      "name": "nama_cabang",
      "label": "Nama Cabang",
      "field_type": "text",
      "is_required": true,
      "placeholder": "Masukkan nama cabang",
      "sort_order": 0
    },
    {
      "name": "tipe",
      "label": "Tipe Cabang",
      "field_type": "select",
      "is_required": true,
      "default_value": "reguler",
      "sort_order": 1,
      "options": [
        { "label": "Reguler", "value": "reguler" },
        { "label": "Premium", "value": "premium" }
      ]
    }
  ]
}

Response 201:
{ "data": { "status": "created" } }
```

**Validasi:**
- `name` wajib, max 255 karakter
- `slug` wajib, unique, lowercase, hanya huruf/angka/dash
- `plural_name` wajib
- `fields[].name` wajib, snake_case, unique dalam satu domain
- `fields[].label` wajib
- `fields[].field_type` wajib, harus salah satu dari daftar field types
- Jika `field_type` = `select`, `options` wajib ada minimal 1 item
- Jika `field_type` = `relation`, `related_domain_id` atau `related_domain_slug` wajib ada

#### Update Domain
```
PUT /api/v1/domains/:id
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "name": "Cabang Bisnis Updated",
  "slug": "cabang-bisnis",
  "description": "Updated description",
  "icon": "business",
  "plural_name": "Cabang Bisnis",
  "sidebar_section": "master_data",
  "sidebar_order": 1,
  "fields": [
    {
      "id": "existing-field-uuid",
      "name": "nama_cabang",
      "label": "Nama Cabang",
      "field_type": "text",
      "is_required": true,
      "sort_order": 0
    },
    {
      "name": "field_baru",
      "label": "Field Baru",
      "field_type": "text",
      "sort_order": 1
    }
  ]
}

Response 200:
{ "data": { "status": "updated" } }
```

**Note:** Update mengirim SEMUA fields. Fields dengan `id` yang ada di-update, fields tanpa `id` dibuat baru, fields yang tidak dikirim dihapus (replace strategy).

#### Delete Domain
```
DELETE /api/v1/domains/:id
Authorization: Bearer <admin_token>

Response 200:
{ "data": { "status": "deleted" } }
```

**Note:** Menghapus domain juga menghapus semua field definitions dan records terkait (CASCADE).

---

### 3.2 Domain Records CRUD

Semua endpoint di bawah ini menggunakan `domain_slug` sebagai path parameter. Frontend menentukan domain mana yang diakses berdasarkan slug.

#### List Records
```
GET /api/v1/domains/:domain_slug/records?page=1&limit=20&search=keyword
Authorization: Bearer <token>

Response 200:
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "domain_slug": "cabang-bisnis",
        "data": {
          "nama_cabang": "Cabang Jakarta",
          "alamat": "Jl. Sudirman No. 1",
          "telepon": "021-12345678",
          "tipe": "premium",
          "region": "uuid-of-region-record"
        },
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

**Query Parameters:**
| Param | Type | Default | Deskripsi |
|---|---|---|---|
| `page` | int | 1 | Nomor halaman |
| `limit` | int | 20 | Jumlah item per halaman |
| `search` | string | - | Pencarian di semua field teks dalam `data` |

**Search behavior:** Jika `search` diberikan, cari di semua field dalam `data` JSONB yang bertipe string. Gunakan case-insensitive matching.

#### Get Record Detail
```
GET /api/v1/domains/:domain_slug/records/:id
Authorization: Bearer <token>

Response 200:
{
  "data": {
    "id": "uuid",
    "domain_slug": "cabang-bisnis",
    "data": {
      "nama_cabang": "Cabang Jakarta",
      "alamat": "Jl. Sudirman No. 1",
      "tipe": "premium"
    },
    "created_at": "2026-03-16T10:00:00Z",
    "updated_at": "2026-03-16T10:00:00Z"
  }
}
```

#### Create Record
```
POST /api/v1/domains/:domain_slug/records
Authorization: Bearer <token> (admin atau editor)
Content-Type: application/json

{
  "data": {
    "nama_cabang": "Cabang Baru",
    "alamat": "Jl. Baru No. 1",
    "tipe": "reguler"
  }
}

Response 201:
{ "data": { "status": "created" } }
```

**Validasi:**
- `data` wajib berupa object
- Validasi berdasarkan field definitions dari domain:
  - Field dengan `is_required: true` harus ada dan tidak kosong
  - Field tipe `email` harus format email valid
  - Field tipe `url` / `image_url` harus format URL valid
  - Field tipe `number` harus numeric
  - Field tipe `select` harus salah satu dari `options[].value`
  - Field tipe `date` harus format tanggal valid (YYYY-MM-DD)
  - Field tipe `relation` harus UUID yang valid dan record harus exist di domain terkait
  - Field tipe `checkbox` harus boolean
- Field yang tidak didefinisikan di domain diabaikan (tidak disimpan)

#### Update Record
```
PUT /api/v1/domains/:domain_slug/records/:id
Authorization: Bearer <token> (admin atau editor)
Content-Type: application/json

{
  "data": {
    "nama_cabang": "Cabang Jakarta Updated",
    "alamat": "Jl. Sudirman No. 1 Updated"
  }
}

Response 200:
{ "data": { "status": "updated" } }
```

#### Delete Record
```
DELETE /api/v1/domains/:domain_slug/records/:id
Authorization: Bearer <token> (admin only)

Response 200:
{ "data": { "status": "deleted" } }
```

#### Get Record Options (untuk Relation dropdown)
```
GET /api/v1/domains/:domain_slug/records/options
Authorization: Bearer <token>

Response 200:
{
  "data": [
    { "id": "uuid-1", "label": "Region Jakarta" },
    { "id": "uuid-2", "label": "Region Surabaya" },
    { "id": "uuid-3", "label": "Region Bandung" }
  ]
}
```

**Note:** Endpoint ini digunakan untuk mengisi dropdown pada field tipe `relation`. `label` diambil dari field pertama yang bertipe `text` dan `is_required: true` pada domain terkait, atau field pertama jika tidak ada yang required.

---

## 4. Error Responses

Mengikuti format yang sudah ada:

| HTTP Code | Kapan | Contoh |
|---|---|---|
| 400 | Input tidak valid | `"field 'nama_cabang' is required"` |
| 401 | Token invalid | `"invalid or expired token"` |
| 403 | Role tidak cukup | `"insufficient permissions"` |
| 404 | Domain/Record tidak ditemukan | `"domain not found: cabang-bisnis"` |
| 409 | Slug duplikat | `"duplicate slug: cabang-bisnis"` |
| 500 | Error internal | `"internal server error"` |

---

## 5. RBAC

| Resource | Read (GET) | Write (POST/PUT) | Delete |
|---|---|---|---|
| Domain Definitions | admin, editor, viewer | admin | admin |
| Domain Records | admin, editor, viewer | admin, editor | admin |

---

## 6. Database Migration

```sql
-- Domain definitions
CREATE TABLE domains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(100),
    plural_name VARCHAR(255) NOT NULL,
    sidebar_section VARCHAR(100) NOT NULL DEFAULT 'content',
    sidebar_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Domain field definitions
CREATE TABLE domain_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    label VARCHAR(255) NOT NULL,
    field_type VARCHAR(50) NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT false,
    default_value TEXT,
    placeholder VARCHAR(255),
    help_text TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    options JSONB,
    related_domain_id UUID REFERENCES domains(id) ON DELETE SET NULL,
    related_domain_slug VARCHAR(255),
    UNIQUE(domain_id, name)
);

-- Domain records
CREATE TABLE domain_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    domain_slug VARCHAR(255) NOT NULL,
    data JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_domain_fields_domain_id ON domain_fields(domain_id);
CREATE INDEX idx_domain_fields_sort_order ON domain_fields(domain_id, sort_order);
CREATE INDEX idx_domain_records_domain_id ON domain_records(domain_id);
CREATE INDEX idx_domain_records_domain_slug ON domain_records(domain_slug);
CREATE INDEX idx_domain_records_data ON domain_records USING GIN (data);
```

---

## 7. Contoh Alur Penggunaan

### Admin membuat domain "Cabang Bisnis":

1. `POST /api/v1/domains` dengan nama "Cabang Bisnis", slug "cabang-bisnis", icon "store", sidebar_section "master_data", fields: [nama_cabang (text, required), alamat (textarea), telepon (phone), tipe (select: reguler/premium)]

2. Frontend reload sidebar → muncul section "Master Data" dengan menu "Cabang Bisnis"

3. User klik menu → `GET /api/v1/domains/cabang-bisnis/records` → tampil tabel kosong

4. User klik "Tambah" → frontend load domain definition, render form dinamis berdasarkan field definitions

5. User isi form → `POST /api/v1/domains/cabang-bisnis/records` dengan `{ "data": { "nama_cabang": "...", ... } }`

### Admin membuat domain "Region" lalu relasikan ke "Cabang":

1. Buat domain "Region" dengan field: nama (text, required)
2. Tambahkan data region: Jakarta, Surabaya, Bandung
3. Edit domain "Cabang Bisnis", tambah field: region (relation, related_domain_slug: "region")
4. Saat user buat/edit cabang, field "Region" tampil sebagai dropdown yang diisi dari `GET /api/v1/domains/region/records/options`

---

## 8. Catatan Teknis

- Semua ID menggunakan UUID v4
- Timestamp format: RFC 3339 (`2026-03-16T10:00:00Z`)
- `data` JSONB di domain_records menyimpan value berdasarkan field `name` sebagai key
- Search di records: gunakan PostgreSQL `to_tsvector` atau simple ILIKE pada JSONB text values
- Saat domain di-delete, semua fields dan records CASCADE delete
- `domain_slug` di tabel `domain_records` adalah denormalized untuk performa query (hindari JOIN saat list records)
- Field `options` di `domain_fields` disimpan sebagai JSONB array: `[{"label": "Opt 1", "value": "opt1"}]`
- Endpoint `/records/options` mengembalikan array langsung dalam `data` (bukan paginated), karena biasanya jumlah opsi tidak banyak

---

*Prompt ini di-generate dari frontend Vernon CMS UI yang sudah jadi. Implementasi backend harus mengikuti spec ini persis agar kompatibel.*

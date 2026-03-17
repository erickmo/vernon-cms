# Vernon CMS UI — Flutter Web PWA

## Overview
Full-featured Content Management System web UI built with Flutter Web (PWA).
Mendukung manajemen konten, halaman, media, user, dan custom domain builder (no-code).

**PRD Lengkap:** docs/requirements/prd-vernon-cms-ui.md

## Stack
- **Framework:** Flutter 3.41.4 (Web PWA)
- **State Management:** BLoC / Cubit (freezed states)
- **Navigation:** go_router (ShellRoute untuk CMS layout)
- **DI:** get_it (manual registration)
- **Network:** Dio + interceptors (auth, error, logger)
- **Chart:** fl_chart
- **Platform:** Web (PWA)

## Features (11 modules, 232 source files)

| Module | Route | Deskripsi |
|---|---|---|
| Auth | `/login`, `/forgot-password` | Login, remember me, forgot password |
| Dashboard | `/dashboard` | Stats cards, chart konten per hari |
| Content | `/content`, `/content/create`, `/content/:id/edit` | CRUD artikel (SEO, OG, publishing workflow) |
| Content Category | `/content-category` | CRUD kategori (hierarchy, SEO) |
| Page Management | `/pages`, `/pages/create`, `/pages/:id/edit` | CRUD halaman (hero, layout, nav, redirect) |
| Domain Builder | `/domain-builder`, `/domain-builder/create` | No-code schema builder (custom entity types) |
| Domain Records | `/domain/:slug`, `/domain/:slug/create` | Dynamic CRUD berdasarkan schema |
| Media Manager | `/media` | Grid view, upload, media picker dialog |
| User Management | `/users`, `/users/create`, `/users/:id/edit` | CRUD users, roles, toggle active, reset password |
| Settings | `/settings` | Global CMS config (SEO, tampilan, integrasi, maintenance) |
| Activity Log | `/activity-logs` | Timeline riwayat perubahan |
| API Token | `/api-tokens` | CRUD API tokens, permissions |

## Coding Rules
- SEMUA code ditulis oleh AI. Developer tidak menulis code manual.
- Ikuti flutter-coding-standard skill
- Tidak ada push langsung ke `main` atau `master`
- Wajib widget test untuk setiap screen baru
- Tidak ada business logic di dalam build()
- Tidak ada hardcode string/color/dimension
- Semua state (loading/success/error/empty) wajib di-handle
- Use `sealed class` untuk freezed states

## Project Structure
```
lib/
├── core/
│   ├── constants/       ← app_colors, app_constants, app_dimensions, app_strings
│   ├── di/              ← get_it dependency injection
│   ├── errors/          ← Failure classes
│   ├── network/         ← ApiClient (Dio + interceptors)
│   ├── router/          ← go_router (ShellRoute)
│   ├── theme/           ← Material 3 theme
│   └── utils/           ← logger, either_extension, icon_resolver
├── shared/presentation/ ← CMS shell layout (sidebar + topbar)
├── features/
│   ├── auth/            ← login, forgot password
│   ├── dashboard/       ← stats, chart
│   ├── content/         ← articles + categories CRUD
│   ├── page_management/ ← pages CRUD
│   ├── domain_builder/  ← schema builder (no-code)
│   ├── domain_records/  ← dynamic CRUD
│   ├── media/           ← media manager
│   ├── user_management/ ← users + roles
│   ├── settings/        ← global settings
│   ├── activity_log/    ← activity timeline
│   └── api_token/       ← API token management
└── main.dart
```

## Key Commands
```bash
make get          # flutter pub get
make run          # flutter run -d chrome
make run-dev      # flutter run -d chrome (dev API)
make gen          # build_runner (code generation)
make test         # flutter test
make analyze      # flutter analyze
make build-web    # build release web
```

## API Endpoints Pattern
- Auth: `/api/login`
- Dashboard: `/api/dashboard/stats`, `/api/dashboard/daily-content`
- Content: `/api/contents`, `/api/content-categories`
- Pages: `/api/pages`
- Domains: `/api/domains`, `/api/domains/{slug}/records`
- Media: `/api/media`, `/api/media/upload`
- Users: `/api/users`
- Settings: `/api/settings`
- Activity: `/api/activity-logs`
- Tokens: `/api/tokens`

## Documentation
- **PRD & Requirements:** `docs/requirements/prd-vernon-cms-ui.md`
- **Backend Development Requests:** `docs/backend_requirements/backend_development_requests.md` (11 endpoints pending)
- **Domain Builder Specs:** `docs/backend-prompt-domain-builder.md`

## Important Notes
- BASE_URL diset via --dart-define saat run/build, bukan hardcode
- Wajib run `make gen` setelah buat/ubah freezed atau json_serializable
- Gunakan `AppColors`, `AppDimensions`, `AppStrings` — tidak boleh hardcode
- URL strategy: path-based (tanpa #) via url_strategy package
- Sidebar: data-driven, domain definitions otomatis muncul di sidebar

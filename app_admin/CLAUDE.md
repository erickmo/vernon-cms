# Vernon Admin — Flutter Web PWA

## Overview
Admin panel untuk mengelola clients dan payments. Terpisah dari CMS web dashboard (`web/`).

**Backend API:** Sama dengan `api/` (Vernon CMS API)

## Stack
- **Framework:** Flutter 3.41.4 (Web PWA)
- **State Management:** BLoC / Cubit (freezed states)
- **Navigation:** go_router (ShellRoute untuk admin layout)
- **DI:** get_it (manual registration)
- **Network:** Dio + interceptors (auth, token refresh, error)
- **Platform:** Web (PWA)

## Features

| Module | Routes | Deskripsi |
|---|---|---|
| Auth | `/login` | Login admin |
| Client | `/clients`, `/clients/create`, `/clients/:id`, `/clients/:id/edit` | CRUD clients, toggle active |
| Payment | `/payments`, `/payments/create`, `/payments/:id` | CRUD payments, filter status |

## Coding Rules
- SEMUA code ditulis oleh AI. Developer tidak menulis code manual.
- Ikuti flutter-coding-standard skill
- Tidak ada business logic di dalam build()
- Tidak ada hardcode string/color/dimension — gunakan AppStrings, AppColors, AppDimensions
- Semua state (loading/success/error/empty) wajib di-handle
- Use `sealed class` untuk freezed states

## Project Structure
```
lib/
├── core/
│   ├── constants/       ← AppColors, AppConstants, AppDimensions, AppStrings
│   ├── di/              ← get_it manual injection
│   ├── errors/          ← Failure classes
│   ├── network/         ← ApiClient (Dio + interceptors)
│   ├── router/          ← go_router (ShellRoute)
│   ├── theme/           ← Material 3 theme
│   └── utils/           ← logger, either_extension, date_formatter
├── shared/presentation/ ← AdminShellPage (sidebar + layout)
├── features/
│   ├── auth/            ← login
│   ├── client/          ← CRUD clients
│   └── payment/         ← CRUD payments
└── main.dart
```

## Key Commands
```bash
make get          # flutter pub get
make run          # flutter run -d chrome --web-port=3001
make gen          # build_runner (freezed, json_serializable)
make test         # flutter test
make analyze      # flutter analyze
make build-web    # build release web
```

## API Endpoints (dipakai app ini)
- Auth: `POST /api/v1/auth/login`
- Clients: `GET/POST /api/v1/clients`, `GET/PUT /api/v1/clients/:id`, `PATCH /api/v1/clients/:id/toggle-active`, `DELETE /api/v1/clients/:id`
- Payments: `GET/POST /api/v1/payments`, `GET /api/v1/payments/:id`

## Important Notes
- BASE_URL diset via `.env` (development) atau `--dart-define=BASE_URL=...` (build/staging/prod)
- Wajib run `make gen` setelah buat/ubah freezed atau json_serializable
- Port default: 3001 (beda dengan web/ yang pakai 3000)
- Endpoints `/api/v1/clients` dan `/api/v1/payments` perlu ditambahkan ke backend `api/`

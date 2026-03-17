# Vernon CMS UI

Full-featured Content Management System built with Flutter Web (PWA). Supports content management, page management, media, user management, and a no-code domain builder for creating custom entity types.

## Features

| Feature | Description |
|---|---|
| **Auth** | Login, remember me, forgot password, JWT token management |
| **Dashboard** | Stats cards (posts, visits, growth %), daily content bar chart |
| **Content Management** | Full CRUD with 30+ fields, SEO, Open Graph, publishing workflow |
| **Content Category** | Hierarchical categories with SEO and visibility settings |
| **Page Management** | CMS pages with hero section, layout settings, navigation, redirect |
| **Domain Builder** | No-code schema builder — create custom entity types with configurable fields |
| **Domain Records** | Dynamic CRUD — auto-generated forms and tables from domain schemas |
| **Media Manager** | Grid view, upload, detail dialog, reusable media picker |
| **User Management** | CRUD users with 4 roles (super_admin, admin, editor, viewer) |
| **Global Settings** | Site config, default SEO, appearance, integrations, maintenance mode |
| **Activity Log** | Timeline view of all system changes with filters |
| **API Token** | CRUD API tokens with permissions and one-time token display |

## Tech Stack

- **Framework:** Flutter 3.41.4 (Web PWA)
- **State Management:** BLoC / Cubit (freezed states)
- **Navigation:** go_router (ShellRoute for CMS layout)
- **DI:** get_it
- **Network:** Dio + interceptors
- **Chart:** fl_chart
- **Architecture:** Clean Architecture (domain / data / presentation)

## Getting Started

### Prerequisites

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0

### Setup

```bash
# Clone repository
git clone https://github.com/erickmo/vernoncms-ui.git
cd vernoncms-ui

# Install dependencies
make get

# Generate code (freezed, json_serializable)
make gen

# Run in development mode
make run-dev
```

### Commands

| Command | Description |
|---|---|
| `make get` | Install dependencies |
| `make run` | Run in Chrome |
| `make run-dev` | Run with dev API URL |
| `make run-staging` | Run with staging API URL |
| `make run-prod` | Run with production API URL |
| `make gen` | Run code generation (freezed, json_serializable) |
| `make test` | Run all tests |
| `make analyze` | Run static analysis |
| `make build-web` | Build production web release |
| `make clean` | Clean and reinstall dependencies |

### Environment Configuration

Base URL is configured via `--dart-define` at build/run time:

```bash
flutter run -d chrome --dart-define=BASE_URL=http://localhost:8080/api/v1
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # Colors, dimensions, strings, app config
│   ├── di/              # Dependency injection (get_it)
│   ├── errors/          # Failure classes
│   ├── network/         # ApiClient (Dio + interceptors)
│   ├── router/          # go_router configuration
│   ├── theme/           # Material 3 theme
│   └── utils/           # Logger, extensions, icon resolver
├── shared/
│   └── presentation/    # CMS shell layout (sidebar + topbar)
├── features/
│   ├── auth/            # Login, forgot password
│   ├── dashboard/       # Stats, charts
│   ├── content/         # Articles + categories CRUD
│   ├── page_management/ # Pages CRUD
│   ├── domain_builder/  # No-code schema builder
│   ├── domain_records/  # Dynamic CRUD from schemas
│   ├── media/           # Media manager
│   ├── user_management/ # Users + roles
│   ├── settings/        # Global settings
│   ├── activity_log/    # Activity timeline
│   └── api_token/       # API token management
└── main.dart
```

Each feature follows Clean Architecture:
```
feature/
├── domain/          # Entities, repository interfaces, use cases
├── data/            # Models (JSON), datasources (API), repository implementations
└── presentation/    # Cubits (state), pages, widgets
```

## API Endpoints

| Module | Endpoints |
|---|---|
| Auth | `POST /api/login` |
| Dashboard | `GET /api/dashboard/stats`, `GET /api/dashboard/daily-content` |
| Content | `GET/POST /api/contents`, `GET/PUT/DELETE /api/contents/{id}` |
| Categories | `GET/POST /api/content-categories`, `GET/PUT/DELETE /api/content-categories/{id}` |
| Pages | `GET/POST /api/pages`, `GET/PUT/DELETE /api/pages/{id}` |
| Domains | `GET/POST /api/domains`, `GET/PUT/DELETE /api/domains/{id}` |
| Domain Records | `GET/POST /api/domains/{slug}/records`, `GET/PUT/DELETE /api/domains/{slug}/records/{id}` |
| Media | `GET /api/media`, `POST /api/media/upload`, `PUT/DELETE /api/media/{id}` |
| Users | `GET/POST /api/users`, `GET/PUT/DELETE /api/users/{id}` |
| Settings | `GET/PUT /api/settings` |
| Activity | `GET /api/activity-logs` |
| Tokens | `GET/POST /api/tokens`, `PUT/DELETE /api/tokens/{id}` |

## Sidebar Menu

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
── [Custom sections from Domain Builder...]
── Pengaturan
   ├── Domain Builder
   ├── Pengguna
   ├── Pengaturan Situs
   ├── Log Aktivitas
   └── API Token
```

## License

Proprietary — All rights reserved.

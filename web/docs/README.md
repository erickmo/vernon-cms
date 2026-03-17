# Vernon CMS UI — Documentation Index

## 📋 Requirements & Specifications

### Product Requirements
- **[PRD — Vernon CMS UI](requirements/prd-vernon-cms-ui.md)**
  - Product overview, features, scope, architecture
  - User journeys, acceptance criteria

### Backend API Specifications

#### ✅ Implemented Endpoints (Already have backend)
- Auth: `/api/login`, `/api/logout`, `/api/refresh-token`
- Content: `/api/contents`, `/api/content/{id}`, `/api/content-categories`
- Pages: `/api/pages`, `/api/pages/{id}`
- Domains: `/api/domains`, `/api/domains/{slug}`, `/api/domains/{slug}/records`
- Users: `/api/users`, `/api/users/{id}`
- Domain Builder: `/api/domain-definitions`, `/api/domain-definitions/{id}`

#### ❌ Pending Implementation (Waiting for backend)
- **[Backend Development Requests](backend_requirements/backend_development_requests.md)** — 11 missing endpoints:
  - **Settings Management** (GET/PUT `/api/v1/settings`)
  - **Activity Log** (GET `/api/v1/activity-logs` with filters)
  - **API Token Management** (CRUD `/api/v1/tokens` with permissions)
  - **Media Manager** (GET/POST/PUT/DELETE `/api/v1/media`, upload)

**Share this file with backend team:** `docs/backend_requirements/backend_development_requests.md`

---

## 🏗️ Architecture & Implementation Details

### Domain Builder
- **[Domain Builder Backend Prompt](backend-prompt-domain-builder.md)**
  - No-code schema builder specification
  - Custom entity types, field validation, relationships

---

## 📂 Documentation Structure

```
docs/
├── README.md (this file) — documentation index
├── requirements/
│   └── prd-vernon-cms-ui.md — full product requirements
├── backend_requirements/
│   └── backend_development_requests.md — API specifications for 11 pending endpoints
└── backend-prompt-domain-builder.md — domain builder specification
```

---

## 🚀 Quick Links for Teams

### For Backend Developers
1. Read: `docs/backend_requirements/backend_development_requests.md`
2. Implement: 11 endpoints with standardized response format
3. Timeline: After implementation, frontend integration takes < 1 day

### For Frontend Developers
1. Read: `docs/requirements/prd-vernon-cms-ui.md` (features & flows)
2. Check: `lib/CLAUDE.md` (coding standards & project structure)
3. Reference: Existing implementation patterns in features/ directory

### For Product Managers
1. Read: `docs/requirements/prd-vernon-cms-ui.md` (complete product spec)
2. Track: Pending backend features in `docs/backend_requirements/backend_development_requests.md`

---

## 📝 How to Update Documentation

1. Edit relevant .md file in `docs/` directory
2. Update this README.md if adding new documents
3. Update `CLAUDE.md` in project root if major changes
4. Commit with message: `docs: update [section name]`

---

**Last Updated:** 2026-03-17
**Frontend Status:** ✅ All UI pages ready
**Backend Status:** ⏳ Waiting for 11 endpoints

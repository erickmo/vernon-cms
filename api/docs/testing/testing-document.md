# Testing Document: Vernon CMS

**Versi:** 1.3.0
**Tanggal:** 2026-03-17
**Total Test Cases:** 334 (core) — new features pending
**Status:** Core All Passed | New features (Settings/Media/Tokens/Dashboard) belum ditest

---

## 1. Test Architecture

### 1.1 Struktur
```
tests/
├── mocks/                              ← In-memory mock implementations
│   ├── event_bus.go                    ← Mock EventBus (track events, simulate failures)
│   ├── page_repository.go             ← Mock Page repo (unique slug check)
│   ├── content_category_repository.go ← Mock ContentCategory repo
│   ├── content_repository.go          ← Mock Content repo
│   ├── user_repository.go             ← Mock User repo (unique email check)
│   └── domain_repository.go           ← Mock DomainWrite+Read repo (unique slug, fields, records)
├── unit/                               ← Unit tests (no external deps)
│   ├── domain_*_test.go               ← Domain entity tests
│   ├── command_*_test.go              ← Command handler tests
│   ├── http_*_handler_test.go         ← HTTP handler tests
│   ├── commandbus_test.go             ← CommandBus tests
│   ├── querybus_test.go               ← QueryBus tests
│   ├── eventbus_test.go               ← EventBus tests
│   ├── middleware_test.go             ← Middleware tests
│   ├── domain_events_test.go          ← Domain events interface tests
│   ├── auth_jwt_test.go               ← JWT token lifecycle tests
│   ├── auth_middleware_test.go        ← Auth + RBAC middleware tests
│   └── apperror_test.go              ← Custom error types tests
└── integration/                        ← Integration tests (require Docker)
    └── page_test.go                   ← Page CRUD with real DB
```

### 1.2 Prinsip Testing
- **Unit tests** menggunakan mock repositories — tidak butuh database/Redis
- **Setiap test case** mencetak Scenario, Goal, Flow, Result, Status
- **Mock repos** mensimulasikan unique constraints (slug, email)
- **Mock event bus** melacak published events dan bisa simulasi kegagalan

---

## 2. Test Coverage per Layer

### 2.1 Domain Layer (6 files, ~68 test cases)

#### Page Entity (`domain_page_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| NewPage valid input | Create with name, slug, variables | Page created, IsActive=true, timestamps set |
| NewPage nil variables | Variables = nil | Defaults to `{}` |
| NewPage empty name | Name = "" | Error: "name is required" |
| NewPage empty slug | Slug = "" | Error: "slug is required" |
| NewPage both empty | Name="" & Slug="" | Error on name first |
| UpdateName valid | Set new name | Name updated, UpdatedAt changed |
| UpdateName empty | Set name="" | Error, name unchanged |
| UpdateSlug valid | Set new slug | Slug updated |
| UpdateSlug empty | Set slug="" | Error |
| SetVariables valid | Set JSON variables | Variables updated |
| SetVariables nil | nil variables | Defaults to `{}` |
| Deactivate | Call Deactivate() | IsActive=false |
| Activate | Call Activate() | IsActive=true |

#### Content Entity (`domain_content_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| NewContent valid | All required fields | Content created, status=draft |
| NewContent empty title | Title="" | Error |
| NewContent empty slug | Slug="" | Error |
| UpdateTitle valid | New title | Updated |
| UpdateTitle empty | "" | Error |
| UpdateSlug valid | New slug | Updated |
| UpdateSlug empty | "" | Error |
| UpdateBody | New body | Updated, UpdatedAt changed |
| Publish from draft | status=draft | status=published, published_at set |
| Publish from published | status=published | Error: already published |
| Publish from archived | status=archived | status=published |
| Archive from draft | status=draft | status=archived |
| Archive from published | status=published | status=archived |
| ToDraft from archived | status=archived | status=draft, published_at nil |
| ToDraft from draft | status=draft | Error or no-op |
| UpdateMetadata | Valid JSONB | Updated |
| UpdateMetadata nil | nil | Defaults to `{}` |

#### ContentCategory Entity (`domain_content_category_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| NewContentCategory valid | name + slug | Created |
| NewContentCategory empty name | "" | Error |
| NewContentCategory empty slug | "" | Error |
| Update valid | New name + slug | Updated |
| Update empty fields | "" | Error |

#### User Entity (`domain_user_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| NewUser valid | All fields | Created, IsActive=true |
| NewUser empty email | "" | Error |
| NewUser empty password | "" | Error |
| NewUser empty name | "" | Error |
| NewUser invalid role | "superadmin" | Error |
| UpdateName valid | New name | Updated |
| UpdateName empty | "" | Error |
| UpdateRole valid | "admin" | Updated |
| UpdateRole invalid | "owner" | Error |
| UpdateEmail valid | Valid email | Updated |
| UpdateEmail empty | "" | Error |
| Activate/Deactivate | Toggle | IsActive toggled |
| SetPasswordHash | New hash | Updated |

#### Domain Events (`domain_events_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| PageCreated interface | Check EventName + OccurredAt | Correct values |
| PageUpdated interface | Check EventName + OccurredAt | Correct values |
| PageDeleted interface | Check EventName + OccurredAt | Correct values |
| ContentCreated interface | Check | Correct values |
| ContentUpdated interface | Check | Correct values |
| ContentPublished interface | Check | Correct values |
| ContentDeleted interface | Check | Correct values |
| ContentCategoryCreated interface | Check | Correct values |
| ContentCategoryUpdated interface | Check | Correct values |
| ContentCategoryDeleted interface | Check | Correct values |
| UserCreated interface | Check | Correct values |
| UserUpdated interface | Check | Correct values |
| UserDeleted interface | Check | Correct values |

---

### 2.2 Command Layer (~130 test cases)

#### Page Commands (`command_page_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| CreatePage success | Valid input | Page saved, event published |
| CreatePage duplicate slug | Slug exists | Error returned, no event |
| CreatePage empty name | name="" | ValidationError |
| UpdatePage success | Valid update | Page updated, event published |
| UpdatePage not found | Wrong ID | Error, no event |
| UpdatePage empty name | name="" | ValidationError |
| DeletePage success | Valid ID | Page deleted, event published |
| DeletePage not found | Wrong ID | Error, no event |

#### Content Category Commands (`command_content_category_test.go`)
*(Same pattern as Page — 8 test cases)*

#### Content Commands (`command_content_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| CreateContent success | Valid input | Saved, event published |
| CreateContent empty title | title="" | ValidationError |
| CreateContent empty slug | slug="" | ValidationError |
| UpdateContent success | Valid | Updated, event published |
| UpdateContent not found | Wrong ID | Error |
| DeleteContent success | Valid | Deleted, event published |
| DeleteContent not found | Wrong ID | Error |
| PublishContent success | draft | Published, event published |
| PublishContent already published | published | Error, no event |
| PublishContent archived | archived | Published |

#### User Commands (`command_user_test.go`)
*(8 test cases)*

#### Register/Login Commands (`command_auth_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| Register success | Valid input | User saved, event published |
| Register duplicate email | Email exists | Error, no event |
| Register empty email | "" | ValidationError |
| Register short password | < 8 chars | ValidationError |
| Login success | Correct credentials | (handled by login.Handler directly) |

---

### 2.3 HTTP Handler Layer (~60 test cases)

#### Page Handler (`http_page_handler_test.go`)
| Test Case | Method | Input | Expected HTTP Code |
|---|---|---|---|
| List pages | GET /pages | - | 200 |
| Get page valid | GET /pages/:id | Valid UUID | 200 |
| Get page invalid UUID | GET /pages/:id | "abc" | 400 |
| Get page not found | GET /pages/:id | Unknown UUID | 404 |
| Create page success | POST /pages | Valid JSON | 201 |
| Create page invalid body | POST /pages | Malformed JSON | 400 |
| Create page missing fields | POST /pages | {} | 400 |
| Update page success | PUT /pages/:id | Valid JSON | 200 |
| Update page invalid UUID | PUT /pages/:id | "abc" | 400 |
| Delete page success | DELETE /pages/:id | Valid UUID | 200 |
| Delete page not found | DELETE /pages/:id | Unknown UUID | 500 |

*(Sama untuk ContentCategory, Content, User — ~44 test cases total)*

---

### 2.4 Infrastructure Layer (~48 test cases)

#### CommandBus (`commandbus_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| Register + Dispatch success | Valid command | Handler called, no error |
| Dispatch unregistered | Unknown command name | Error: "handler not found" |
| Dispatch with logging hook | Valid | Logged, handler called |
| Dispatch with validation hook — pass | Struct valid | Handler called |
| Dispatch with validation hook — fail | Struct invalid | Error before handler |
| Multiple hooks order | 2 hooks | Both executed in order |
| CommandBus metrics | Valid dispatch | HTTPRequestCount incremented |
| Nil handler panic recovery | - | Error, no panic |

#### QueryBus (`querybus_test.go`)
*(~8 test cases)*

#### EventBus (`eventbus_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| Subscribe + Publish | Single subscriber | Handler called once |
| Multiple subscribers | 2 subs, 1 event | Both called |
| No subscribers | Publish with no sub | No error |
| Subscriber error | Handler returns error | Error propagated |
| Multiple events | Publish 2 events | Both handled independently |

#### JWT (`auth_jwt_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| GenerateTokenPair success | Valid user/role | Tokens returned, ExpiresAt set |
| GenerateTokenPair claims | Check claims | UserID, Email, Role, SiteID correct |
| ValidateToken valid | Valid access token | Claims returned |
| ValidateToken expired | Expired token | Error |
| ValidateToken wrong secret | Wrong key | Error |
| ValidateToken malformed | "garbage" | Error |
| ValidateToken refresh token | Refresh as access | Still valid (same type) |
| ExpiresAt value | Near-future | Within expected window |

#### Auth Middleware (`auth_middleware_test.go`)
*(~10 test cases)*

#### Custom Error Types (`apperror_test.go`)
*(~10 test cases)*

---

### 2.5 New Features — Test Gap ⚠️

Fitur berikut belum memiliki unit test:

| Feature | Mock Needed | Priority |
|---|---|---|
| Settings (UpdateSettings, GetSettings) | `settings.WriteRepository`, `settings.ReadRepository` | High |
| Media (UploadMedia, UpdateMedia, DeleteMedia, ListMedia, GetMedia) | `media.WriteRepository`, `media.ReadRepository` | High |
| APIToken (Create/Update/Delete/Toggle, List) | `apitoken.WriteRepository`, `apitoken.ReadRepository` | High |
| Dashboard (GetDashboardStats, GetDailyContentStats) | sqlx.DB mock / in-memory | Medium |
| ActivityLog (ListActivityLogs, ActivityLogHandler) | sqlx.DB mock | Medium |
| Site commands (CreateSite, AddSiteMember, dll) | `site.WriteRepository` | Medium |
| HTTP handlers untuk semua fitur baru | - | High |

---

## 3. Integration Tests

### 3.1 Existing
| File | Coverage |
|---|---|
| `tests/integration/page_test.go` | Page CRUD dengan real PostgreSQL via Testcontainers |

### 3.2 Planned
- Content + ContentCategory integration
- Multi-tenant isolation test (data tidak bocor antar site_id)
- API Token authentication flow
- Media CRUD integration

---

## 4. Test Commands

```bash
make test             # Unit tests semua
make test-race        # Race condition detection (wajib sebelum PR)
make test-integration # Integration tests (butuh Docker)
```

---

## 5. Changelog

| Versi | Tanggal | Perubahan |
|---|---|---|
| 1.0.0 | 2026-03-16 | Initial: 284 test cases |
| 1.1.0 | 2026-03-16 | +50 test cases: JWT, Auth middleware, RBAC, apperror |
| 1.2.0 | 2026-03-16 | +0: Domain builder mocks, domain builder tests (sudah termasuk sebelumnya) |
| 1.3.0 | 2026-03-17 | Dokumen diupdate: mencatat test gap untuk Settings/Media/Tokens/Dashboard/ActivityLog |

---
*Di-generate dan di-update oleh AI. Review sebelum production deploy.*

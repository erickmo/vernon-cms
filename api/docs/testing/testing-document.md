# Testing Document: Vernon CMS

**Versi:** 1.2.0
**Tanggal:** 2026-03-17
**Total Test Cases:** 334
**Status:** All Passed

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
| UpdateSlug empty | Set slug="" | Error, slug unchanged |
| UpdateVariables | Set complex JSON | Variables updated |
| SetActive false/true | Toggle active | IsActive toggled |
| Unique UUIDs | Create 2 pages | Different UUIDs |

#### ContentCategory Entity (`domain_content_category_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| NewContentCategory valid | Create with name, slug | Entity created |
| Empty name/slug/both | Invalid input | Error returned |
| UpdateName/UpdateSlug | Valid and empty input | Success or error |

#### Content Entity (`domain_content_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| NewContent valid | Create with all fields | Status=draft, PublishedAt=nil, Metadata={} |
| NewContent custom metadata | With JSON metadata | Metadata set correctly |
| NewContent empty body/excerpt | Body="" & Excerpt="" | Allowed (no error) |
| Empty title/slug | Invalid input | Error returned |
| **Publish draft→published** | Publish() on draft | Status=published, PublishedAt set |
| **Double publish (BLOCKED)** | Publish() on published | Error: "already published" |
| Published→archived | Archive() on published | Status=archived |
| Archived→draft | ToDraft() on archived | Status=draft, PublishedAt=nil |
| Draft→archived | Archive() on draft | Status=archived |
| Archived→published | Publish() on archived | Status=published |
| UpdateTitle/Slug valid/empty | Valid and empty | Success or error |
| UpdateBody | Set body + excerpt | Both updated |
| UpdateMetadata | Set JSON | Metadata updated |
| Status constants | draft/published/archived | Match string values |

#### User Entity (`domain_user_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| NewUser valid | Create with all fields | IsActive=true |
| Empty role defaults to viewer | Role="" | Role=viewer |
| All role types | admin/editor/viewer | All accepted |
| Empty email/password/name/all | Invalid input | Error returned |
| UpdateName/Email valid/empty | Valid and empty | Success or error |
| UpdatePassword | Set new hash | PasswordHash updated |
| UpdateRole transitions | viewer→editor→admin→viewer | All transitions work |
| SetActive toggle | true↔false | Toggled correctly |
| Password not in JSON | json:"-" tag | Internal access works, not in JSON |

#### Domain Events (`domain_events_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| All 13 events | EventName() + OccurredAt() | Correct event name string + timestamp |

#### Domain Builder Entity (`domain_domain_builder_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| NewDomain valid input | name, slug, plural_name, sidebar_section | Domain created, Fields=[], timestamps set |
| NewDomain with description & icon | Optional pointer fields | Description & icon set |
| NewDomain empty sidebar_section | sidebar_section="" | Defaults to "content" |
| NewDomain empty name | name="" | Error: "name is required" |
| NewDomain empty slug | slug="" | Error: "slug is required" |
| NewDomain empty plural_name | plural_name="" | Error: "plural_name is required" |
| NewDomainField valid text field | All params valid | Field created with correct ID + DomainID |
| NewDomainField all 12 valid types | text/textarea/number/email/url/phone/date/select/checkbox/image_url/rich_text/relation | All accepted |
| NewDomainField invalid type | FieldType="unknown" | Error: "invalid field type" |
| NewDomainField empty name | name="" | Error |
| NewDomainField empty label | label="" | Error |
| FieldType constants | ValidFieldTypes map check | All 12 types present |
| Domain UUID uniqueness | Create 2 domains | Different UUIDs |

---

### 2.2 Command Handler Layer (6 files, ~58 test cases)

#### Page Commands (`command_page_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| CreatePage success | Valid input | Saved + page.created event |
| CreatePage empty name | Domain validation | Error, nothing saved, no event |
| CreatePage repo error | DB connection lost | Error propagated, no event |
| CreatePage duplicate slug | Same slug twice | Error: duplicate |
| CreatePage event bus failure | Event bus unavailable | Page saved but error returned |
| UpdatePage success | Existing page | Updated + page.updated event |
| UpdatePage not found | Non-existent ID | Error: not found, no event |
| UpdatePage empty name | Domain validation | Error, no event |
| UpdatePage repo error | Disk full | Error propagated |
| DeletePage success | Existing page | Deleted + page.deleted event |
| DeletePage not found | Non-existent ID | Error: not found |
| DeletePage double delete | Same ID twice | Second delete: not found |

#### Content Commands (`command_content_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| CreateContent success | Valid input | Saved + content.created event |
| CreateContent empty title | Validation | Error |
| CreateContent duplicate slug | Same slug twice | Error: duplicate |
| CreateContent repo error | Connection refused | Error |
| UpdateContent success | Existing | Updated + content.updated event |
| UpdateContent not found | Non-existent | Error: not found |
| UpdateContent empty title | Validation | Error |
| **PublishContent success** | Draft content | Published + content.published event |
| **PublishContent double publish** | Already published | Error: already published, no event |
| PublishContent not found | Non-existent | Error: not found |
| DeleteContent success/not found | Existing/non-existent | Deleted or error |

#### ContentCategory & User Commands
Sama pattern: success, validation, duplicate, repo error, not found.

#### Domain Builder Commands (`command_domain_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| CreateDomain without fields | Valid name/slug/plural | Saved + domain.created event |
| CreateDomain with 2 fields | text + number fields | Domain + fields saved, event published |
| CreateDomain with description/icon | Optional pointer fields | Saved with description and icon |
| CreateDomain empty name | name="" | Error from domain factory, no event |
| CreateDomain empty slug | slug="" | Error from domain factory, no event |
| CreateDomain duplicate slug | Same slug twice | Error: duplicate slug |
| CreateDomain invalid field type | FieldType="unsupported" | Error: invalid field type |
| CreateDomain repo error | SaveDomainErr set | Error propagated, no event |
| UpdateDomain metadata | Change name/slug | Updated + domain.updated event |
| UpdateDomain replace fields | 1 field → 2 fields | Fields replaced (ReplaceFields called) |
| UpdateDomain not found | Non-existent ID | Error: not found |
| DeleteDomain success | Existing domain | Deleted + domain.deleted event |
| DeleteDomain not found | Non-existent ID | Error: not found |
| CreateDomainRecord success | Valid domain_slug + data | Record saved + domain_record.created |
| CreateDomainRecord domain not found | Non-existent slug | Error: domain not found |
| CreateDomainRecord repo error | SaveRecordErr set | Error propagated, no event |
| UpdateDomainRecord success | Existing record | Updated + domain_record.updated event |
| UpdateDomainRecord not found | Non-existent record ID | Error: not found |
| DeleteDomainRecord success | Existing record | Deleted + domain_record.deleted event |
| DeleteDomainRecord not found | Non-existent record ID | Error: not found |

---

### 2.3 HTTP Handler Layer (6 files, ~84 test cases)

#### Page HTTP Handler (`http_page_handler_test.go`)
| Test Case | Status Code | Scenario |
|---|---|---|
| POST valid | 201 | Created successfully |
| POST missing name | 400 | Validator: required field |
| POST missing slug | 400 | Validator: required field |
| POST malformed JSON | 400 | JSON decode error |
| POST empty body | 400 | Empty body |
| GET invalid UUID | 400 | UUID parse error |
| GET trailing slash | 301/200/404 | Router behavior |
| **GET default pagination** | 200 | page=1, limit=20 |
| **GET custom pagination** | 200 | page=2, limit=10 |
| **GET negative page** | 200 | Corrected to page=1 |
| **GET zero limit** | 200 | Corrected to limit=20 |
| **GET non-numeric params** | 200 | Defaults applied |
| **GET page beyond total** | 200 | Empty items, correct total |
| PUT invalid UUID | 400 | UUID parse error |
| PUT malformed JSON | 400 | JSON decode error |
| PUT missing required fields | 400 | Validator |
| DELETE invalid UUID | 400 | UUID parse error |
| DELETE non-existent | 500 | Not found error |
| PATCH (not supported) | 405 | Method not allowed |
| Full CRUD flow | 201→200→200→200 | Create→List→Delete→Verify empty |
| Success response format | 200/201 | Has `data` key, no `error` key |
| Error response format | 400 | Has `error` key |

#### Content HTTP Handler (`http_content_handler_test.go`)
| Test Case | Status Code | Scenario |
|---|---|---|
| POST valid | 201 | Created |
| POST missing title | 400 | Validator |
| POST missing page_id (FK) | 400 | Missing FK reference |
| POST malformed JSON | 400 | Decode error |
| GET invalid UUID | 400 | Parse error |
| PUT publish invalid UUID | 400 | Parse error |
| PUT publish non-existent | 500 | Not found |
| GET slug not found | 404/500 | Slug doesn't exist |
| Full CRUD + Publish | 201→200→200→200→200 | Create→List→Update→Publish→Delete |

#### ContentCategory & User HTTP Handlers
Sama pattern: valid/invalid input, malformed JSON, invalid UUID, full CRUD flow.

#### Domain Builder HTTP Handler (`http_domain_handler_test.go`)
| Test Case | Status Code | Scenario |
|---|---|---|
| POST domain valid (no fields) | 201 | name/slug/plural_name valid |
| POST domain valid (with fields) | 201 | text + number fields |
| POST domain missing required fields | 400 | Validator: slug/plural_name missing |
| POST domain malformed JSON | 400 | JSON decode error |
| GET domains empty | 200 | Returns total=0 |
| GET domains after create | 200 | total ≥ 1 |
| GET domain invalid UUID | 400 | UUID parse error |
| GET domain not found | 404 | Non-existent UUID |
| DELETE domain invalid UUID | 400 | UUID parse error |
| Full Domain CRUD | 201→200→200→200→200 | Create→List→GetByID→Update→Delete→Verify |
| POST record valid | 201 | data field created |
| POST record malformed JSON | 400 | Decode error |
| POST record domain not found | 500 | Non-existent domain_slug |
| GET records list | 200 | Returns items + total |
| GET records with search | 200 | Search filter applied |
| GET record invalid UUID | 400 | UUID parse error |
| GET record not found | 404 | Non-existent record ID |
| Full Record CRUD | 201→200→200→200→200 | Create→List→GetByID→Update→Delete→Verify |
| GET record options | 200 | Returns 1 option for 1 record |

---

### 2.4 Infrastructure Layer (4 files, ~25 test cases)

#### CommandBus (`commandbus_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| Dispatch registered | Valid handler | Handler invoked |
| Dispatch unregistered | No handler | Error: no handler registered |
| Handler error | Handler returns error | Error propagated |
| Before hook blocks | Hook returns error | Handler NOT invoked |
| After hook captures | Handler error | Hook receives error |

#### QueryBus (`querybus_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| Dispatch with result | Valid handler | Result returned |
| No handler registered | Unknown query | Error |
| Handler error | Handler returns error | Error, nil result |
| Nil result without error | Handler returns nil, nil | Valid (no error) |

#### EventBus (`eventbus_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| Publish triggers subscriber | 1 subscriber | Subscriber invoked |
| Multiple subscribers | 3 subscribers | All 3 invoked |
| No subscriber | Orphan event | No error |
| Subscriber error | First sub errors | Second sub still invoked |
| Event name isolation | Publish event.a | Only event.a subscriber triggered |

#### Middleware (`middleware_test.go`)
| Test Case | Scenario | Expected |
|---|---|---|
| **Panic recovery** | Handler panics | 500 returned, no crash |
| Normal request | No panic | Passes through |
| CORS headers | GET request | All CORS headers set |
| **OPTIONS preflight** | OPTIONS request | 204 No Content |
| Logging | GET /test | Request processed with logger |

---

## 3. Robustness Coverage Matrix

| Vulnerability | Covered By | Test Files |
|---|---|---|
| Empty/null required fields | Domain entity validation | domain_*_test.go |
| Malformed JSON body | HTTP handler JSON decode | http_*_handler_test.go |
| Empty request body | HTTP handler decode | http_page_handler_test.go |
| Invalid UUID in URL path | HTTP handler UUID parse | http_*_handler_test.go |
| Invalid email format | go-playground/validator | http_user_handler_test.go |
| Invalid enum values (role) | validator oneof | http_user_handler_test.go |
| Duplicate unique constraints (slug) | Mock repo unique check | command_page_test.go, command_content_test.go |
| Duplicate unique constraints (email) | Mock repo unique check | command_user_test.go |
| Not found on update/delete | Repository FindByID | command_*_test.go |
| Double delete | Delete same ID twice | command_page_test.go |
| **Double publish** | Content state guard | domain_content_test.go, command_content_test.go |
| **State transition violations** | Domain entity rules | domain_content_test.go |
| Database connection error | Mock SaveErr/UpdateErr | command_*_test.go |
| Event bus failure | Mock ShouldFail | command_page_test.go |
| Duplicate domain slug | Mock slug uniqueness | command_domain_test.go |
| Invalid DomainField type | ValidFieldTypes guard | domain_domain_builder_test.go |
| Domain record on non-existent domain | FindDomainBySlug error | command_domain_test.go |
| Domain not found on update/delete | FindDomainByID error | command_domain_test.go |
| Domain record not found | FindRecordByID error | command_domain_test.go |
| Domain record repo error | SaveRecordErr | command_domain_test.go |
| Pagination: negative page | HTTP handler default | http_page_handler_test.go |
| Pagination: zero limit | HTTP handler default | http_page_handler_test.go |
| Pagination: non-numeric | strconv.Atoi fallback | http_page_handler_test.go |
| Pagination: beyond total | Offset > count | http_page_handler_test.go |
| Unregistered command/query | Bus dispatch error | commandbus_test.go, querybus_test.go |
| Hook blocks execution | Before hook error | commandbus_test.go |
| **Panic in handler** | Recovery middleware | middleware_test.go |
| CORS preflight | OPTIONS → 204 | middleware_test.go |
| Method not allowed | PATCH on pages | http_page_handler_test.go |
| Password leak via JSON | json:"-" tag | domain_user_test.go |
| Event subscriber isolation | Error in one sub | eventbus_test.go |
| **JWT token generation & validation** | Generate, validate, expiry | auth_jwt_test.go |
| **JWT expired token** | Token past expiry | auth_jwt_test.go |
| **JWT wrong signing key** | Different secret | auth_jwt_test.go |
| **JWT unique JTI per token** | Each token unique ID | auth_jwt_test.go |
| **Password hash/verify (bcrypt)** | Hash then check | auth_jwt_test.go |
| **Wrong password rejected** | bcrypt mismatch | auth_jwt_test.go |
| **Same password different hash** | bcrypt salt | auth_jwt_test.go |
| **Missing Authorization header** | No header → 401 | auth_middleware_test.go |
| **Invalid Bearer format** | No "Bearer " prefix → 401 | auth_middleware_test.go |
| **Invalid token string** | Bad token → 401 | auth_middleware_test.go |
| **Expired token** | Expired JWT → 401 | auth_middleware_test.go |
| **Token from different secret** | Wrong key → 401 | auth_middleware_test.go |
| **Bearer case insensitive** | "bearer" accepted | auth_middleware_test.go |
| **RBAC: admin access admin route** | Allowed | auth_middleware_test.go |
| **RBAC: editor blocked from admin** | 403 Forbidden | auth_middleware_test.go |
| **RBAC: viewer blocked from editor** | 403 Forbidden | auth_middleware_test.go |
| **RBAC: multi-role route** | All permitted roles pass | auth_middleware_test.go |
| **RBAC: no token → 401 before role check** | Auth before RBAC | auth_middleware_test.go |
| **NotFoundError type detection** | IsNotFound() | apperror_test.go |
| **ValidationError type detection** | IsValidation() | apperror_test.go |
| **ConflictError type detection** | IsConflict() | apperror_test.go |
| **UnauthorizedError type detection** | IsUnauthorized() | apperror_test.go |
| **ForbiddenError type detection** | IsForbidden() | apperror_test.go |
| **Plain error false-positive** | No false match | apperror_test.go |
| **Max body size middleware** | Small body passes | auth_middleware_test.go |
| **GetClaims nil context** | No claims → nil | auth_middleware_test.go |

---

## 4. Menjalankan Tests

```bash
# Unit tests (tidak butuh database)
make test

# Unit tests dengan race detector
make test-race

# Integration tests (butuh Docker running)
make infra-up
make migrate-up
make test-integration

# Specific test file
go test ./tests/unit/... -run TestContentPublish -v
```

---

## 5. Coverage Gaps (TODO)

| Area | Deskripsi | Priority |
|---|---|---|
| Integration tests | Full CRUD dengan real PostgreSQL untuk semua entity | High |
| Concurrent write test | Simulasi race condition pada update | Medium |
| Large payload test | Request body > 1MB (body size limit) | Low |
| SQL injection test | Malicious input di slug/name | Medium |
| Cache consistency test | Verify cache invalidated after mutation | High |
| Load test | k6/vegeta untuk throughput benchmark | Medium |
| ~~Authentication test~~ | ~~JWT middleware~~ | ~~Done (v1.1.0)~~ |
| Token refresh flow | End-to-end refresh token rotation | Medium |
| Token blacklist | Revoked token rejection | Pending (not implemented) |
| Login brute force | Rate limiting on login endpoint | Medium |

---
*Di-generate saat project init. Update sesuai perkembangan project.*

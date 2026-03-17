# Vernon CMS — Root Makefile
# Delegate semua command ke sub-project yang relevan

.PHONY: infra-up infra-down dev-api dev-web dev-admin \
        test-api test-web test-admin build-api build-web build-admin \
        sqlc mock migrate-up migrate-down \
        gen-web gen-admin lint-api lint-web lint-admin tidy

# ── Infrastructure ────────────────────────────────────────────────
infra-up:
	$(MAKE) -C api infra-up

infra-down:
	$(MAKE) -C api infra-down

# ── Development ───────────────────────────────────────────────────
dev-api:
	$(MAKE) -C api dev

dev-web:
	$(MAKE) -C web run

dev-admin:
	$(MAKE) -C app_admin run

dev:
	@echo "Jalankan di terminal terpisah:"
	@echo "  Terminal 1: make dev-api"
	@echo "  Terminal 2: make dev-web      (CMS dashboard, port 3000)"
	@echo "  Terminal 3: make dev-admin    (Admin panel, port 3001)"

# ── Testing ───────────────────────────────────────────────────────
test-api:
	$(MAKE) -C api test

test-api-race:
	$(MAKE) -C api test-race

test-api-integration:
	$(MAKE) -C api test-integration

test-web:
	$(MAKE) -C web test

test-admin:
	$(MAKE) -C app_admin test

test: test-api test-web test-admin

# ── Build ─────────────────────────────────────────────────────────
build-api:
	$(MAKE) -C api build

build-web:
	$(MAKE) -C web build-web

build-admin:
	$(MAKE) -C app_admin build-web

# ── Code Generation ───────────────────────────────────────────────
sqlc:
	$(MAKE) -C api sqlc

mock:
	$(MAKE) -C api mock

migrate-up:
	$(MAKE) -C api migrate-up

migrate-down:
	$(MAKE) -C api migrate-down

gen-web:
	$(MAKE) -C web gen

gen-web-watch:
	$(MAKE) -C web gen-watch

gen-admin:
	$(MAKE) -C app_admin gen

gen-admin-watch:
	$(MAKE) -C app_admin gen-watch

# ── Code Quality ──────────────────────────────────────────────────
lint-api:
	$(MAKE) -C api lint

lint-web:
	$(MAKE) -C web analyze

lint-admin:
	$(MAKE) -C app_admin analyze

tidy:
	$(MAKE) -C api tidy

clean-web:
	$(MAKE) -C web clean

clean-admin:
	$(MAKE) -C app_admin clean

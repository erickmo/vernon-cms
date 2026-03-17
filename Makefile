# Vernon CMS — Root Makefile
# Delegate semua command ke sub-project yang relevan

.PHONY: infra-up infra-down dev-api dev-web \
        test-api test-web build-api build-web \
        sqlc mock migrate-up migrate-down \
        gen-web lint-api lint-web tidy

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

# Jalankan API + Web sekaligus (butuh 2 tab terminal)
dev:
	@echo "Jalankan di dua terminal terpisah:"
	@echo "  Terminal 1: make dev-api"
	@echo "  Terminal 2: make dev-web"

# ── Testing ───────────────────────────────────────────────────────
test-api:
	$(MAKE) -C api test

test-api-race:
	$(MAKE) -C api test-race

test-api-integration:
	$(MAKE) -C api test-integration

test-web:
	$(MAKE) -C web test

test: test-api test-web

# ── Build ─────────────────────────────────────────────────────────
build-api:
	$(MAKE) -C api build

build-web:
	$(MAKE) -C web build-web

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

# ── Code Quality ──────────────────────────────────────────────────
lint-api:
	$(MAKE) -C api lint

lint-web:
	$(MAKE) -C web analyze

tidy:
	$(MAKE) -C api tidy

clean-web:
	$(MAKE) -C web clean

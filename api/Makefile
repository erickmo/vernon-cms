SERVICE=vernon-cms
MAIN=./cmd/api
BIN=./bin/$(SERVICE)

.PHONY: build dev test test-race test-integration lint sqlc mock migrate infra-up

build:
	go build -o $(BIN) $(MAIN)

run: build
	$(BIN)

dev:
	air

test:
	go test ./internal/... ./pkg/... -v -timeout 30s

test-race:
	go test -race ./... -timeout 60s

test-integration:
	go test ./tests/integration/... -v -timeout 120s -tags integration

lint:
	golangci-lint run ./...

sqlc:
	sqlc generate

mock:
	mockery --all --dir=internal/domain --output=internal/mocks --outpkg=mocks

migrate-up:
	migrate -path migrations -database "$(DATABASE_URL)" up

migrate-down:
	migrate -path migrations -database "$(DATABASE_URL)" down 1

migrate-create:
	migrate create -ext sql -dir migrations -seq $(name)

infra-up:
	docker compose up -d

infra-down:
	docker compose down

tidy:
	go mod tidy
